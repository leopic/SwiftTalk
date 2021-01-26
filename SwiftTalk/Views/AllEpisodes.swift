import SwiftUI
import Model

struct AllEpisodes: View {
  let episodes: [EpisodeView]

  var body: some View {
    List {
      ForEach(episodes.filter { $0.preview_url != nil }) { episode in
        NavigationLink(destination: EpisodeViewView(episode: episode)) {
          EpisodeItemView(episode)
        }
      }
    }.navigationTitle("All Episodes")
  }
}

struct AllEpisodes_Previews: PreviewProvider {
  static var previews: some View {
    AllEpisodes(episodes: sample(name: "all-episodes"))
  }
}
