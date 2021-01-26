import SwiftUI
import Combine

struct ContentView: View {
  @ObservedObject var store = sharedStore
  var subs = Set<AnyCancellable>()

  init() {
    store.stream.sink { _ in }.store(in: &subs) // Have to kick-off the subscription
  }

  var body: some View {
    Group {
      if sharedStore.isLoading {
        Text("Loading...")
      } else {
        TabView {
          NavigationView {
            CollectionsList(collections: store.sharedCollections.value!)
          }.tabItem { Text("Collections") }.tag(0)
          NavigationView {
            AllEpisodes(episodes: store.sharedEpisodes.value!)
          }.tabItem { Text("Episodes") }.tag(1)
          NavigationView {
            Account()
          }.tabItem({ Text("Account") }).tag(2)
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
