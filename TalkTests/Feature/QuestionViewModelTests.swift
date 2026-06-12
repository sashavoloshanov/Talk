import Testing
import Foundation
@testable import Talk

private func makeQuestions(_ count: Int) -> [CardQuestion] {
    (0..<count).map { .fixture(id: "q\($0)", text: "Q\($0)") }
}

private func makeQVMDefaults() -> (UserDefaults, String) {
    let suite = "com.talk.tests.qvm.\(UUID().uuidString)"
    return (UserDefaults(suiteName: suite)!, suite)
}

@Suite("QuestionViewModel", .serialized)
@MainActor
struct QuestionViewModelTests {

    @Suite("init")
    struct Init {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeQVMDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func defaultInitStartsAt0() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.currentIndex == 0)
            #expect(vm.isStateLoaded == false)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func forceStartIndex2() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 2)
            #expect(vm.currentIndex == 2)
            #expect(vm.isStateLoaded == true)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func forceStartIndexClampsToCountMinus1() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub", forceStartIndex: 10)
            #expect(vm.currentIndex == 2)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func emptyQuestionsCurrentIsNil() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: [], subcategoryId: "sub")
            #expect(vm.currentIndex == 0)
            #expect(vm.current == nil)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("Computed properties")
    struct ComputedProperties {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeQVMDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func canGoNextTrueInMiddle() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.canGoNext == true)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func canGoNextFalseAtLast() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(1), subcategoryId: "sub")
            #expect(vm.canGoNext == false)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func canGoPreviousTrueInMiddle() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub", forceStartIndex: 1)
            #expect(vm.canGoPrevious == true)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func canGoPreviousFalseAtFirst() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.canGoPrevious == false)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func progressString() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.progress == "1 / 3")
            vm.next()
            #expect(vm.progress == "2 / 3")
            vm.next()
            #expect(vm.progress == "3 / 3")
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func progressValueCalculation() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(4), subcategoryId: "sub")
            #expect(vm.progressValue == 1.0 / 4.0)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func progressValueEmptyQuestionsIsZero() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: [], subcategoryId: "sub")
            #expect(vm.progressValue == 0)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func isCurrentLiked() {
            UserDefaultsClient.defaults = defaults
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.isCurrentLiked(in: store) == false)
            store.toggle("q0")
            #expect(vm.isCurrentLiked(in: store) == true)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("next()")
    struct Next {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeQVMDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func nextIncrementsIndex() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            vm.next()
            #expect(vm.currentIndex == 1)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func nextWritesProgressToDefaults() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            vm.next()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 2)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func nextDoesNotExceedBounds() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(1), subcategoryId: "sub")
            vm.next()
            #expect(vm.currentIndex == 0)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("previous()")
    struct Previous {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeQVMDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func previousDecrementsIndex() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub", forceStartIndex: 2)
            vm.previous()
            #expect(vm.currentIndex == 1)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func previousDoesNotGoBelowZero() {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            vm.previous()
            #expect(vm.currentIndex == 0)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("loadState()")
    struct LoadState {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeQVMDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func loadStateRestoresSavedIndex() async {
            UserDefaultsClient.defaults = defaults
            UserDefaultsClient.set(["sub": 2], for: .subcategoryProgress)
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.currentIndex == 2)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func loadStateClampsSavedIndex() async {
            UserDefaultsClient.defaults = defaults
            UserDefaultsClient.set(["sub": 100], for: .subcategoryProgress)
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.currentIndex == 2)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func loadStateDefaultsToZeroWhenNoRecord() async {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.currentIndex == 0)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func loadStateSetsIsStateLoaded() async {
            UserDefaultsClient.defaults = defaults
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.isStateLoaded == true)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func secondLoadStateIsIgnored() async {
            UserDefaultsClient.defaults = defaults
            UserDefaultsClient.set(["sub": 2], for: .subcategoryProgress)
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub")
            await vm.loadState()
            UserDefaultsClient.set(["sub": 4], for: .subcategoryProgress)
            await vm.loadState()
            #expect(vm.currentIndex == 2)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }

    @Suite("incrementProgressCount")
    struct IncrementProgress {
        let defaults: UserDefaults
        let suite: String

        init() {
            (defaults, suite) = makeQVMDefaults()
            UserDefaultsClient.defaults = defaults
        }

        @Test @MainActor func existing0CurrentIndex2Writes3() {
            UserDefaultsClient.defaults = defaults
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 2)
            vm.toggleLike(in: store)
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 3)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func existing5CurrentIndex2Stays5() {
            UserDefaultsClient.defaults = defaults
            UserDefaultsClient.set(["sub": 5], for: .subcategoryProgress)
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 2)
            vm.toggleLike(in: store)
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 5)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }

        @Test @MainActor func existing2CurrentIndex4Writes5() {
            UserDefaultsClient.defaults = defaults
            UserDefaultsClient.set(["sub": 2], for: .subcategoryProgress)
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 4)
            vm.toggleLike(in: store)
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 5)
            UserDefaults.standard.removePersistentDomain(forName: suite)
        }
    }
}
