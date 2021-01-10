import SwiftUI
import Combine
import TinyNetworking
import Model
import ViewHelpers

struct ContentView: View {
  @ObservedObject var collections = Resource(endpoint: allCollections)

    var body: some View {
      Group {
        if collections.value == nil {
          Text("Loading ...")
        } else {
          NavigationView {
            CollectionsList(collections: collections.value!)
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
