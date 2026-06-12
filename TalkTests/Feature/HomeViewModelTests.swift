import Testing
@testable import Talk

private let testSuite = "com.talk.tests.home"

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    init() {
        UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
        UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
    }

    @Suite("isLocked")
    struct IsLocked {
        let vm = HomeViewModel()

        @Test func premiumSubNotPremiumUser_isLocked() {
            let sub = Subcategory.fixture(isPremium: true)
            #expect(vm.isLocked(sub, isPremium: false) == true)
        }

        @Test func premiumSubPremiumUser_notLocked() {
            let sub = Subcategory.fixture(isPremium: true)
            #expect(vm.isLocked(sub, isPremium: true) == false)
        }

        @Test func freeSubNotPremiumUser_notLocked() {
            let sub = Subcategory.fixture(isPremium: false)
            #expect(vm.isLocked(sub, isPremium: false) == false)
        }

        @Test func freeSubPremiumUser_notLocked() {
            let sub = Subcategory.fixture(isPremium: false)
            #expect(vm.isLocked(sub, isPremium: true) == false)
        }
    }

    @Suite("hasLikedQuestions")
    struct HasLiked {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func emptyStoreReturnsFalse() {
            let vm = HomeViewModel()
            let store = LikesStore()
            #expect(vm.hasLikedQuestions(store) == false)
        }

        @Test @MainActor func afterToggleReturnsTrue() {
            let vm = HomeViewModel()
            let store = LikesStore()
            store.toggle("q1")
            #expect(vm.hasLikedQuestions(store) == true)
        }

        @Test @MainActor func afterDoubleToggleReturnsFalse() {
            let vm = HomeViewModel()
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q1")
            #expect(vm.hasLikedQuestions(store) == false)
        }
    }

    @Suite("loadContent")
    struct LoadContent {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func successClearsErrorMessage() async {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = HomeViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            #expect(vm.errorMessage == nil)
        }

        @Test @MainActor func throwingSetsErrorMessage() async {
            let mock = MockQuestionClient()
            await mock.setThrow(true)
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = HomeViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            #expect(vm.errorMessage != nil)
        }
    }

    @Suite("reloadContent")
    struct ReloadContent {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func reloadResetsLoadedLanguage() async {
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = HomeViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            await vm.reloadContent(holder: holder, language: .english, premiumClient: premium)
            let count = await mock.loadCategoriesCallCount
            #expect(count == 2)
        }
    }
}

extension MockQuestionClient {
    func setThrow(_ value: Bool) {
        shouldThrow = value
    }
}
