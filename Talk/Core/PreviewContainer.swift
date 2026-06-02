#if DEBUG
import SwiftUI

struct PreviewContainer<Content: View>: View {
    @State private var questionHolder = QuestionClientHolder()
    @State private var languageClient: LanguageClient
    @State private var themeClient: ThemeClient
    @State private var premiumClient = PremiumClient()
    @State private var coordinator = AppCoordinator()
    @State private var likesStore = LikesStore()

    private let scheme: ColorScheme
    let content: () -> Content

    init(
        scheme: ColorScheme = .dark,
        language: AppLanguage = .ukrainian,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.scheme = scheme
        self.content = content

        let lc = LanguageClient()
        lc.setLanguage(language)
        _languageClient = State(initialValue: lc)

        let tc = ThemeClient()
        tc.setTheme(scheme == .dark ? .dark : .light)
        _themeClient = State(initialValue: tc)
    }

    var body: some View {
        content()
            .environment(languageClient)
            .environment(\.languageBundle, languageClient.bundle)
            .environment(themeClient)
            .environment(premiumClient)
            .environment(coordinator)
            .environment(questionHolder)
            .environment(likesStore)
            .preferredColorScheme(scheme)
    }
}
#endif
