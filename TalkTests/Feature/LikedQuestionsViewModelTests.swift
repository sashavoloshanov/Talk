import Testing
@testable import Talk

private let testSuite = "com.talk.tests.liked"

@Suite("LikedQuestionsViewModel")
@MainActor
struct LikedQuestionsViewModelTests {

    init() {
        UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
        UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
    }

    @Suite("questions(for:) до load")
    struct BeforeLoad {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func emptyStoreReturnsEmpty() {
            let vm = LikedQuestionsViewModel()
            let store = LikesStore()
            #expect(vm.questions(for: store).isEmpty)
        }

        @Test @MainActor func emptyCategories_returnsEmptyEvenWithLikedIds() {
            let vm = LikedQuestionsViewModel()
            let store = LikesStore()
            store.toggle("q1")
            #expect(vm.questions(for: store).isEmpty)
        }
    }

    @Suite("questions(for:) після load")
    struct AfterLoad {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func returnsOnlyLikedQuestions() {
            let q1 = CardQuestion.fixture(id: "q1")
            let q2 = CardQuestion.fixture(id: "q2")
            let cat = Category.fixture(subcategories: [.fixture(questions: [q1, q2])])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat])
            let store = LikesStore()
            store.toggle("q1")
            let result = vm.questions(for: store)
            #expect(result.count == 1)
            #expect(result[0].id == "q1")
        }

        @Test @MainActor func questionsFromMultipleSubcategories() {
            let q1 = CardQuestion.fixture(id: "q1")
            let q2 = CardQuestion.fixture(id: "q2")
            let cat = Category.fixture(subcategories: [
                .fixture(id: "sub1", questions: [q1]),
                .fixture(id: "sub2", questions: [q2])
            ])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat])
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q2")
            #expect(vm.questions(for: store).count == 2)
        }

        @Test @MainActor func questionsFromMultipleCategories() {
            let q1 = CardQuestion.fixture(id: "q1")
            let q2 = CardQuestion.fixture(id: "q2")
            let cat1 = Category.fixture(id: "cat1", subcategories: [.fixture(id: "sub1", questions: [q1])])
            let cat2 = Category.fixture(id: "cat2", subcategories: [.fixture(id: "sub2", questions: [q2])])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat1, cat2])
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q2")
            #expect(vm.questions(for: store).count == 2)
        }

        @Test @MainActor func orderFollowsCategoriesSubcategoriesQuestions() {
            let q1 = CardQuestion.fixture(id: "q1")
            let q2 = CardQuestion.fixture(id: "q2")
            let q3 = CardQuestion.fixture(id: "q3")
            let cat = Category.fixture(subcategories: [
                .fixture(id: "sub1", questions: [q1, q2]),
                .fixture(id: "sub2", questions: [q3])
            ])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat])
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q2")
            store.toggle("q3")
            let result = vm.questions(for: store)
            #expect(result.map(\.id) == ["q1", "q2", "q3"])
        }

        @Test @MainActor func unknownIdDoesNotAppear() {
            let q1 = CardQuestion.fixture(id: "q1")
            let cat = Category.fixture(subcategories: [.fixture(questions: [q1])])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat])
            let store = LikesStore()
            store.toggle("unknown_id")
            #expect(vm.questions(for: store).isEmpty)
        }
    }

    @Suite("load(allCategories:)")
    struct Load {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func afterLoadReturnsData() {
            let q1 = CardQuestion.fixture(id: "q1")
            let cat = Category.fixture(subcategories: [.fixture(questions: [q1])])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat])
            let store = LikesStore()
            store.toggle("q1")
            #expect(vm.questions(for: store).count == 1)
        }

        @Test @MainActor func reloadReplacesCategories() {
            let q1 = CardQuestion.fixture(id: "q1")
            let q2 = CardQuestion.fixture(id: "q2")
            let cat1 = Category.fixture(id: "cat1", subcategories: [.fixture(questions: [q1])])
            let cat2 = Category.fixture(id: "cat2", subcategories: [.fixture(questions: [q2])])
            let vm = LikedQuestionsViewModel()
            vm.load(allCategories: [cat1])
            vm.load(allCategories: [cat2])
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q2")
            let result = vm.questions(for: store)
            #expect(result.count == 1)
            #expect(result[0].id == "q2")
        }
    }
}
