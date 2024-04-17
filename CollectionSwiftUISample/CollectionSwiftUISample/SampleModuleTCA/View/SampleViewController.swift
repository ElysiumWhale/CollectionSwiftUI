import UIKit
import ComposableArchitecture
import Combine

/// Экран для демонстрации интеграции UICollectioniew со SwiftUI ячейками
final class SampleViewController: UIViewController {
    private let collection = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    private let store: StoreOf<SampleSystem>

    let viewStore: ViewStoreOf<SampleSystem>

    private var cancellables = Set<AnyCancellable>()

    private lazy var dataSource = Self.makeDataSource(
        collection: collection,
        storeProvider: { [weak self] id in
            self?.store.scope(state: \.sampleItems[id:id], action: \.item[id:id])
        },
        viewStoreProvider: {  [weak self] in
            self?.viewStore
        },
        actionHandler: { [weak self] in
            self?.viewStore.send($0)
        }
    )

    init(store: StoreOf<SampleSystem>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        setupToolbarAndFooter()
        setupAppearance()
        setupSubscriptions()

        viewStore.send(.loadItems)
    }

    private func setupSubviews() {
        Cell.allCases.forEach {
            collection.register(
                UICollectionViewCell.self,
                forCellWithReuseIdentifier: $0.rawValue
            )
        }
        view.addSubview(collection)
        collection.edgesToSuperview()

        collection.delegate = self
        collection.collectionViewLayout = .sampleLayout { [weak self] in
            self?.dataSource.sectionIdentifier(for: $0)
        }
    }

    private func setupToolbarAndFooter() {
        var snapshot = Snapshot()
        snapshot.appendSections([.toolbar, .footer])
        snapshot.appendItems([.toolbar], toSection: .toolbar)
        snapshot.appendItems([.footer], toSection: .footer)
        dataSource.apply(snapshot)

        // MARK: Добавление дочерних элементов в элемент секции
        // для демонстрации нативной поддержки древовидных секций
        // с возможностью скрытия/раскрытия
        var sectionSnapshot = dataSource.snapshot(for: .toolbar)
        sectionSnapshot.append(
            [
                .carouselItem(id: 99),
                .listItem(id: 10, salt: 1),
                .carouselItem(id: 98)
            ],
            to: .toolbar
        )
        dataSource.apply(sectionSnapshot, to: .toolbar)
    }

    private func setupAppearance() {
        view.backgroundColor = .systemBackground
        collection.backgroundColor = view.backgroundColor
    }

    private func setupSubscriptions() {
        viewStore.publisher.sampleItems
            .sink { [unowned self] in
                applyItems($0)
            }
            .store(in: &cancellables)

        viewStore.publisher.carouselItems
            .sink { [unowned self] in
                applyCarousel($0)
            }
            .store(in: &cancellables)

        viewStore.publisher.isLoading
            .sink { [unowned self] in
                applyLoader(isLoading: $0)
            }
            .store(in: &cancellables)

        // MARK: Настройка прокрутки к нужному элементу
        viewStore.publisher.scrollPath
            .compactMap { $0 }
            .sink { [unowned self] path in
                scroll(to: path)
            }
            .store(in: &cancellables)
    }

    /// Обработка события прокрутки к элементу
    private func scroll(to path: SampleSystem.State.ScrollPath) {
        switch path {
        case .top:
            let index = IndexPath(row: 0, section: 0)
            collection.scrollToItem(at: index, at: .top, animated: true)
        case let .item(id):
            if let index = dataSource.indexPath(for: .listItem(id: id)) {
                collection.scrollToItem(at: index, at: .top, animated: true)
                viewStore.send(.item(.element(id: id, action: .setCollapsed(false))))
            }
        }
        viewStore.send(.didScroll)
    }

    /// Обработка элементов для секции элементов списка `Section.list`
    private func applyItems(_ items: IdentifiedArrayOf<SampleItemSystem.State>) {
        var snapshot = dataSource.snapshot()
        if !snapshot.sectionIdentifiers.contains(.list) {
            snapshot.insertSections([.list], beforeSection: .footer)
        }
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .list))
        snapshot.appendItems(
            items.map { Item.listItem(id: $0.id) },
            toSection: .list
        )
        dataSource.apply(snapshot)
    }

    /// Обработка элементов для секции элементов карусели `Section.carousel`
    private func applyCarousel(_ items: [Int]) {
        var snapshot = dataSource.snapshot()

        if !snapshot.sectionIdentifiers.contains(.carousel) {
            snapshot.insertSections([.carousel], beforeSection: .list)
        }

        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .carousel))
        if items.isEmpty {
            snapshot.deleteSections([.carousel])
        } else {
            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .carousel))
            snapshot.appendItems(
                items.map { Item.carouselItem(id: $0) },
                toSection: .carousel
            )
        }
        dataSource.apply(snapshot)
    }

    /// Обработка состояния загрузки (добавление/удаление индикатора)
    private func applyLoader(isLoading: Bool) {
        var snapshot = dataSource.snapshot()
        let loaderExists = snapshot.itemIdentifiers.contains(.loader)

        switch (isLoading, loaderExists) {
        case (true, false):
            snapshot.insertItems([.loader], beforeItem: .toolbar)
        case (false, true):
            snapshot.deleteItems([.loader])
        default:
            return
        }

        dataSource.apply(snapshot)
    }
}

// MARK: - UICollectionViewDelegate
extension SampleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard dataSource.sectionIdentifier(for: indexPath.section) == .toolbar else {
            return
        }
        // MARK: Использование нативного скрытия/раскрытия секций
        var sectionSnapshot = dataSource.snapshot(for: .toolbar)
        guard let root = sectionSnapshot.rootItems.first else {
            return
        }
        if sectionSnapshot.isExpanded(root) {
            sectionSnapshot.collapse([.toolbar])
        } else {
            sectionSnapshot.expand([.toolbar])
        }
        dataSource.apply(sectionSnapshot, to: .toolbar)
    }
}

// MARK: - Layout
extension UICollectionViewLayout {
    static func sampleLayout(
        _ sectionProvider: @escaping (Int) -> SampleViewController.Section?
    ) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { index, env in
            // TODO: - Supplementary
            // section.boundarySupplementaryItems
            switch sectionProvider(index) {
            case nil, .list, .toolbar, .footer:
                return NSCollectionLayoutSection.standart()
            case .carousel:
                let section = NSCollectionLayoutSection.standart(
                    height: .estimated(50),
                    width: .estimated(100),
                    isHorizontalGroup: false
                )
                // MARK: Создание секции с горизонтальной прокруткой
                section.orthogonalScrollingBehavior = .continuous
                return section
            }
        }
    }
}
