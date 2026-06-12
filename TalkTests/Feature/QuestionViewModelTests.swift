import Testing
@testable import Talk

private let testSuite = "com.talk.tests.qvm"

private func makeQuestions(_ count: Int) -> [CardQuestion] {
    (0..<count).map { .fixture(id: "q\($0)", text: "Q\($0)") }
}

@Suite("QuestionViewModel")
@MainActor
struct QuestionViewModelTests {

    init() {
        UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
        UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
    }

    @Suite("init")
    struct Init {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func defaultInitStartsAt0() {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.currentIndex == 0)
            #expect(vm.isStateLoaded == false)
        }

        @Test @MainActor func forceStartIndex2() {
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 2)
            #expect(vm.currentIndex == 2)
            #expect(vm.isStateLoaded == true)
        }

        @Test @MainActor func forceStartIndexClampsToCountMinus1() {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub", forceStartIndex: 10)
            #expect(vm.currentIndex == 2)
        }

        @Test @MainActor func emptyQuestionsCurrentIsNil() {
            let vm = QuestionViewModel(questions: [], subcategoryId: "sub")
            #expect(vm.currentIndex == 0)
            #expect(vm.current == nil)
        }
    }

    @Suite("Computed properties")
    struct ComputedProperties {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func canGoNextTrueInMiddle() {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.canGoNext == true)
        }

        @Test @MainActor func canGoNextFalseAtLast() {
            let vm = QuestionViewModel(questions: makeQuestions(1), subcategoryId: "sub")
            #expect(vm.canGoNext == false)
        }

        @Test @MainActor func canGoPreviousTrueInMiddle() {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub", forceStartIndex: 1)
            #expect(vm.canGoPrevious == true)
        }

        @Test @MainActor func canGoPreviousFalseAtFirst() {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.canGoPrevious == false)
        }

        @Test @MainActor func progressString() {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.progress == "1 / 3")
            vm.next()
            #expect(vm.progress == "2 / 3")
            vm.next()
            #expect(vm.progress == "3 / 3")
        }

        @Test @MainActor func progressValueCalculation() {
            let vm = QuestionViewModel(questions: makeQuestions(4), subcategoryId: "sub")
            #expect(vm.progressValue == 1.0 / 4.0)
        }

        @Test @MainActor func progressValueEmptyQuestionsIsZero() {
            let vm = QuestionViewModel(questions: [], subcategoryId: "sub")
            #expect(vm.progressValue == 0)
        }

        @Test @MainActor func isCurrentLiked() {
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.isCurrentLiked(in: store) == false)
            store.toggle("q0")
            #expect(vm.isCurrentLiked(in: store) == true)
        }
    }

    @Suite("next()")
    struct Next {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func nextIncrementsIndex() {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            vm.next()
            #expect(vm.currentIndex == 1)
        }

        @Test @MainActor func nextWritesProgressToDefaults() {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            vm.next()
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 2)
        }

        @Test @MainActor func nextDoesNotExceedBounds() {
            let vm = QuestionViewModel(questions: makeQuestions(1), subcategoryId: "sub")
            vm.next()
            #expect(vm.currentIndex == 0)
        }
    }

    @Suite("previous()")
    struct Previous {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func previousDecrementsIndex() {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub", forceStartIndex: 2)
            vm.previous()
            #expect(vm.currentIndex == 1)
        }

        @Test @MainActor func previousDoesNotGoBelowZero() {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            vm.previous()
            #expect(vm.currentIndex == 0)
        }
    }

    @Suite("loadState()")
    struct LoadState {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func loadStateRestoresSavedIndex() async {
            UserDefaultsClient.set(["sub": 2], for: .subcategoryProgress)
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.currentIndex == 2)
        }

        @Test @MainActor func loadStateClampsSavedIndex() async {
            UserDefaultsClient.set(["sub": 100], for: .subcategoryProgress)
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.currentIndex == 2)
        }

        @Test @MainActor func loadStateDefaultsToZeroWhenNoRecord() async {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.currentIndex == 0)
        }

        @Test @MainActor func loadStateSetsIsStateLoaded() async {
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.isStateLoaded == true)
        }

        @Test @MainActor func secondLoadStateIsIgnored() async {
            UserDefaultsClient.set(["sub": 2], for: .subcategoryProgress)
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub")
            await vm.loadState()
            UserDefaultsClient.set(["sub": 4], for: .subcategoryProgress)
            await vm.loadState()
            #expect(vm.currentIndex == 2)
        }
    }

    @Suite("incrementProgressCount")
    struct IncrementProgress {
        init() {
            UserDefaultsClient.defaults = UserDefaults(suiteName: testSuite)!
            UserDefaultsClient.defaults.removePersistentDomain(forName: testSuite)
        }

        @Test @MainActor func existing0CurrentIndex2Writes3() {
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 2)
            vm.toggleLike(in: store)
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 3)
        }

        @Test @MainActor func existing5CurrentIndex2Stays5() {
            UserDefaultsClient.set(["sub": 5], for: .subcategoryProgress)
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 2)
            vm.toggleLike(in: store)
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 5)
        }

        @Test @MainActor func existing2CurrentIndex4Writes5() {
            UserDefaultsClient.set(["sub": 2], for: .subcategoryProgress)
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 4)
            vm.toggleLike(in: store)
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 5)
        }
    }
}
