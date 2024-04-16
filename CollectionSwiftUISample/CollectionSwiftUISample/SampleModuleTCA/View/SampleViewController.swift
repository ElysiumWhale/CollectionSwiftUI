import UIKit
import ComposableArchitecture
import Combine

final class SampleViewController: UIViewController {
    private let collection = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    private let store: StoreOf<SampleSystem>

    let viewStore: ViewStoreOf<SampleSystem>

    private var cancellables = Set<AnyCancellable>()

    private lazy var dataSource = makeDataSource(
        collection: collection,
        storeProvider: { [weak self] id in
            self?.store.scope(state: \.sampleItems[id:id], action: \.item[id:id])
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

        viewStore.publisher.scrollPath
            .compactMap { $0 }
            .sink { [unowned self] in
                switch $0 {
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
            .store(in: &cancellables)
    }

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

    private func applyCarousel(_ items: [Int]) {
        var snapshot = dataSource.snapshot()
        if !snapshot.sectionIdentifiers.contains(.carousel) {
            snapshot.insertSections([.carousel], beforeSection: .list)
        }
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .carousel))
        snapshot.appendItems(
            items.map { Item.carouselItem(id: $0) },
            toSection: .carousel
        )
        dataSource.apply(snapshot)
    }

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

extension UICollectionViewLayout {
    static func sampleLayout(
        _ provider: @escaping (Int) -> SampleViewController.Section?
    ) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { index, env in
            // TODO: - Supplementary
            // section.boundarySupplementaryItems
            switch provider(index) {
            case nil, .list, .toolbar, .footer:
                return NSCollectionLayoutSection.standart()
            case .carousel:
                let section = NSCollectionLayoutSection.standart(
                    height: .estimated(50),
                    width: .estimated(100),
                    isHorizontalGroup: false
                )
                section.orthogonalScrollingBehavior = .continuous
                return section
            }
        }
    }
}