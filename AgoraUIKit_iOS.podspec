#
# Be sure to run `pod lib lint AgoraUIKit_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraUIKit_iOS'
  s.module_name      = 'AgoraUIKit'
  s.version          = ENV['LIB_VERSION'] || '4.0.0'
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

  s.static_framework = true
  s.source_files = 'Sources/Agora-Video-UIKit/*'
  s.dependency 'AgoraRtcEngine_iOS', '4.0.0.4'
  s.dependency 'AgoraRtmControl_iOS', "#{s.version.to_s}"

end
