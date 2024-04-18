import UIKit
import SwiftUI

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
        label.edgesToSuperview(excluding: .trailing, insets: .uniform(8))
        let hosting = UIHostingConfiguration {
            Image(systemName: "gear")
                .foregroundStyle(.white)
        }
        let hostingView = hosting.makeContentView()
        addSubview(hostingView)
        hostingView.edgesToSuperview(excluding: .leading, insets: .uniform(8))
        hostingView.leadingToTrailing(of: label)
    }

    private func setupAppearence() {
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .white
        backgroundColor = .systemIndigo
        label.backgroundColor = backgroundColor
    }

    func render(viewState: String) {
        label.text = viewState
    }
}
