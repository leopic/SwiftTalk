import SwiftUI
import Model
import ViewHelpers

struct CollectionsList: View {
  let collections: [CollectionView]

    var body: some View {
      List {
        ForEach(collections) { col in
          NavigationLink(
            destination: CollectionDetails(collection: col)) {
            VStack(alignment: .leading) {
              Text(col.title)
              Text("\(col.episodes_count) episodes - \(TimeInterval(col.total_duration).hoursAndMinutes)")
                .font(.caption)
                .foregroundColor(.gray)
            }
          }
        }
      }.navigationTitle("Collections")
    }
}

struct CollectionsList_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView {
        CollectionsList(collections: sample(name: "collections"))
      }
    }
}
