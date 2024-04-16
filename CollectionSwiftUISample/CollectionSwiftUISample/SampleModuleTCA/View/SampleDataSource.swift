import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture

extension SampleViewController {
    /// Идентификаторы ячеек для **ручной** регистрации
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

    /// - Parameters:
    ///   - storeProvider: Для ячеек с ТСА системой
    ///   - actionHandler: Обработчик событий в ячейках
    static func makeDataSource(
        collection: UICollectionView,
        storeProvider: @escaping (SampleItemSystem.State.ID) -> StoreOf<SampleItemSystem>?,
        viewStoreProvider: @escaping () -> ViewStoreOf<SampleSystem>?,
        actionHandler: @escaping (SampleSystem.Action) -> Void
    ) -> DataSource {
        // Регистрация должна создаваться вне самого дата сорса
        let loader = CellProvider.loader()
        let footer = CellProvider.footer(actionHandler)

        // TODO: - Add supplementary
        // result.supplementaryViewProvider = { }

        return DataSource(collectionView: collection) { collection, index, item in
            switch item {
            case let .listItem(id, _):
                let cell = collection.dequeue(id: Cell.listItemCell, for: index)
                // MARK: Конфигурация ячейки с ТСА системой
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
                // MARK: Конфигурация ячейки + отдельная конфигурация фона
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
                // MARK: Конфигурация ячейки без ТСА системы с проборосом Binding
                let binding = viewStoreProvider()?.binding(
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
                // MARK: Использование UICollectionView.CellRegistration
                // для выноса логики настройки ячейки
                // При использовании данного подхода не требуется ручная регистрация
                return collection.dequeue(footer, for: index, item: item)
            case .loader:
                // MARK: Использование UICollectionView.CellRegistration
                // для выноса логики настройки ячейки
                // При использовании данного подхода не требуется ручная регистрация
                return collection.dequeue(loader, for: index, item: .systemGray)
            }
        }
    }
}
