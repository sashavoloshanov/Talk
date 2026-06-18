import Testing
import Foundation
@testable import Talk

@Suite("DocumentItem", .serialized)
@MainActor
struct DocumentItemTests {

    @Suite("fileName")
    @MainActor
    struct FileName {
        @Test func privacyPolicy_ukrainian() {
            #expect(DocumentItem.privacyPolicy.fileName(.ukrainian) == "privacy_policy_ua")
        }

        @Test func privacyPolicy_english() {
            #expect(DocumentItem.privacyPolicy.fileName(.english) == "privacy_policy_en")
        }

        @Test func termsOfService_ukrainian() {
            #expect(DocumentItem.termsOfService.fileName(.ukrainian) == "terms_of_use_ua")
        }

        @Test func termsOfService_english() {
            #expect(DocumentItem.termsOfService.fileName(.english) == "terms_of_use_en")
        }

        @Test func support_ukrainian() {
            #expect(DocumentItem.support.fileName(.ukrainian) == "support_ua")
        }

        @Test func support_english() {
            #expect(DocumentItem.support.fileName(.english) == "support_en")
        }
    }

    @Suite("localURL")
    @MainActor
    struct LocalURL {
        @Test func privacyPolicy_english_returnsURL() {
            let url = DocumentItem.privacyPolicy.localURL(.english)
            #expect(url != nil)
            #expect(url?.lastPathComponent == "privacy_policy_en.html")
        }

        @Test func privacyPolicy_ukrainian_returnsURL() {
            let url = DocumentItem.privacyPolicy.localURL(.ukrainian)
            #expect(url != nil)
            #expect(url?.lastPathComponent == "privacy_policy_ua.html")
        }

        @Test func termsOfService_english_returnsURL() {
            let url = DocumentItem.termsOfService.localURL(.english)
            #expect(url != nil)
            #expect(url?.lastPathComponent == "terms_of_use_en.html")
        }

        @Test func termsOfService_ukrainian_returnsURL() {
            let url = DocumentItem.termsOfService.localURL(.ukrainian)
            #expect(url != nil)
            #expect(url?.lastPathComponent == "terms_of_use_ua.html")
        }

        @Test func support_english_returnsURL() {
            let url = DocumentItem.support.localURL(.english)
            #expect(url != nil)
            #expect(url?.lastPathComponent == "support_en.html")
        }

        @Test func support_ukrainian_returnsURL() {
            let url = DocumentItem.support.localURL(.ukrainian)
            #expect(url != nil)
            #expect(url?.lastPathComponent == "support_ua.html")
        }
    }

    @Suite("Hashable")
    @MainActor
    struct HashableConformance {
        @Test func sameCasesAreEqual() {
            #expect(DocumentItem.privacyPolicy == DocumentItem.privacyPolicy)
            #expect(DocumentItem.termsOfService == DocumentItem.termsOfService)
            #expect(DocumentItem.support == DocumentItem.support)
        }

        @Test func differentCasesAreNotEqual() {
            #expect(DocumentItem.privacyPolicy != DocumentItem.termsOfService)
            #expect(DocumentItem.privacyPolicy != DocumentItem.support)
            #expect(DocumentItem.termsOfService != DocumentItem.support)
        }
    }
}
