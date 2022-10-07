//
//  AgoraVideoViewer+Token.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import Foundation

extension AgoraVideoViewer {

    /// Error types to expect from fetchToken on failing ot retrieve valid token.
    public enum TokenError: Error {
        /// No data returned from the token request
        case noData
        /// Data corrupted or in the wrong format
        case invalidData
        /// URL could not be created
        case invalidURL
    }

    /// Update the token currently in use by the Agora SDK. Used to not interrupt an active video session.
    /// - Parameter newToken: new token to be applied to the current connection.
    @objc open func updateToken(_ newToken: String) {
        self.currentRtcToken = newToken
        self.agkit.renewToken(newToken)
    }

    /// Requests the token from our backend token service
    /// - Parameter urlBase: base URL specifying where the token server is located
    /// - Parameter channelName: Name of the channel we're requesting for
    /// - Parameter userId: User ID of the user trying to join (0 for any user)
    /// - Parameter callback: Callback method for returning either the string token or error
    public static func fetchToken(
        urlBase: String, channelName: String, userId: UInt,
        callback: @escaping (Result<String, Error>) -> Void
    ) {
        guard let fullURL = URL(string: "\(urlBase)/rtc/\(channelName)/publisher/uid/\(userId)/") else {
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
            if let responseDict = responseJSON as? [String: Any], let token = responseDict["rtcToken"] as? String {
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
            AgoraVideoViewer.agoraPrint(.error, message: "Could not fetch token from server: \(err)")
        }
    }
}
