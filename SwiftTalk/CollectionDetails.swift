import SwiftUI
import TinyNetworking
import Model
import Combine

enum ImageError: Error {
  case something
}

extension Endpoint where A == UIImage {
    init(imageURL url: URL) {
        self.init(.get, url: url, expectedStatusCode: expected200to300) { data, _ in
            guard let d = data, let i = UIImage(data: d) else {
              return .failure(ImageError.something)
            }
            return .success(i)
        }
    }
}

struct CollectionDetails: View {
  @ObservedObject var image: Resource<UIImage>
  @ObservedObject var store = sharedStore
  var subs = Set<AnyCancellable>()

  let collection: CollectionView
  var episodes: [EpisodeView] {
    store.sharedEpisodes.value?.filter { $0.collection == collection.id } ?? []
  }

  init(collection: CollectionView) {
    self.collection = collection
    self.image = Resource(endpoint: Endpoint(imageURL: collection.artwork.png))
  }

  var body: some View {
    VStack {
      Text(collection.title).font(.largeTitle).lineLimit(nil)

      if image.value != nil {
        Image(uiImage: image.value!).resizable().aspectRatio(contentMode: .fit)
      }

      Text(collection.description).lineLimit(nil)

      List {
        ForEach(episodes) { episode in
          Text(episode.title)
        }
      }
    }
  }
}

struct CollectionDetails_Previews: PreviewProvider {
  static var previews: some View {
    let data: [CollectionView] = sample(name: "collections")
    CollectionDetails(collection: data[0])
  }
}
