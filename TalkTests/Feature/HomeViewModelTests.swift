import Testing
import Foundation
@testable import Talk

private func makeHomeDefaults() -> (UserDefaults, String) {
    let suite = "com.talk.tests.home.\(UUID().uuidString)"
    return (UserDefaults(suiteName: suite)!, suite)
}

@Suite("HomeViewModel", .serialized)
@MainActor
struct HomeViewModelTests {

    @Suite("isLocked")
    struct IsLocked {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeHomeDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func premiumSubNotPremiumUser_isLocked() {
            UserDefaultsClient.defaults = defaults
            let vm = HomeViewModel()
            let sub = Subcategory.fixture(isPremium: true)
            #expect(vm.isLocked(sub, isPremium: false) == true)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func premiumSubPremiumUser_notLocked() {
            UserDefaultsClient.defaults = defaults
            let vm = HomeViewModel()
            let sub = Subcategory.fixture(isPremium: true)
            #expect(vm.isLocked(sub, isPremium: true) == false)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func freeSubNotPremiumUser_notLocked() {
            UserDefaultsClient.defaults = defaults
            let vm = HomeViewModel()
            let sub = Subcategory.fixture(isPremium: false)
            #expect(vm.isLocked(sub, isPremium: false) == false)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func freeSubPremiumUser_notLocked() {
            UserDefaultsClient.defaults = defaults
            let vm = HomeViewModel()
            let sub = Subcategory.fixture(isPremium: false)
            #expect(vm.isLocked(sub, isPremium: true) == false)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("hasLikedQuestions")
    struct HasLiked {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeHomeDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func emptyStoreReturnsFalse() {
            UserDefaultsClient.defaults = defaults
            let vm = HomeViewModel()
            let store = LikesStore()
            #expect(vm.hasLikedQuestions(store) == false)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func afterToggleReturnsTrue() {
            UserDefaultsClient.defaults = defaults
            let vm = HomeViewModel()
            let store = LikesStore()
            store.toggle("q1")
            #expect(vm.hasLikedQuestions(store) == true)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func afterDoubleToggleReturnsFalse() {
            UserDefaultsClient.defaults = defaults
            let vm = HomeViewModel()
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q1")
            #expect(vm.hasLikedQuestions(store) == false)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("loadContent")
    struct LoadContent {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeHomeDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func successClearsErrorMessage() async {
            UserDefaultsClient.defaults = defaults
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = HomeViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            #expect(vm.errorMessage == nil)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func throwingSetsErrorMessage() async {
            UserDefaultsClient.defaults = defaults
            let mock = MockQuestionClient()
            await mock.setThrow(true)
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = HomeViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            #expect(vm.errorMessage != nil)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("reloadContent")
    struct ReloadContent {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeHomeDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func reloadResetsLoadedLanguage() async {
            UserDefaultsClient.defaults = defaults
            let mock = MockQuestionClient()
            let holder = QuestionClientHolder(client: mock)
            let premium = PremiumClient()
            let vm = HomeViewModel()
            await vm.loadContent(holder: holder, language: .english, premiumClient: premium)
            await vm.reloadContent(holder: holder, language: .english, premiumClient: premium)
            let count = await mock.loadCategoriesCallCount
            #expect(count == 2)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }
}

extension MockQuestionClient {
    func setThrow(_ value: Bool) {
        shouldThrow = value
    }
}
