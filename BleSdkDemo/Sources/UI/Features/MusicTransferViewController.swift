import UIKit
import UniformTypeIdentifiers

final class MusicTransferViewController: UIViewController, UIDocumentPickerDelegate {
    private let repo = BleRepository.shared
    private let statusLabel = UIHelpers.makeLabel("")
    private let storageLabel = UIHelpers.makeLabel("—")
    private let progress = UIProgressView(progressViewStyle: .default)
    private let logView = UITextView()
    private var pickedURLs: [URL] = []
    private var busy = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("music")
        view.backgroundColor = .systemBackground
        statusLabel.text = L10n.tr("feature_ready")
        let refresh = UIHelpers.makeButton(L10n.tr("music_query_storage"))
        let pick = UIHelpers.makeButton(L10n.tr("music_pick_files"))
        let push = UIHelpers.makeButton(L10n.tr("music_push"), primary: true)
        let cancel = UIHelpers.makeButton(L10n.tr("music_cancel"))
        refresh.addTarget(self, action: #selector(refreshStorage), for: .touchUpInside)
        pick.addTarget(self, action: #selector(pickFiles), for: .touchUpInside)
        push.addTarget(self, action: #selector(pushAuto), for: .touchUpInside)
        cancel.addTarget(self, action: #selector(cancelTransfer), for: .touchUpInside)
        progress.translatesAutoresizingMaskIntoConstraints = false
        logView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logView.isEditable = false
        logView.backgroundColor = .secondarySystemBackground
        logView.layer.cornerRadius = 8
        let stack = UIStackView(arrangedSubviews: [
            statusLabel, storageLabel, refresh, pick, push, cancel, progress, logView
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
        refreshStorage()
    }

    @objc private func refreshStorage() {
        repo.getMusicStorage { [weak self] result in
            switch result {
            case .success(let s):
                // SDK 回调单位为 KB，UI 与 Android/HaWoFit 一致按 MB 展示（小数点固定用 `.`）
                let availableMb = Double(s.availableKb) / 1024.0
                let totalMb = Double(s.totalKb) / 1024.0
                self?.storageLabel.text = String(
                    format: "%.2fMB / %.2fMB",
                    locale: Locale(identifier: "en_US_POSIX"),
                    availableMb,
                    totalMb
                )
                self?.append(L10n.tr("music_storage_ok_log"))
            case .failure(let e):
                self?.storageLabel.text = L10n.tr("music_storage_fail")
                self?.append(e.localizedDescription)
            }
        }
    }

    @objc private func pickFiles() {
        // 对齐 HwMusicViewController：仅 public.mp3
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.mp3], asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        pickedURLs = urls
        append(L10n.tr("music_files_selected", urls.count, urls.map { $0.lastPathComponent }.joined(separator: ", ")))
    }

    @objc private func pushAuto() {
        guard !busy else { return }
        guard !pickedURLs.isEmpty else { append(L10n.tr("music_no_files")); return }
        busy = true
        statusLabel.text = L10n.tr("music_pushing")
        progress.progress = 0
        repo.pushMusicAuto(fileURLs: pickedURLs, onReady: { [weak self] in
            self?.append(L10n.tr("music_ready"))
        }, onProgress: { [weak self] p in
            self?.progress.progress = p
            self?.statusLabel.text = L10n.tr("music_progress", p * 100)
        }, completion: { [weak self] result in
            self?.busy = false
            switch result {
            case .success:
                self?.statusLabel.text = L10n.tr("music_push_ok")
                self?.append(L10n.tr("feature_success"))
                self?.refreshStorage()
            case .failure(let e):
                self?.statusLabel.text = L10n.tr("feature_failed")
                self?.append(e.localizedDescription)
            }
        })
    }

    @objc private func cancelTransfer() {
        repo.cancelTransfer()
        busy = false
        statusLabel.text = L10n.tr("music_cancelled")
        append(L10n.tr("music_cancelled"))
    }

    private func append(_ s: String) {
        logView.text = (logView.text ?? "") + s + "\n"
    }
}
