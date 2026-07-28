import UIKit

final class UnbindFlowViewController: UIViewController {
    private let repo = BleRepository.shared
    var onFinished: ((Bool) -> Void)?

    private var steps: [FlowStep] = []
    private let table = UITableView(frame: .zero, style: .insetGrouped)
    private let startButton = UIHelpers.makeButton("", primary: true)
    private let closeButton = UIHelpers.makeButton("")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("unbind_title")
        view.backgroundColor = .systemBackground
        startButton.setTitle(L10n.tr("unbind_start"), for: .normal)
        closeButton.setTitle(L10n.tr("close"), for: .normal)
        steps = [
            FlowStep(api: "unbindDevice", description: L10n.tr("unbind_step_unbind"), platformNote: L10n.tr("unbind_note_ios")),
            FlowStep(api: "disconnect", description: L10n.tr("unbind_step_disconnect"), platformNote: nil),
            FlowStep(api: "removeConnectionCache", description: L10n.tr("unbind_step_cache"), platformNote: nil),
            FlowStep(api: "BoundDeviceStore.clear", description: L10n.tr("unbind_step_local"), platformNote: nil)
        ]
        table.dataSource = self
        table.register(FlowStepCell.self, forCellReuseIdentifier: FlowStepCell.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(table)
        view.addSubview(startButton)
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -12),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            startButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -8),
            closeButton.leadingAnchor.constraint(equalTo: startButton.leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: startButton.trailingAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    @objc private func close() {
        dismiss(animated: true) { self.onFinished?(false) }
    }

    @objc private func start() {
        startButton.isEnabled = false
        soft(0) { done in
            self.repo.unbindDevice(completion: done)
        } then: {
            self.soft(1) { done in
                self.repo.disconnect { err in
                    if let err = err { done(.failure(err)) } else { done(.success(())) }
                }
            } then: {
                self.hard(2) { done in
                    self.repo.removeConnectionCache()
                    done(.success(()))
                } then: {
                    self.hard(3) { done in
                        self.repo.clearBoundDevice()
                        done(.success(()))
                    } then: {
                        self.dismiss(animated: true) { self.onFinished?(true) }
                    }
                }
            }
        }
    }

    private func soft(_ index: Int,
                      action: (@escaping (Result<Void, Error>) -> Void) -> Void,
                      then: @escaping () -> Void) {
        mark(index, .running)
        action { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success: self.mark(index, .done)
            case .failure(let e): self.mark(index, .skipped, e.localizedDescription)
            }
            then()
        }
    }

    private func hard(_ index: Int,
                      action: (@escaping (Result<Void, Error>) -> Void) -> Void,
                      then: @escaping () -> Void) {
        mark(index, .running)
        action { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.mark(index, .done)
                then()
            case .failure(let e):
                self.mark(index, .failed, e.localizedDescription)
                self.startButton.isEnabled = true
            }
        }
    }

    private func mark(_ index: Int, _ status: FlowStepStatus, _ detail: String? = nil) {
        steps[index].status = status
        steps[index].detail = detail
        table.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
}

extension UnbindFlowViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { steps.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FlowStepCell.reuseId, for: indexPath) as! FlowStepCell
        cell.configure(steps[indexPath.row])
        return cell
    }
}
