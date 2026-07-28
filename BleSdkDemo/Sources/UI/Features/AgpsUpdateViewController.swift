import UIKit

enum AgpsTimeFormatter {
    private static let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        f.locale = Locale.current
        return f
    }()

    static func formatRange(startMs: Int64, endMs: Int64) -> String {
        if startMs <= 0 && endMs <= 0 { return L10n.tr("agps_valid_unknown") }
        let start = startMs > 0 ? dateFmt.string(from: Date(timeIntervalSince1970: TimeInterval(startMs) / 1000.0)) : "-"
        let end = endMs > 0 ? dateFmt.string(from: Date(timeIntervalSince1970: TimeInterval(endMs) / 1000.0)) : "-"
        let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
        if endMs > 0 && endMs < nowMs {
            return L10n.tr("agps_valid_expired", start, end)
        }
        return L10n.tr("agps_valid_range", start, end)
    }
}

final class AgpsUpdateViewController: UIViewController {
    private let repo = BleRepository.shared
    private let statusLabel = UIHelpers.makeLabel("")
    private let clipLabel = UIHelpers.makeLabel("")
    private let fwLabel = UIHelpers.makeLabel("")
    private let validLabel = UIHelpers.makeLabel("")
    private let progress = UIProgressView(progressViewStyle: .default)
    private let phaseLabel = UIHelpers.makeLabel("")
    private let logView = UITextView()
    private var busy = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("agps")
        view.backgroundColor = .systemBackground
        statusLabel.text = L10n.tr("feature_ready")
        clipLabel.text = L10n.tr("agps_gps_clip", "-")
        fwLabel.text = L10n.tr("agps_gps_fw", "-", 0)
        validLabel.text = L10n.tr("agps_valid_dash")
        let refresh = UIHelpers.makeButton(L10n.tr("agps_refresh_status"))
        let start = UIHelpers.makeButton(L10n.tr("agps_start"), primary: true)
        let cancel = UIHelpers.makeButton(L10n.tr("agps_cancel"))
        refresh.addTarget(self, action: #selector(refreshStatus), for: .touchUpInside)
        start.addTarget(self, action: #selector(startUpdate), for: .touchUpInside)
        cancel.addTarget(self, action: #selector(cancelUpdate), for: .touchUpInside)
        logView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logView.isEditable = false
        logView.backgroundColor = .secondarySystemBackground
        logView.layer.cornerRadius = 8
        let stack = UIStackView(arrangedSubviews: [
            statusLabel, clipLabel, fwLabel, validLabel, refresh, start, cancel, phaseLabel, progress, logView
        ])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            logView.heightAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ])
        refreshStatus()
    }

    @objc private func refreshStatus() {
        guard repo.isConnected() else {
            statusLabel.text = L10n.tr("status_need_connect")
            return
        }
        repo.getDeviceGpsStatus { [weak self] result in
            switch result {
            case .success(let gps):
                self?.clipLabel.text = L10n.tr("agps_gps_clip", gps.gpsClipType ?? "-")
                self?.fwLabel.text = L10n.tr("agps_gps_fw", gps.gpsFirmwareVersion ?? "-", gps.gpsFirmwareBuild)
                self?.validLabel.text = AgpsTimeFormatter.formatRange(
                    startMs: gps.agpsValidStartTimeMs,
                    endMs: gps.agpsValidEndTimeMs
                )
                self?.append(L10n.tr("agps_status_ok_log"))
                self?.statusLabel.text = L10n.tr("agps_status_ok")
            case .failure(let e):
                self?.append(e.localizedDescription)
                self?.statusLabel.text = L10n.tr("agps_status_fail")
            }
        }
    }

    @objc private func startUpdate() {
        guard !busy else { return }
        guard repo.isConnected() else {
            statusLabel.text = L10n.tr("status_need_connect")
            return
        }
        busy = true
        progress.progress = 0
        phaseLabel.text = L10n.tr("agps_phase_download")
        statusLabel.text = L10n.tr("agps_preparing")
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("agps_\(UUID().uuidString)", isDirectory: true)
        AgpsXywBuilder.buildSevenDayZip(into: dir, onProgress: { [weak self] p in
            DispatchQueue.main.async {
                self?.progress.progress = p.fraction
                self?.phaseLabel.text = p.message
            }
        }, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let e):
                self.busy = false
                self.statusLabel.text = L10n.tr("agps_build_fail")
                self.append(e.localizedDescription)
            case .success(let built):
                self.append(L10n.tr(
                    "agps_zip_ready",
                    built.zipURL.lastPathComponent,
                    built.validStartTimeMs,
                    built.validEndTimeMs
                ))
                self.phaseLabel.text = L10n.tr("agps_phase_push")
                self.statusLabel.text = L10n.tr("agps_pushing")
                self.repo.pushAgpsZip(zipURL: built.zipURL, onProgress: { [weak self] p in
                    self?.progress.progress = 0.5 + Float(p) / 200.0
                    self?.statusLabel.text = L10n.tr("agps_push_progress", p)
                }, completion: { [weak self] pushResult in
                    self?.busy = false
                    switch pushResult {
                    case .success:
                        self?.statusLabel.text = L10n.tr("agps_push_ok")
                        self?.phaseLabel.text = L10n.tr("agps_phase_done")
                        self?.progress.progress = 1
                        self?.append(L10n.tr("agps_push_ok"))
                        self?.refreshStatus()
                    case .failure(let e):
                        self?.statusLabel.text = L10n.tr("agps_push_fail")
                        self?.append(e.localizedDescription)
                    }
                })
            }
        })
    }

    @objc private func cancelUpdate() {
        repo.cancelTransfer()
        busy = false
        statusLabel.text = L10n.tr("agps_cancelled")
        append(L10n.tr("agps_cancelled"))
    }

    private func append(_ s: String) {
        logView.text = (logView.text ?? "") + s + "\n"
    }
}
