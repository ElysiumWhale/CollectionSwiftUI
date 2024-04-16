import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture

extension SampleViewController {
    enum Cell: String, CaseIterable {
        case loaderCell
        case toolbarCell
        case listItemCell
        case carouselItemCell
        case footerCell
    }

    enum Section {
        case toolbar
        case carousel
        case list
        case footer
    }

    enum Item: Hashable {
        case loader
        case toolbar
        case listItem(id: Int)
        case carouselItem(id: Int)
        case footer
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    func makeDataSource(
        collection: UICollectionView,
        storeProvider: @escaping (SampleItemSystem.State.ID) -> StoreOf<SampleItemSystem>?,
        actionHandler: @escaping (SampleSystem.Action) -> Void
    ) -> DataSource {
        let result = DataSource(collectionView: collection) { [weak self] collection, index, item in
            switch item {
            case let .listItem(id):
                let cell = collection.dequeue(id: Cell.listItemCell, for: index)
                cell.contentConfiguration = UIHostingConfiguration {
                    if let store = storeProvider(id) {
                        SampleItemCell(store: store)
                    }
                }
                return cell
            case .toolbar:
                let cell = collection.dequeue(id: Cell.toolbarCell, for: index)
                cell.contentConfiguration = UIHostingConfiguration {
                    ToolbarView(actionHandler: actionHandler)
                }
                return cell
            case let .carouselItem(id):
                let cell = collection.dequeue(id: Cell.carouselItemCell, for: index)
                let binding = self?.viewStore.binding(
                    get: { $0.selectedCarouselItems.contains(id) },
                    send: { .setActiveCarouselItem(id, $0) }
                )
                cell.contentConfiguration = UIHostingConfiguration {
                    CarouselItemCell(
                        id: id,
                        action: { _ in
                            actionHandler(.scrollTo(.item(id)))
                        },
                        isActivated: binding ?? .constant(false)
                    )
                }
                return cell
            case .footer:
                let cell = collection.dequeue(id: Cell.footerCell, for: index)
                cell.contentConfiguration = UIHostingConfiguration {
                    Button(
                        action: { actionHandler(.scrollTo(.top)) },
                        label: { Image(systemName: "arrow.up") }
                    )
                    .buttonStyle(.borderedProminent)
                }
                return cell
            case .loader:
                let cell = collection.dequeue(id: Cell.loaderCell, for: index)
                // SwiftUI.ProgressView работает только один раз
                let indicator = UIActivityIndicatorView(style: .medium)
                indicator.startAnimating()
                cell.contentView.addSubview(indicator)
                indicator.edgesToSuperview()
                return cell
            }
        }

        // TODO: - Add supplementary
        // result.supplementaryViewProvider = { }

        return result
    }
}
