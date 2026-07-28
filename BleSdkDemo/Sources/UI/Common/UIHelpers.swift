import UIKit

final class FlowStepCell: UITableViewCell {
    static let reuseId = "FlowStepCell"
    let apiLabel = UILabel()
    let descLabel = UILabel()
    let statusLabel = UILabel()
    let detailLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        apiLabel.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        apiLabel.numberOfLines = 0
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.numberOfLines = 0
        statusLabel.font = .boldSystemFont(ofSize: 12)
        detailLabel.font = .systemFont(ofSize: 12)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [statusLabel, apiLabel, descLabel, detailLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(_ step: FlowStep) {
        apiLabel.text = step.api
        descLabel.text = step.description
        detailLabel.text = step.detail
        detailLabel.isHidden = (step.detail ?? "").isEmpty
        switch step.status {
        case .pending: statusLabel.text = L10n.tr("step_pending"); statusLabel.textColor = .secondaryLabel
        case .running: statusLabel.text = L10n.tr("step_running"); statusLabel.textColor = .systemBlue
        case .done: statusLabel.text = L10n.tr("step_done"); statusLabel.textColor = .systemGreen
        case .failed: statusLabel.text = L10n.tr("step_failed"); statusLabel.textColor = .systemRed
        case .skipped: statusLabel.text = L10n.tr("step_skipped"); statusLabel.textColor = .systemOrange
        }
    }
}

final class LogCell: UITableViewCell {
    static let reuseId = "LogCell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel?.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        textLabel?.numberOfLines = 0
        textLabel?.lineBreakMode = .byWordWrapping
        selectionStyle = .none
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }
}

enum UIHelpers {
    static func makeButton(_ title: String, primary: Bool = false) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.backgroundColor = primary ? UIColor.systemBlue : UIColor.secondarySystemBackground
        b.setTitleColor(primary ? .white : .label, for: .normal)
        b.setTitleColor(.tertiaryLabel, for: .disabled)
        b.layer.cornerRadius = 10
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        b.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return b
    }

    static func makeLabel(_ text: String = "", style: UIFont.TextStyle = .body) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .preferredFont(forTextStyle: style)
        l.numberOfLines = 0
        return l
    }
}
