#
# Be sure to run `pod lib lint Agora-UIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraUIKit_macOS'
  s.version          = '1.0.3'
  s.summary          = 'Agora video session AppKit template.'

  s.description      = <<-DESC
Use this Pod to create a video AppKit view that can be easily added to your macOS application.
                       DESC

  s.homepage         = 'https://github.com/AgoraIO-Community/iOS-UIKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Max Cobb' => 'max@agora.io' }
  s.source           = { :git => 'https://github.com/AgoraIO-Community/iOS-UIKit.git', :tag => s.version.to_s }

  s.macos.deployment_target = '10.14'
  s.swift_versions = ['5.0']

  s.source_files = 'Sources/Agora-UIKit/*'
  s.dependency 'AgoraRtcEngine_macOS', '~> 3.0'
  
  s.static_framework = true
end
