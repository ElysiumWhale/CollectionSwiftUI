import UIKit
import SwiftUI
import TinyConstraints
import ComposableArchitecture

final class MainViewController: UIViewController {
    private let viewStore: ViewStoreOf<MainSystem>

    init(viewStore: ViewStoreOf<MainSystem>) {
        self.viewStore = viewStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        setupAppearence()
    }

    private func setupSubviews() {
        let hosting = UIHostingConfiguration { [weak viewStore] in
            Button("Go to Sample") {
                viewStore?.send(.showSample)
            }
            .buttonStyle(.borderedProminent)
        }

        let hostingView = hosting.makeContentView()
        view.addSubview(hostingView)
        hostingView.edgesToSuperview()
    }

    private func setupAppearence() {
        view.backgroundColor = .systemBackground
    }
}
