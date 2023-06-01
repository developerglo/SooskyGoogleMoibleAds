import SwiftUI

struct MenuView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isPresentedFull : Bool = false
    @State var isPresentedReward : Bool = false
  private let items: [MenuItem] = [
    .banner,
    .interstitial,
    .rewarded,
    .rewardedInterstitial,
  ]

  var body: some View {
      HStack(alignment: .top) {
          Button{
              isPresentedFull.toggle()
          } label: {
              Text("Full Ads")
          }.fullScreenCover(isPresented: $isPresentedFull, content: InterstitialContentView.init)
          
          Button{
              isPresentedReward.toggle()
          } label: {
              Text("Reward Ads")
          }.fullScreenCover(isPresented: $isPresentedReward, content: RewardedContentView.init)
      }
      
    NavigationView {
      List(items) { item in
        NavigationLink(destination: item.contentView) {
          Text(item.rawValue)
        }
      }
      .navigationTitle("Menu")
    }
  }
}

struct MenuView_Previews: PreviewProvider {
  static var previews: some View {
    MenuView()
  }
}
