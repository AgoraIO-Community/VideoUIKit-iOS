//
//  AgoraVideoViewer+Token.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import Foundation

extension AgoraVideoViewer {

    /// Error types to expect from fetchToken on failing ot retrieve valid token.
    public enum TokenError: Error {
        case noData
        case invalidData
        case invalidURL
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
            if let responseDict = responseJSON as? [String: Any], let token = responseDict["token"] as? String {
                callback(.success(token))
            } else {
                callback(.failure(TokenError.invalidData))
            }
        }

        task.resume()
    }

}
