import SwiftUI

/// Ячейка с изменяющейся высотой в завимости от состония
struct CarouselItemCell: View {
    enum Event {
        case press
    }

    let id: Int
    let action: (Event) -> Void

    @Binding
    var isActivated: Bool

    var body: some View {
        VStack {
            Button("CarouselItem \(id)") {
                isActivated = !isActivated
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)

            if isActivated {
                Button("CarouselItem \(id)") {
                    action(.press)
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
            }
        }
        .animation(.linear, value: isActivated)
    }
}

#if DEBUG
#Preview {
    CarouselItemCell(
        id: 1,
        action: { print($0) },
        isActivated: .constant(false)
    )
}
#endif
