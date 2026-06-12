import Foundation
@testable import Talk

extension CardQuestion {
    static func fixture(id: String = "q1", text: String = "Question?") -> CardQuestion {
        CardQuestion(id: id, text: text)
    }
}

extension Subcategory {
    static func fixture(
        id: String = "sub1",
        emoji: String = "💬",
        name: String = "Sub",
        description: String = "Desc",
        isPremium: Bool = false,
        questions: [CardQuestion] = [.fixture()]
    ) -> Subcategory {
        Subcategory(id: id, emoji: emoji, name: name, description: description, isPremium: isPremium, questions: questions)
    }
}

extension Category {
    static func fixture(
        id: String = "cat1",
        name: String = "Category",
        emoji: String = "🗂",
        subcategories: [Subcategory] = [.fixture()]
    ) -> Category {
        Category(id: id, name: name, emoji: emoji, subcategories: subcategories)
    }
}
