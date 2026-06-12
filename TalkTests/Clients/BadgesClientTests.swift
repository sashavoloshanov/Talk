import Testing
@testable import Talk

@Suite("BadgesClient")
struct BadgesClientTests {

    private let subcategoryId = "couple"
    private var category: Category {
        .fixture(id: "cat1", subcategories: [.fixture(id: subcategoryId)])
    }

    @Suite("earned / locked за прогресом")
    struct EarnedLocked {
        let subId = "couple"
        let category: Category = .fixture(id: "cat1", subcategories: [.fixture(id: "couple")])

        private func badges(progress: Int) -> [Badge] {
            BadgesClient.badges(for: [category], progress: [subId: progress])["cat1"] ?? []
        }

        @Test func progress0AllLocked() {
            let result = badges(progress: 0)
            #expect(result.filter { !$0.isEarned }.count == 3)
            #expect(result.filter { $0.isEarned }.count == 0)
        }

        @Test func progress9AllLocked() {
            let result = badges(progress: 9)
            #expect(result.filter { !$0.isEarned }.count == 3)
        }

        @Test func progress10OneEarned() {
            let result = badges(progress: 10)
            #expect(result.filter { $0.isEarned }.count == 1)
            #expect(result.filter { !$0.isEarned }.count == 2)
        }

        @Test func progress29OneEarned() {
            let result = badges(progress: 29)
            #expect(result.filter { $0.isEarned }.count == 1)
            #expect(result.filter { !$0.isEarned }.count == 2)
        }

        @Test func progress30TwoEarned() {
            let result = badges(progress: 30)
            #expect(result.filter { $0.isEarned }.count == 2)
            #expect(result.filter { !$0.isEarned }.count == 1)
        }

        @Test func progress50AllEarned() {
            let result = badges(progress: 50)
            #expect(result.filter { $0.isEarned }.count == 3)
        }

        @Test func progress99AllEarned() {
            let result = badges(progress: 99)
            #expect(result.filter { $0.isEarned }.count == 3)
        }
    }

    @Suite("imageName")
    struct ImageName {
        let subId = "couple"
        let category: Category = .fixture(id: "cat1", subcategories: [.fixture(id: "couple")])

        @Test func earnedImageName() {
            let badges = BadgesClient.badges(for: [category], progress: [subId: 10])["cat1"] ?? []
            let earned = badges.first(where: { $0.isEarned })
            #expect(earned?.imageName == "badge_couple_10")
        }

        @Test func lockedImageName() {
            let badges = BadgesClient.badges(for: [category], progress: [subId: 0])["cat1"] ?? []
            #expect(badges.allSatisfy { $0.imageName == "lockedBadgeIcon" })
        }
    }

    @Suite("badge.id")
    struct BadgeId {
        let subId = "couple"
        let category: Category = .fixture(id: "cat1", subcategories: [.fixture(id: "couple")])

        @Test func badgeIdsMatchFormat() {
            let badges = BadgesClient.badges(for: [category], progress: [:])["cat1"] ?? []
            let ids = badges.map { $0.id }
            #expect(ids.contains("couple_10"))
            #expect(ids.contains("couple_30"))
            #expect(ids.contains("couple_50"))
        }
    }

    @Suite("Структура результату")
    struct ResultStructure {
        @Test func emptyCategoriesReturnsEmptyDict() {
            let result = BadgesClient.badges(for: [], progress: [:])
            #expect(result.isEmpty)
        }

        @Test func oneCategoryOneSubcategoryHas3Badges() {
            let cat = Category.fixture(id: "cat1", subcategories: [.fixture(id: "sub1")])
            let result = BadgesClient.badges(for: [cat], progress: [:])
            #expect(result["cat1"]?.count == 3)
        }

        @Test func oneCategoryTwoSubcategoriesHas6Badges() {
            let cat = Category.fixture(id: "cat1", subcategories: [.fixture(id: "sub1"), .fixture(id: "sub2")])
            let result = BadgesClient.badges(for: [cat], progress: [:])
            #expect(result["cat1"]?.count == 6)
        }

        @Test func threeCategoriesHave3Keys() {
            let cats = [
                Category.fixture(id: "cat1"),
                Category.fixture(id: "cat2"),
                Category.fixture(id: "cat3")
            ]
            let result = BadgesClient.badges(for: cats, progress: [:])
            #expect(result.keys.count == 3)
        }
    }
}
