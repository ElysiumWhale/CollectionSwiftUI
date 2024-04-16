import UIKit

typealias Registration<Cell: UICollectionViewCell, Item> = UICollectionView.CellRegistration<Cell, Item>

extension UICollectionView {
    func dequeue(
        id: any RawRepresentable<String>,
        for index: IndexPath
    ) -> UICollectionViewCell {
        dequeueReusableCell(withReuseIdentifier: id.rawValue, for: index)
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
