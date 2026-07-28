import UIKit
import PhotosUI

final class AlbumTransferViewController: UIViewController, PHPickerViewControllerDelegate, UITextFieldDelegate {
    private let repo = BleRepository.shared
    private let statusLabel = UIHelpers.makeLabel("")
    private let infoLabel = UIHelpers.makeLabel("")
    private let widthField = UITextField()
    private let heightField = UITextField()
    private let progress = UIProgressView(progressViewStyle: .default)
    private let logView = UITextView()
    private var images: [UIImage] = []
    private var busy = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.tr("album")
        view.backgroundColor = .systemBackground
        statusLabel.text = L10n.tr("feature_ready")
        infoLabel.text = L10n.tr("album_none_selected")

        let sizeTitle = UIHelpers.makeLabel(L10n.tr("album_target_size_title"))
        sizeTitle.font = .preferredFont(forTextStyle: .subheadline)
        sizeTitle.textColor = .secondaryLabel
        configureSizeField(widthField, placeholder: L10n.tr("album_width"), defaultValue: 466)
        configureSizeField(heightField, placeholder: L10n.tr("album_height"), defaultValue: 466)
        let xLabel = UIHelpers.makeLabel("×")
        xLabel.textAlignment = .center
        xLabel.setContentHuggingPriority(.required, for: .horizontal)
        let sizeRow = UIStackView(arrangedSubviews: [widthField, xLabel, heightField])
        sizeRow.axis = .horizontal
        sizeRow.spacing = 8
        sizeRow.alignment = .center
        widthField.widthAnchor.constraint(equalTo: heightField.widthAnchor).isActive = true

        let ids = UIHelpers.makeButton(L10n.tr("album_query_ids"))
        let pick = UIHelpers.makeButton(L10n.tr("album_pick_files"))
        let push = UIHelpers.makeButton(L10n.tr("album_push"), primary: true)
        let cancel = UIHelpers.makeButton(L10n.tr("album_cancel"))
        ids.addTarget(self, action: #selector(queryIds), for: .touchUpInside)
        pick.addTarget(self, action: #selector(pickImages), for: .touchUpInside)
        push.addTarget(self, action: #selector(pushAuto), for: .touchUpInside)
        cancel.addTarget(self, action: #selector(cancelTransfer), for: .touchUpInside)
        logView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logView.isEditable = false
        logView.backgroundColor = .secondarySystemBackground
        logView.layer.cornerRadius = 8
        let stack = UIStackView(arrangedSubviews: [
            statusLabel, infoLabel, sizeTitle, sizeRow, ids, pick, push, cancel, progress, logView
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
            logView.heightAnchor.constraint(greaterThanOrEqualToConstant: 180),
            widthField.heightAnchor.constraint(equalToConstant: 40),
            heightField.heightAnchor.constraint(equalToConstant: 40)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func configureSizeField(_ field: UITextField, placeholder: String, defaultValue: Int) {
        field.placeholder = placeholder
        field.text = "\(defaultValue)"
        field.keyboardType = .numberPad
        field.borderStyle = .roundedRect
        field.textAlignment = .center
        field.delegate = self
        field.font = .monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        field.accessibilityLabel = placeholder
    }

    @objc private func endEditingTap() {
        view.endEditing(true)
    }

    private func resolvedTargetSize() -> CGSize? {
        let w = Int(widthField.text?.trimmingCharacters(in: .whitespaces) ?? "") ?? 0
        let h = Int(heightField.text?.trimmingCharacters(in: .whitespaces) ?? "") ?? 0
        guard w > 0, h > 0, w <= 4096, h <= 4096 else { return nil }
        return CGSize(width: w, height: h)
    }

    @objc private func queryIds() {
        repo.getAlbumFileIds { [weak self] result in
            switch result {
            case .success(let ids):
                self?.append(L10n.tr("album_ids_log", "\(ids)"))
            case .failure(let e):
                self?.append(e.localizedDescription)
            }
        }
    }

    @objc private func pickImages() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 10
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        images.removeAll()
        let group = DispatchGroup()
        for r in results {
            group.enter()
            r.itemProvider.loadObject(ofClass: UIImage.self) { obj, _ in
                if let img = obj as? UIImage { self.images.append(img) }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.infoLabel.text = L10n.tr("album_selected_count", self.images.count)
            self.append(L10n.tr("album_files_selected", self.images.count))
        }
    }

    @objc private func pushAuto() {
        guard !busy else { return }
        guard !images.isEmpty else { append(L10n.tr("album_no_files")); return }
        guard let size = resolvedTargetSize() else {
            append(L10n.tr("album_invalid_size"))
            return
        }
        view.endEditing(true)
        busy = true
        statusLabel.text = L10n.tr("album_pushing")
        progress.progress = 0
        append(L10n.tr("album_resize_log", Int(size.width), Int(size.height)))
        repo.pushAlbumAuto(images: images, size: size, onReady: { [weak self] in
            self?.append(L10n.tr("album_ready"))
        }, onProgress: { [weak self] p in
            self?.progress.progress = p
            self?.statusLabel.text = L10n.tr("album_progress", p * 100)
        }, completion: { [weak self] result in
            self?.busy = false
            switch result {
            case .success:
                self?.statusLabel.text = L10n.tr("feature_success")
                self?.append(L10n.tr("album_push_ok"))
                self?.queryIds()
            case .failure(let e):
                self?.statusLabel.text = L10n.tr("feature_failed")
                self?.append(e.localizedDescription)
            }
        })
    }

    @objc private func cancelTransfer() {
        repo.cancelTransfer()
        busy = false
        statusLabel.text = L10n.tr("album_cancelled")
        append(L10n.tr("album_cancelled"))
    }

    private func append(_ s: String) {
        logView.text = (logView.text ?? "") + s + "\n"
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        return string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
