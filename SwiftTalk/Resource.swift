import Foundation
import TinyNetworking
import Combine

final class Resource<A>: ObservableObject {
  @Published var value: A?
  
  var shouldDeferLoading: Bool {
    didSet {
      guard !shouldDeferLoading else { return }
      load()
    }
  }

  private var endpoint: Endpoint<A>

  init(endpoint: Endpoint<A>, shouldDeferLoading: Bool = false) {
    self.endpoint = endpoint
    self.shouldDeferLoading = shouldDeferLoading

    guard !shouldDeferLoading else { return }
    load()
  }

  private func load() -> Void {
    URLSession.shared.load(endpoint) { result in
      DispatchQueue.main.async {
        self.value = try? result.get()
      }
    }
  }
}
