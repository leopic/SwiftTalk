import Foundation
import TinyNetworking
import Combine

final class Resource<A>: ObservableObject {
  @Published var value: A?

  private var endpoint: Endpoint<A>

  init(endpoint: Endpoint<A>) {
    self.endpoint = endpoint
    load()
  }

  private func load() -> Void {
    URLSession.shared.load(endpoint) { result in
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
        self.value = try? result.get()
      })
    }
  }
}
