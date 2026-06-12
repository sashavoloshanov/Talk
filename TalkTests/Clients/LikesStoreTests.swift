import Testing
import Foundation
@testable import Talk

private func makeLikesDefaults() -> (UserDefaults, String) {
    let suite = "com.talk.tests.likes.\(UUID().uuidString)"
    return (UserDefaults(suiteName: suite)!, suite)
}

@Suite("LikesStore", .serialized)
@MainActor
struct LikesStoreTests {

    @Suite("toggle")
    struct Toggle {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeLikesDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func toggleAddsId() {
            UserDefaultsClient.defaults = defaults
            let store = LikesStore()
            store.toggle("q1")
            #expect(store.likedIds.contains("q1"))
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func toggleTwiceRemovesId() {
            UserDefaultsClient.defaults = defaults
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q1")
            #expect(!store.likedIds.contains("q1"))
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func toggleMultipleDifferentIds() {
            UserDefaultsClient.defaults = defaults
            let store = LikesStore()
            store.toggle("q1")
            store.toggle("q2")
            store.toggle("q3")
            #expect(store.likedIds.contains("q1"))
            #expect(store.likedIds.contains("q2"))
            #expect(store.likedIds.contains("q3"))
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("Персистенція")
    struct Persistence {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeLikesDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func toggleThenReloadContainsId() {
            UserDefaultsClient.defaults = defaults
            let store1 = LikesStore()
            store1.toggle("q1")
            let store2 = LikesStore()
            #expect(store2.likedIds.contains("q1"))
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func toggleTwiceThenReloadIsEmpty() {
            UserDefaultsClient.defaults = defaults
            let store1 = LikesStore()
            store1.toggle("q1")
            store1.toggle("q1")
            let store2 = LikesStore()
            #expect(store2.likedIds.isEmpty)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("Початковий стан")
    struct InitialState {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeLikesDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func freshStoreIsEmpty() {
            UserDefaultsClient.defaults = defaults
            let store = LikesStore()
            #expect(store.likedIds.isEmpty)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }
}
