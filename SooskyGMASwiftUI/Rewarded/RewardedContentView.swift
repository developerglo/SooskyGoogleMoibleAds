import GoogleMobileAds
import SwiftUI

struct RewardedContentView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    var navigationTitle: String = ""
    
    var adViewControllerRepresentableView: some View {
        adViewControllerRepresentable
            .frame(width: .zero, height: .zero)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Button{
                adViewControllerRepresentable.viewController.showPopupConfirmToShowRewardAds("Watch Ads", "Are you sure to watch ads to have coin?")
                adViewControllerRepresentable.viewController.haveReward = {
                    print("[DEBUG] Đóng quảng cáo khi có thưởng")
                }
                adViewControllerRepresentable.viewController.dontHaveReward = {
                    print("[DEBUG] Đóng quảng cáo khi không thưởng")
                }
            } label: {
                Text("ShowAds")
            }
            
            Spacer()
            
            Button{
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Close")
            }
            Spacer()
        }
        .navigationTitle(navigationTitle)
        .background(adViewControllerRepresentableView)
    }
}

// MARK: - Helper to present Rewarded Ad
private struct AdViewControllerRepresentable: UIViewControllerRepresentable {
    let viewController = BaseViewController()
    
    func makeUIViewController(context: Context) -> some BaseViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
