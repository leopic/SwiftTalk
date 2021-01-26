import Foundation
import KeychainItem
import Combine

final class Session: ObservableObject {
  @KeychainItem(account: "sessionId") private var sessionId
  @KeychainItem(account: "csrf") private var csrf

  @Published var credentials: (sessionId: String, csrf: String)? {
    didSet {
      (sessionId, csrf) = (credentials?.sessionId, credentials?.csrf)
    }
  }

  static let shared = Session()

  init() {
    guard let s = sessionId,
          let c = csrf else { return }
    credentials = (sessionId: s, csrf: c)
  }

  func logIn(sessionId s: String, csrf c: String) {
    credentials = (sessionId: s, csrf: c)
  }

  func logOut() -> Void {
    credentials = nil
  }
}
