#
# Be sure to run `pod lib lint AgoraUIKit_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraUIKit_iOS'
  s.version          = '4.0.0-preview.1'
  s.summary          = 'Agora video session UIKit template.'

  s.description      = <<-DESC
Use this Pod to create a video UIKit view that can be easily added to your iOS application.
                       DESC

  s.homepage         = 'https://github.com/AgoraIO-Community/iOS-UIKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Max Cobb' => 'max@agora.io' }
  s.source           = { :git => 'https://github.com/AgoraIO-Community/iOS-UIKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.0']

  s.source_files = 'Sources/Agora-UIKit/*'
  s.dependency 'AgoraFFmpegPlayer_iOS_Preview', '~> 4.0.0'
  s.dependency 'AgoraRtm_iOS', '~> 1.4.8'

  s.static_framework = true
end
