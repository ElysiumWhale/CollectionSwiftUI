import UIKit

typealias CellRegistration = UICollectionView.CellRegistration
typealias SuppRegistration = UICollectionView.SupplementaryRegistration

extension UICollectionView {
    /// Получение переиспользуемой ячейки по строковому id
    func dequeue(
        id: any RawRepresentable<String>,
        for index: IndexPath
    ) -> UICollectionViewCell {
        dequeueReusableCell(withReuseIdentifier: id.rawValue, for: index)
    }

    /// Получение переиспользуемой ячейки по регистрации
    func dequeue<CellType: UICollectionViewCell, Item: Hashable>(
        _ registration: CellRegistration<CellType, Item>,
        for index: IndexPath,
        item: Item
    ) -> UICollectionViewCell {
        dequeueConfiguredReusableCell(using: registration, for: index, item: item)
    }

    /// Получение переиспользуемой вспомогательной вьюхи по регистрации
    func dequeue<SupplementaryView>(
        _ registration: SupplementaryRegistration<SupplementaryView>,
        for index: IndexPath
    ) -> UICollectionReusableView {
        dequeueConfiguredReusableSupplementary(using: registration, for: index)
    }
}

extension NSCollectionLayoutSection {
    static func standart(
        height: NSCollectionLayoutDimension = .estimated(120),
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        isHorizontalGroup: Bool = true
    ) -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(
            widthDimension: width,
            heightDimension: height
        )

        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = isHorizontalGroup
        ? NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        : NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}
