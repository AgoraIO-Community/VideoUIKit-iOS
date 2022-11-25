//
//  AgoraCameraSourcePush.swift
//  Agora-UIKit-Example
//
//  Created by Max Cobb on 22/09/2022.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import AVFoundation
import AgoraRtcKit

#if os(iOS)
internal extension UIDeviceOrientation {
    func toCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return .portrait
        }
    }
    var intRotation: Int {
        switch self {
        case .portrait: return 90
        case .landscapeLeft: return 0
        case .landscapeRight: return 180
        case .portraitUpsideDown: return -90
        default: return 90
        }
    }
}
#endif

/// View to show the custom camera feed for the local camera feed.
open class CustomVideoSourcePreview: MPView {
    /// Layer that displays video from a camera device.
    open private(set) var previewLayer: AVCaptureVideoPreviewLayer?

    /// Add new frame to the preview layer
    /// - Parameter previewLayer: New `previewLayer` to be displayed on the preview.
    open func insertCaptureVideoPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer?.removeFromSuperlayer()
        #if os(macOS)
        guard let layer = layer else { return }
        #endif
        previewLayer.frame = bounds
        layer.insertSublayer(previewLayer, below: layer.sublayers?.first)
        self.previewLayer = previewLayer
    }

    #if os(iOS)
    /// Tells the delegate a layer's bounds have changed.
    /// - Parameter layer: The layer that requires layout of its sublayers.
    override open func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        previewLayer?.frame = bounds
        if let connection = self.previewLayer?.connection {
            let currentDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection: AVCaptureConnection = connection

            if previewLayerConnection.isVideoOrientationSupported {
                self.updatePreviewLayer(
                    layer: previewLayerConnection,
                    orientation: orientation.toCaptureVideoOrientation()
                )
            }
        }
    }
    #elseif os(macOS)
    open override func layout() {
        super.layout()
        self.previewLayer?.frame = bounds
    }
    #endif

    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        self.previewLayer?.frame = self.bounds
    }

    #if os(macOS)
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    #endif
}

/// Delegate for capturing the frames from the camera source.
public protocol AgoraCameraSourcePushDelegate: AnyObject {
    func myVideoCapture(
        _ capture: AgoraCameraSourcePush, didOutputSampleBuffer pixelBuffer: CVPixelBuffer,
        rotation: Int, timeStamp: CMTime
    )
}

open class AgoraCameraSourcePush: NSObject {
    fileprivate var delegate: AgoraCameraSourcePushDelegate?
    private var localVideoPreview: CustomVideoSourcePreview?

    /// Active capture session
    public let captureSession: AVCaptureSession
    /// DispatchQueue for processing and sending images from ``captureSession``
    public let captureQueue: DispatchQueue
    /// Latest output from the active ``captureSession``.
    public var currentOutput: AVCaptureVideoDataOutput? {
        if let outputs = self.captureSession.outputs as? [AVCaptureVideoDataOutput] {
            return outputs.first
        } else {
            return nil
        }
    }

    /// Create a new AgoraCameraSourcePush object
    /// - Parameters:
    ///   - delegate: Camera source delegate, where the pixel buffer is sent to.
    ///   - localVideoPreview: Local view where the camera feed is rendered to.
    public init(
        delegate: AgoraCameraSourcePushDelegate,
        localVideoPreview: CustomVideoSourcePreview?
    ) {
        self.delegate = delegate
        self.localVideoPreview = localVideoPreview

        self.captureSession = AVCaptureSession()
        #if os(iOS)
        self.captureSession.usesApplicationAudioSession = false
        #endif

        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        if self.captureSession.canAddOutput(captureOutput) {
            self.captureSession.addOutput(captureOutput)
        }

        self.captureQueue = DispatchQueue(label: "AgoraCaptureQueue")

        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        localVideoPreview?.insertCaptureVideoPreviewLayer(previewLayer: previewLayer)
    }

    /// Update the local preview layer to a new one.
    /// - Parameter videoPreview: New custom preview layer.
    open func updateVideoPreview(to videoPreview: CustomVideoSourcePreview) {
        self.localVideoPreview?.previewLayer?.removeFromSuperlayer()

        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        videoPreview.insertCaptureVideoPreviewLayer(previewLayer: previewLayer)
        self.localVideoPreview = videoPreview
    }

    deinit {
        self.captureSession.stopRunning()
    }

    func changeCaptureDevice(to device: AVCaptureDevice) {
        self.startCapture(ofDevice: device)
    }

    /// Start caturing frames from the device. Usually internally called.
    /// - Parameter device: Capture device to have images captured from.
    open func startCapture(ofDevice device: AVCaptureDevice) {
        guard let currentOutput = self.currentOutput else {
            return
        }

        currentOutput.setSampleBufferDelegate(self, queue: self.captureQueue)

        captureQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.setCaptureDevice(device, ofSession: strongSelf.captureSession)
            strongSelf.captureSession.beginConfiguration()
            if strongSelf.captureSession.canSetSessionPreset(.vga640x480) {
                strongSelf.captureSession.sessionPreset = .vga640x480
            }
            strongSelf.captureSession.commitConfiguration()
            strongSelf.captureSession.startRunning()
        }
    }

    func resumeCapture() {
        self.currentOutput?.setSampleBufferDelegate(self, queue: self.captureQueue)
        self.captureQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func stopCapture() {
        self.currentOutput?.setSampleBufferDelegate(nil, queue: nil)
        self.captureQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

}

public extension AgoraCameraSourcePush {
    func setCaptureDevice(_ device: AVCaptureDevice, ofSession captureSession: AVCaptureSession) {
        let currentInputs = captureSession.inputs as? [AVCaptureDeviceInput]
        let currentInput = currentInputs?.first

        if let currentInputName = currentInput?.device.localizedName,
            currentInputName == device.uniqueID {
            return
        }

        guard let newInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        captureSession.beginConfiguration()
        if let currentInput = currentInput {
            captureSession.removeInput(currentInput)
        }
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
        }
        captureSession.commitConfiguration()
    }
}

extension AgoraCameraSourcePush: AVCaptureVideoDataOutputSampleBufferDelegate {
    open func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        DispatchQueue.main.async {[weak self] in
            guard let weakSelf = self else { return }

            #if os(iOS)
            let imgRot = UIDevice.current.orientation.intRotation
            #else
            let imgRot = 0
            #endif
            weakSelf.delegate?.myVideoCapture(
                weakSelf, didOutputSampleBuffer: pixelBuffer,
                rotation: imgRot, timeStamp: time
            )
        }
    }
}
