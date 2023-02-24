//
//  AgoraVideoViewer+PrecallPreview.swift
//  
//
//  Created by Max Cobb on 25/04/2022.
//

import AgoraRtcKit

extension AgoraVideoViewer {
    func startPrecall(callback: @escaping (Bool) -> Void) {
        guard self.checkPermissions(mediaType: .video, alsoRequest: true, callback: { permissionErr in
            if let permissionErr = permissionErr {
                AgoraVideoViewer.agoraPrint(.warning, message: "Could not get camera permission\n" +
                                            "Code: \(permissionErr.localizedDescription)")
                return callback(false)
            }
            callback(true)
        }) else {
            return
        }
        self.addLocalVideo()
    }
}
