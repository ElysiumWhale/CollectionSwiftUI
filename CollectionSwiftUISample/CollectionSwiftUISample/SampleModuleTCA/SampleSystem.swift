import ComposableArchitecture
import Foundation

struct SampleSystem: Reducer {
    @ObservableState // без этого макроса scope не работает нормально
    struct State: Equatable {
        enum ScrollPath: Hashable {
            case top
            case item(_ id: Int)
        }

        var isLoading = false
        var scrollPath: ScrollPath?

        var sampleItems: IdentifiedArrayOf<SampleItemSystem.State> = []

        var carouselItems: [Int] = []
        var selectedCarouselItems: Set<Int> = []
    }

    @CasePathable // без этого макроса forEach не работает
    enum Action: Hashable {
        case loadItems
        case loadedItems([Int])
        case removeFirst
        case addFirst
        case item(IdentifiedActionOf<SampleItemSystem>)

        case loadCarousel
        case loadedCarousel([Int])
        case setActiveCarouselItem(Int, Bool)

        case scrollTo(State.ScrollPath)
        case didScroll
    }

    var body: some Reducer<State, Action> {
        Reduce(mainReduce)
            .forEach(\.sampleItems, action: \.item) {
                SampleItemSystem()
            }
    }

    func mainReduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .addFirst:
            let firstId = (state.sampleItems.first?.id ?? 0) - 1
            state.sampleItems.insert(SampleItemSystem.State(id: firstId), at: 0)
            return .none
        case .removeFirst:
            if !state.sampleItems.isEmpty {
                state.sampleItems.remove(at: 0)
            }
            return .none
        case .loadItems:
            state.isLoading = true
            state.sampleItems.removeAll()
            return .run {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                return await $0(.loadedItems(Array(0...19)))
            }
        case let .loadedItems(items):
            state.isLoading = false
            state.sampleItems = IdentifiedArray(
                uniqueElements: items.map { SampleItemSystem.State(id: $0) }
            )
            return .none
        case .loadCarousel:
            state.isLoading = true
            state.carouselItems = []
            // не затираем activatedCarouselItems,
            // чтобы продемонстрировать восстановление состояния по id
            return .run {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                return await $0(.loadedCarousel(Array(0...19)))
            }
        case let .loadedCarousel(items):
            state.isLoading = false
            state.carouselItems = items
            return .none
        case let .setActiveCarouselItem(id, value):
            if value {
                state.selectedCarouselItems.insert(id)
            } else {
                state.selectedCarouselItems.remove(id)
            }
            return .none
        case let .scrollTo(path):
            state.scrollPath = path
            return .none
        case .didScroll:
            state.scrollPath = nil
            return .none
        case .item:
            return .none
        }
    }
}
