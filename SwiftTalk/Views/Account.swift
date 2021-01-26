import SwiftUI

struct Account: View {
  @ObservedObject var session = Session.shared

  var body: some View {
    Form {
      if session.credentials != nil {
        Button("Log Out", action: {
          session.logOut()
        })
      } else {
        Button(action: {
          getAuthToken() { result in
            switch result {
            case let .failure(e): print(e) // todo
            case let .success(info):
              session.logIn(sessionId: info.sessionId, csrf: info.csrf)
            }
          }
        }) { Text("Log in") }
      }
    }.navigationBarTitle("Account")
  }
}

struct Account_Previews: PreviewProvider {
  static var previews: some View {
    Account()
  }
}
