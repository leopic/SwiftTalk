import SwiftUI
import Model
import TinyNetworking

struct PlayingState {
  var isPlaying = false {
    didSet {
      if isPlaying {
        startedPlaying = true
      }
    }
  }

  var startedPlaying = false
}

struct EpisodeViewView: View {
  let episode: EpisodeView
  @State var playingState = PlayingState()
  @ObservedObject var image: Resource<UIImage>

  var overlay: AnyView? {
    guard let image = image.value,
          !playingState.startedPlaying else {
      return nil
    }

    return AnyView(Image(uiImage: image).resizable().aspectRatio(contentMode: .fit))
  }

  init(episode: EpisodeView) {
    self.episode = episode
    self.image = Resource(endpoint: Endpoint(imageURL: episode.poster_url))
  }

  var body: some View {
    VStack(alignment: .leading) {
      Text(episode.title)
        .font(.largeTitle)
        .fontWeight(.bold)
      Text(episode.synopsis)
        .lineLimit(nil)
      HStack(alignment: .center) {
        Spacer()
        Player(
          url: episode.preview_url!,
          overlay: overlay,
          isPlaying: $playingState.isPlaying
        )
          .aspectRatio(16/9, contentMode: .fit)
        Spacer()
      }
    }
  }
}

struct EpisodeViewView_Previews: PreviewProvider {
  static var previews: some View {
    let episodes: [EpisodeView] = sample(name: "all-episodes")
    EpisodeViewView(episode: episodes.first!)
  }
}
