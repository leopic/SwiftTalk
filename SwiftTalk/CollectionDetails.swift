import SwiftUI
import TinyNetworking
import Model

enum ImageError: Error {
  case something
}

struct CollectionDetails: View {
  let collection: CollectionView
  @ObservedObject var image: Resource<UIImage>

  init(collection: CollectionView) {
    self.collection = collection

    let endpoint = Endpoint<UIImage>(.get, url: collection.artwork.png, expectedStatusCode: expected200to300) { data, _ in
      guard let d = data,
            let i = UIImage(data: d) else {
        return .failure(ImageError.something)
      }

      return .success(i)
    }

    self.image = Resource<UIImage>(endpoint: endpoint)
  }

  var body: some View {
    VStack {
      Text(collection.title).font(.largeTitle).lineLimit(nil)

      if image.value != nil {
        Image(uiImage: image.value!).resizable().aspectRatio(contentMode: .fit)
      }

      Text(collection.description).lineLimit(nil)
    }
  }
}

struct CollectionDetails_Previews: PreviewProvider {
  static var previews: some View {
    let data: [CollectionView] = sample(name: "collections")
    CollectionDetails(collection: data[0])
  }
}
