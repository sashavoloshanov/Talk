import Foundation
import Observation

@Observable
final class LikedQuestionsViewModel: BaseViewModel {
    private var allCategories: [Category] = []

    func questions(for store: LikesStore) -> [CardQuestion] {
        let ids = store.likedIds
        var found: [CardQuestion] = []
        for category in allCategories {
            for sub in category.subcategories {
                for q in sub.questions where ids.contains(q.id) {
                    found.append(q)
                }
            }
        }
        return found
    }

    func load(allCategories: [Category]) {
        self.allCategories = allCategories
    }
}
