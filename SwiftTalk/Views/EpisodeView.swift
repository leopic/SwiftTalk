import SwiftUI
import Model
import Combine
import TinyNetworking

struct EpisodeItemView: View {
  let episode: EpisodeView
  @ObservedObject var image: Resource<UIImage>

  var length: String {
    "Length: \(TimeInterval(episode.media_duration).hoursAndMinutes)"
  }

  init(_ episode: EpisodeView) {
    self.episode = episode
    self.image = Resource(endpoint: Endpoint(imageURL: episode.poster_url), shouldDeferLoading: true)
  }

  var body: some View {
    HStack {
      if image.value != nil {
        Image(uiImage: image.value!)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 150)
      }

      VStack(alignment: .leading, spacing: 2.0) {
        Text(episode.title).font(.headline)
        Text(length)
          .font(.subheadline)
          .foregroundColor(.gray)
      }
    }.onAppear() {
      self.image.shouldDeferLoading = false
    }
  }
}

struct EpisodeItemView_Previews: PreviewProvider {
  static var previews: some View {
    let allEpisodes: [EpisodeView] = sample(name: "all-episodes")
    EpisodeItemView(allEpisodes[0])
  }
}
