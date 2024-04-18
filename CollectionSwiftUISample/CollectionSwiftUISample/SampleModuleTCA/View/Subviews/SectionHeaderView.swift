import UIKit

final class SectionHeaderView: UICollectionReusableView {
    private let label = UILabel()

    static let kind = "section.header"

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setupSubviews()
        setupAppearence()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        addSubview(label)
        label.edgesToSuperview(insets: .uniform(8))
    }

    private func setupAppearence() {
        label.font = .boldSystemFont(ofSize: 22)
        backgroundColor = .systemIndigo
        label.backgroundColor = backgroundColor
    }

    func render(viewState: String) {
        label.text = viewState
    }
}
