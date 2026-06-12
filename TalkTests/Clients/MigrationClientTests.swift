import Testing
import Foundation
@testable import Talk

@Suite("MigrationClient", .serialized)
struct MigrationClientTests {
    let suite: String

    init() {
        suite = "com.talk.tests.migration.\(UUID().uuidString)"
        UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
    }

    @Suite("Guard / idempotency")
    struct Idempotency {
        let suite: String

        init() {
            suite = "com.talk.tests.migration.\(UUID().uuidString)"
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
        }

        @Test func afterRunIfNeededFlagIsSet() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            MigrationClient.runIfNeeded()
            let flag = UserDefaultsClient.get(Bool.self, for: .didMigrateFromStorageClient)
            #expect(flag == true)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test func secondRunIfNeededDoesNotMigrate() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            UserDefaultsClient.defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            UserDefaultsClient.defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let favoritesStillPresent = UserDefaultsClient.defaults.stringArray(forKey: "favorites")
            #expect(favoritesStillPresent != nil)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("migrateLikedQuestions")
    struct MigrateLiked {
        let suite: String

        init() {
            suite = "com.talk.tests.migration.\(UUID().uuidString)"
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
        }

        @Test func migratesFavoritesToLikedQuestions() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            UserDefaultsClient.defaults.set(["q1", "q2"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
            #expect(liked.contains("q1"))
            #expect(liked.contains("q2"))
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test func emptyFavoritesLeavesLikedUnchanged() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            UserDefaultsClient.defaults.set([String](), forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions)
            #expect(liked == nil || liked!.isEmpty)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test func mergesWithExistingLikedQuestions() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            UserDefaultsClient.set(["q2"], for: .likedQuestions)
            UserDefaultsClient.defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
            #expect(liked.contains("q1"))
            #expect(liked.contains("q2"))
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test func mergedResultHasNoDuplicates() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            UserDefaultsClient.set(["q1"], for: .likedQuestions)
            UserDefaultsClient.defaults.set(["q1", "q2"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            let liked = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
            #expect(liked.count == Set(liked).count)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test func favoritesKeyRemovedAfterMigration() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            UserDefaultsClient.defaults.set(["q1"], forKey: "favorites")
            MigrationClient.runIfNeeded()
            #expect(UserDefaultsClient.defaults.stringArray(forKey: "favorites") == nil)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("migrateSubcategoryProgress")
    struct MigrateProgress {
        let suite: String

        init() {
            suite = "com.talk.tests.migration.\(UUID().uuidString)"
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
        }

        @Test func migratesLegacyIndexToSubcategoryProgress() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            UserDefaultsClient.defaults.set(5, forKey: "lastQuestionIndex_couple")
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["couple"] == 5)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test func legacyKeyRemovedAfterMigration() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            UserDefaultsClient.defaults.set(5, forKey: "lastQuestionIndex_couple")
            MigrationClient.runIfNeeded()
            #expect(UserDefaultsClient.defaults.object(forKey: "lastQuestionIndex_couple") == nil)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test func existingProgressNotOverwritten() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            UserDefaultsClient.set(["couple": 10], for: .subcategoryProgress)
            UserDefaultsClient.defaults.set(5, forKey: "lastQuestionIndex_couple")
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["couple"] == 10)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test func multipleLegacyKeysMigratedAtOnce() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            UserDefaultsClient.defaults.set(3, forKey: "lastQuestionIndex_couple")
            UserDefaultsClient.defaults.set(7, forKey: "lastQuestionIndex_family")
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["couple"] == 3)
            #expect(progress?["family"] == 7)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test func noLegacyKeysLeavesProgressAbsent() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: suite)!
            MigrationClient.runIfNeeded()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress == nil || progress!.isEmpty)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }
}
