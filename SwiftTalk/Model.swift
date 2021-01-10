import Foundation
import SwiftUI
import TinyNetworking
import Model

extension CollectionView: Identifiable {}

let allCollections = Endpoint<[CollectionView]>(json: .get, url: URL(string: "https://talk.objc.io/collections.json")!)


func sample<T: Codable>(name: String) -> T {
  let url = Bundle.main.url(forResource: name, withExtension: "json")!
  let data = try! Data(contentsOf: url)
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .secondsSince1970
  return try! decoder.decode(T.self, from: data)
}

