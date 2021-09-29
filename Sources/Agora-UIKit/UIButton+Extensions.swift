//
//  MPButton+Extensions.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension MPButton {
    /// Create a custom UI/NSButton made up of one or two SF Symbol images to alternate between
    /// - Parameters:
    ///   - unselected: SF Symbol present by default, when button has not yet been selected
    ///   - selected: SF Symbol to be displayed after the button is selected
    /// - Returns: A new MPButton of type `.custom` which will alternate between the given SF Symbols on selecting
    static func newToggleButton(unselected: String, selected: String? = nil) -> MPButton {
        #if os(iOS)
        let button = MPButton(type: .custom)
        #elseif os(macOS)
        let button = MPButton()
        button.wantsLayer = true
        #endif
        if let selected = selected {
            #if os(iOS)
            button.setImage(MPImage(
                systemName: selected,
                withConfiguration: MPImage.SymbolConfiguration(scale: AgoraSettings.buttonIconScale)
            ), for: .selected)
            #elseif os(macOS)
            button.alternateTitle = selected
            #endif
        }
        #if os(iOS)
        button.setImage(MPImage(
            systemName: unselected,
            withConfiguration: MPImage.SymbolConfiguration(scale: AgoraSettings.buttonIconScale)
        ), for: .normal)
        #elseif os(macOS)
        button.title = unselected
        button.font = .systemFont(ofSize: AgoraSettings.buttonIconSize)
        #endif
        return button
    }

    #if os(iOS)
    /// SF Symbol name for camera icon for builtin button
    public static var videoSymbol = "camera.fill"
    /// SF Symbol name for camera alt icon for builtin button
    public static var muteVideoSelectedSymbol: String?
    /// SF Symbol name for microphone icon for builtin button
    public static var micSymbol = "mic"
    /// SF Symbol name for microphone alt icon for builtin button
    public static var muteMicSelectedSymbol: String? = "mic.slash"
    /// SF Symbol name for microphone muted flag
    public static var micSlashSymbol = "mic.slash"
    /// SF Symbol name for option request on iOS
    public static var ellipsisSymbol = "ellipsis.circle"
    /// SF Symbol name for flip camera builtin button
    public static var cameraRotateSymbol = "camera.rotate"
    /// SF Symbol name for beautify buitlin button
    public static var wandSymbol = "wand.and.stars.inverse"
    /// SF Symbol name to appear behind user with camera off
    public static var personSymbol = "person.circle"
    /// SF Symbol name for sharing screen builtin button
    public static var screenShareSymbol = "rectangle.on.rectangle"
    /// SF Symbol name for pin icon
    public static var pinSymbol = "pin.fill"
    internal var isOn: Bool {
        get { self.isSelected }
        set { self.isSelected = newValue }
    }
    #elseif os(macOS)
    /// SF Symbol name for camera icon for builtin button
    static var videoSymbol = "􀌟"
    /// SF Symbol name for camera alt icon for builtin button
    static var muteVideoSelectedSymbol: String?
    /// SF Symbol name for microphone icon for builtin button
    static var micSymbol = "􀊰"
    /// SF Symbol for microphone alt icon for builtin button
    static var muteMicSelectedSymbol: String? = "􀊲"
    /// SF Symbol for microphone muted flag
    static var micSlashSymbol = "􀊲"
    /// SF Symbol for flip camera builtin button
    static var cameraRotateSymbol = "􀌢"
    /// SF Symbol for beautify buitlin button
    static var wandSymbol = "􀜎"
    /// SF Symbol to appear behind user with camera off
    static var personSymbol = "􀓣"
    /// SF Symbol for sharing screen builtin button
    static var screenShareSymbol = "􀏧"
    /// SF Symbol for pin icon
    static var pinSymbol = "􀎧"
    var isOn: Bool {
        get { return self.state == .on }
        set { self.state = newValue ? .on : .off }
    }
    #endif
    static var muteCameraString = "mute camera"
    static var muteMicString = "mute microphone"
    static var unmuteCameraString = "unmute camera"
    static var unmuteMicString = "unmute microphone"
}
