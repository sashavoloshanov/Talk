import Testing
@testable import Talk

private let testSuite = "com.talk.tests.likes"

@Suite("LikesStore")
@MainActor
struct LikesStoreTests {

    init() {
        UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
        UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
    }

    @Suite("toggle")
    struct Toggle {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func toggleAddsId() {
            let store = LikesStore()
            store.toggle("q1")
            #expect(store.likedIds.contains("q1"))
        }

        @Test @MainActor func toggleTwiceRemovesId() {
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q1")
            #expect(!store.likedIds.contains("q1"))
        }

        @Test @MainActor func toggleMultipleDifferentIds() {
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q2")
            store.toggle("q3")
            #expect(store.likedIds.contains("q1"))
            #expect(store.likedIds.contains("q2"))
            #expect(store.likedIds.contains("q3"))
        }
    }

    @Suite("Персистенція")
    struct Persistence {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func toggleThenReloadContainsId() {
            let store1 = LikesStore()
            store1.toggle("q1")
            let store2 = LikesStore()
            #expect(store2.likedIds.contains("q1"))
        }

        @Test @MainActor func toggleTwiceThenReloadIsEmpty() {
            let store1 = LikesStore()
            store1.toggle("q1")
            store1.toggle("q1")
            let store2 = LikesStore()
            #expect(store2.likedIds.isEmpty)
        }
    }

    @Suite("Початковий стан")
    struct InitialState {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func freshStoreIsEmpty() {
            let store = LikesStore()
            #expect(store.likedIds.isEmpty)
        }
    }
}
