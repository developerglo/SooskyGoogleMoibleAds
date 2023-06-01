import GoogleMobileAds
import SwiftUI

var countFullAdsSoosky : Int = 0

struct InterstitialContentView: View {
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
                adViewControllerRepresentable.viewController.showFull()
                adViewControllerRepresentable.viewController.turnOffAdsFull = {
                    print("[DEBUG] Đóng quảng cáo full")
                }
            } label: {
                Text("ShowAds")
            }
            
            Spacer()
            
            Text("Đếm tương tác các nút để show ads full")
              .font(.title2)
            
            Spacer()
            Group{
                Button{
                    //Tương tác 3 lần đầu tiên hiển thị quảng cáo full, sau đó tương tác 5 lần mới hiển thị quảng cáo và lặp lại
                    adViewControllerRepresentable.viewController.countAdsToShowVC(3, 5, &countTimerShowAds)
                    adViewControllerRepresentable.viewController.turnOffAdsFull = {
                        print("[DEBUG] Đóng quảng cáo full")
                    }
                } label: {
                    Text("Count To Show Ads Full")
                }
                
                Spacer()
                
                Button{
                    //Tương tác 3 lần đầu tiên hiển thị quảng cáo full, sau đó tương tác 5 lần mới hiển thị quảng cáo và lặp lại
                    adViewControllerRepresentable.viewController.countAdsToShowVC(3, 5, &countTimerShowAds)
                    adViewControllerRepresentable.viewController.turnOffAdsFull = {
                        print("[DEBUG] Đóng quảng cáo full")
                    }
                } label: {
                    Text("Count To Show Ads Full")
                }
                
                Spacer()
                
                Button{
                    //Tương tác 3 lần đầu tiên hiển thị quảng cáo full, sau đó tương tác 5 lần mới hiển thị quảng cáo và lặp lại
                    adViewControllerRepresentable.viewController.countAdsToShowVC(3, 5, &countTimerShowAds)
                    adViewControllerRepresentable.viewController.turnOffAdsFull = {
                        print("[DEBUG] Đóng quảng cáo full")
                    }
                } label: {
                    Text("Count To Show Ads Full")
                }
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

struct InterstitialContentView_Previews: PreviewProvider {
    static var previews: some View {
        InterstitialContentView(navigationTitle: "Interstitial")
    }
}

// MARK: - Helper to present Interstitial Ad
private struct AdViewControllerRepresentable: UIViewControllerRepresentable {
    let viewController = BaseViewController()
    
    func makeUIViewController(context: Context) -> some BaseViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
