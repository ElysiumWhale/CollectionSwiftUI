import UIKit
import SwiftUI

extension SampleViewController {
    /// Фабрика регистраций ячеек
    enum CellProvider {
        /// Пример регистрации ячейки с параметром конфигурации,
        /// отличным от элемента источника данных (`UIColor` вместо `Item`)
        static func loader() -> Registration<UICollectionViewCell, UIColor> {
            Registration { cell, index, item in
                // SwiftUI.ProgressView работает только один раз
                let indicator = UIActivityIndicatorView(style: .medium)
                indicator.color = item
                indicator.startAnimating()
                cell.contentView.addSubview(indicator)
                indicator.edgesToSuperview()
            }
        }

        /// Пример регистрации ячейки с параметром конфигурации,
        /// совпадающим с элементом источника данных
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
