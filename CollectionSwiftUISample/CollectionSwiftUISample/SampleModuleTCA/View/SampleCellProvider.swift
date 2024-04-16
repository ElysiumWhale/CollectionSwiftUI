import UIKit
import SwiftUI

extension SampleViewController {
    enum CellProvider {
        static let loader = Registration { cell, index, item in
            // SwiftUI.ProgressView работает только один раз
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.color = item
            indicator.startAnimating()
            cell.contentView.addSubview(indicator)
            indicator.edgesToSuperview()
        }

        static func footer(
            _ handler: @escaping (SampleSystem.Action) -> Void
        ) -> Registration<UICollectionViewCell, Item> {
            Registration { cell, _, _ in
                cell.contentConfiguration = UIHostingConfiguration {
                    Button(
                        action: { handler(.scrollTo(.top)) },
                        label: { Image(systemName: "arrow.up") }
                    )
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
