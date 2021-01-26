import SwiftUI
import Model
import TinyNetworking
import Combine

final class EpisodeProgress: ObservableObject {
  @Published var progress: TimeInterval

  let episode: EpisodeView

  private var subs = Set<AnyCancellable>()

  init(episode: EpisodeView, progress: TimeInterval) {
    self.episode = episode
    self.progress = progress

    self.$progress
      .throttle(for: 2.5, scheduler: RunLoop.main, latest: true)
      .removeDuplicates()
      .sink(receiveValue: { time in
        print("_ got new time: \(time)")
      }).store(in: &subs)
  }
}

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
  @ObservedObject var progress: EpisodeProgress
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
    self.progress = EpisodeProgress(episode: episode, progress: TimeInterval(0))
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
          isPlaying: $playingState.isPlaying,
          playPosition: $progress.progress
        ).aspectRatio(16/9, contentMode: .fit)
        Spacer()
      }
      Slider(value: $progress.progress, in: 0...TimeInterval(15))
    }
  }
}

struct EpisodeViewView_Previews: PreviewProvider {
  static var previews: some View {
    let episodes: [EpisodeView] = sample(name: "all-episodes")
    EpisodeViewView(episode: episodes.first!)
  }
}
