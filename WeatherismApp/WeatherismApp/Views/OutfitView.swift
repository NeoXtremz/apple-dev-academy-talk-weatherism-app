import SwiftUI

struct OutfitListView: View {
    @ObservedObject var viewModel: OutfitViewModel
    let condition: WeatherCondition

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recommended Outfits")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)

            if viewModel.isLoading {
                ProgressView("Loading outfits...")
                    .foregroundColor(.white)
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.outfits) { outfit in
                            AsyncImage(url: URL(string: outfit.imageUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 150, height: 200)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
