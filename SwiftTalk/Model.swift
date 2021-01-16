import Foundation
import SwiftUI
import TinyNetworking
import Combine
import Model

extension CollectionView: Identifiable {}
extension EpisodeView: Identifiable {
  public var id: Int { number }
}

let allCollections = Endpoint<[CollectionView]>(json: .get, url: URL(string: "https://talk.objc.io/collections.json")!)
let allEpisodes = Endpoint<[EpisodeView]>(json: .get, url: URL(string: "https://talk.objc.io/episodes.json")!)

final class Store: ObservableObject {
  var sharedCollections = Resource(endpoint: allCollections)
  var sharedEpisodes = Resource(endpoint: allEpisodes)
  private var collections: AnyPublisher<[CollectionView], Never>
  private var episodes: AnyPublisher<[EpisodeView], Never>
  @Published var stream: AnyPublisher<([CollectionView], [EpisodeView]), Never>!
  @Published var isLoading = false

  init() {
    collections = sharedCollections.$value.compactMap { $0 }.eraseToAnyPublisher()
    episodes = sharedEpisodes.$value.compactMap { $0 }.eraseToAnyPublisher()
    isLoading = true
    stream = collections.zip(episodes).handleEvents(receiveOutput: { [weak self] _ in
      self?.isLoading = false // this is cheating...
    }).eraseToAnyPublisher()
  }
}

let sharedStore = Store()

func sample<T: Codable>(name: String) -> T {
  let url = Bundle.main.url(forResource: name, withExtension: "json")!
  let data = try! Data(contentsOf: url)
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .secondsSince1970
  return try! decoder.decode(T.self, from: data)
}

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
