import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture

extension SampleViewController {
    enum Cell: String, CaseIterable {
        case toolbarCell
        case listItemCell
        case carouselItemCell
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
        case listItem(id: Int, salt: Int = 0)
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
        // Регистрация должна создаваться вне самого дата сорса
        let loader = CellProvider.loader()
        let footer = CellProvider.footer(actionHandler)

        // TODO: - Add supplementary
        // result.supplementaryViewProvider = { }

        return DataSource(collectionView: collection) { [weak self] collection, index, item in
            switch item {
            case let .listItem(id, _):
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
                .background {
                    HStack {
                        Text("Tap here")
                        Spacer()
                        Text("Tap here")
                    }
                    .padding(.horizontal, 16)
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
                return collection.dequeue(footer, for: index, item: item)
            case .loader:
                return collection.dequeue(loader, for: index, item: .systemGray)
            }
        }
    }
}
