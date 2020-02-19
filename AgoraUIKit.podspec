#
#  Be sure to run `pod spec lint AgoraUIKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "AgoraUIKit"
  spec.version      = "0.0.1"
  spec.summary      = "Pre-built UI for video calling with Agora."
  spec.description  = <<-DESC
                    A pre-built, easy to use UI that handles creating, joining, and managing an
                    Agora video call.
                   DESC

  spec.homepage     = "http://agora.io"
  spec.license      = { :type => "MIT" }
  spec.author       = { "Jonathan Fotland" => "jonathan@agora.io" }
  spec.platform     = :ios, "12.0"
  spec.swift_version = "4.0"
  spec.source       = { :git => "https://github.com/zontan/AgoraUIKit.git" }
  spec.source_files = "AgoraUIKit"
  spec.resources    = "AgoraUIKit/*.storyboard", "Resources/*.png"
  spec.dependency     "AgoraRtcEngine_iOS"
  spec.static_framework = true

end
