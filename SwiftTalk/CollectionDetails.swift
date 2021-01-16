import SwiftUI
import TinyNetworking
import Model
import Combine

struct CollectionDetails: View {
  @ObservedObject var image: Resource<UIImage>
  @ObservedObject var store = sharedStore

  let collection: CollectionView
  var episodes: [EpisodeView] {
    store.sharedEpisodes.value?.filter { $0.collection == collection.id } ?? []
  }

  init(collection: CollectionView) {
    self.collection = collection
    self.image = Resource(endpoint: Endpoint(imageURL: collection.artwork.png), shouldDeferLoading: true)
  }

  var body: some View {
    VStack {
      Text(collection.title).font(.largeTitle).lineLimit(nil)

      if image.value != nil {
        Image(uiImage: image.value!).resizable().aspectRatio(contentMode: .fit)
      }

      Text(collection.description).lineLimit(nil)

      AllEpisodes(episodes: episodes)
    }.onAppear() {
      self.image.shouldDeferLoading = false
    }
  }
}

struct CollectionDetails_Previews: PreviewProvider {
  static var previews: some View {
    let data: [CollectionView] = sample(name: "collections")
    CollectionDetails(collection: data[0])
  }
}
