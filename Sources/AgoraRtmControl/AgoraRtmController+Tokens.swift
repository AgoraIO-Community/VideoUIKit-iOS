//
//  AgoraRtmController+Tokens.swift
//  
//
//  Created by Max Cobb on 29/07/2021.
//

import Foundation

extension AgoraRtmController {

    /// Error types to expect from fetchToken on failing ot retrieve valid token.
    public enum TokenError: Error {
        /// No data returned from the token request
        case noData
        /// Data corrupted or in the wrong format
        case invalidData
        /// URL could not be created
        case invalidURL
    }

    /// Requests the token from our backend token service
    /// - Parameter urlBase: base URL specifying where the token server is located
    /// - Parameter channelName: Name of the channel we're requesting for
    /// - Parameter userId: User ID of the user trying to join (0 for any user)
    /// - Parameter callback: Callback method for returning either the string token or error
    public static func fetchRtmToken(
        urlBase: String, userId: String,
        callback: @escaping (Result<String, Error>) -> Void
    ) {
        guard let fullURL = URL(string: "\(urlBase)/rtm/\(userId)") else {
            callback(.failure(TokenError.invalidURL))
            return
        }
        var request = URLRequest(
            url: fullURL,
            timeoutInterval: 10
        )
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, _, err in
            guard let data = data else {
                if let err = err {
                    callback(.failure(err))
                } else {
                    callback(.failure(TokenError.noData))
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseDict = responseJSON as? [String: Any],
               let token = responseDict["rtmToken"] as? String {
                callback(.success(token))
            } else {
                callback(.failure(TokenError.invalidData))
            }
        }

        task.resume()
    }

    func newTokenFetched(result: Result<String, Error>) {
        switch result {
        case .success(let token):
            self.updateToken(token)
        case .failure(let err):
            AgoraRtmController.agoraPrint(.error, message: "Could not fetch rtm token: \(err)")
        }
    }

    func updateToken(_ token: String) {
        self.rtmKit.renewToken(token) { _, renewStatus in
            switch renewStatus {
            case .ok:
                AgoraRtmController.agoraPrint(.verbose, message: "token renewal success")
            case .failure, .invalidArgument, .rejected, .tooOften,
                 .tokenExpired, .invalidToken,
                 .notInitialized, .notLoggedIn:
                AgoraRtmController.agoraPrint(
                    .error,
                    message: "cannot renew token: \(renewStatus): \(renewStatus.rawValue)"
                )
            @unknown default:
                AgoraRtmController.agoraPrint(
                    .error,
                    message: "cannot renew token (unknown): \(renewStatus): \(renewStatus.rawValue)"
                )
           }
        }
    }
}
