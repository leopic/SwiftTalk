//
//  AuthenticationHelpers.swift
//  SwiftTalk
//
//  Created by Chris Eidhof on 18.07.19.
//  Copyright © 2019 Chris Eidhof. All rights reserved.
//
import Foundation
import UIKit
import AuthenticationServices

fileprivate var p: Provider? = nil
fileprivate var authSession: ASWebAuthenticationSession?

extension URLComponents {
  subscript(query name: String) -> String? {
    return queryItems?.first(where: { $0.name == name })?.value
  }
}

// Thanks to https://www.andyibanez.com/posts/using-aswebauthenticationaession-swiftui/
class Provider: NSObject, ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    ASPresentationAnchor()
  }
}

enum AuthenticationError: Error {
  case unknownError
  case authenticationError(Error)
  case parsingError
}

func getAuthToken(onComplete: @escaping (Result<(sessionId: String, csrf: String), AuthenticationError>) -> ()) {
  p = Provider()
  let callbackUrlScheme = "swifttalk"
  let authURL = URL(string: "https://talk.objc.io/users/auth/github?origin=/authorize_app")!

  //Initialize auth session
  authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackUrlScheme) { (callback: URL?, error: Error?) in
    if let e = error {
      onComplete(.failure(.authenticationError(e)))
      return
    }
    guard let successURL = callback else {
      onComplete(.failure(.unknownError))
      return
    }

    guard let components = URLComponents(url: successURL, resolvingAgainstBaseURL: false),
          let id = components[query: "session_id"], let csrf = components[query: "csrf"] else {
      onComplete(.failure(.parsingError))
      return
    }

    onComplete(.success((id, csrf)))
  }
  authSession?.presentationContextProvider = p
  authSession!.start()
}
