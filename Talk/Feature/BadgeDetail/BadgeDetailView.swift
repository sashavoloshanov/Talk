import SwiftUI

struct BadgeDetailView: View {
    @Environment(AppCoordinator.self) private var coordinator
    let badge: Badge

    @State private var shareImage: UIImage?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.white.opacity(0.4)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture { coordinator.dismissCover() }

            VStack {
                Spacer()

                RemoteBadgeImage(imageName: badge.imageName)
                    .padding(32)

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture { coordinator.dismissCover() }

            if let shareImage {
                ShareLink(
                    item: Image(uiImage: shareImage),
                    preview: SharePreview(badge.name, image: Image(uiImage: shareImage))
                ) {
                    ZStack {
                        Circle()
                            .frame(width: 44, height: 44)
                            .foregroundColor(Colors.textPrimary)

                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Colors.backgroundSecondary)
                            .offset(y: -1)
                    }
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
            }
        }
        .task {
            shareImage = try? await BadgeImageClient.shared.image(named: badge.imageName)
        }
    }
}
