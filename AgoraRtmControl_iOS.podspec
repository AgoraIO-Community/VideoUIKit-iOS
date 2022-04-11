#
# Be sure to run `pod lib lint AgoraRtmControl_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraRtmControl_iOS'
  s.module_name      = 'AgoraRtmControl'
  s.version          = ENV['LIB_VERSION'] || '1.8.0-rc.3'
  s.summary          = 'Agora Real-time Messaging Wrapper.'

  s.description      = <<-DESC
Use this Pod to interact with Agora Real-time messaging SDK with additional properties and commands,
to make the usage simpler with the AgoraRtmController class.
                       DESC

  s.homepage         = 'https://github.com/AgoraIO-Community/iOS-UIKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Max Cobb' => 'max@agora.io' }
  s.source           = { :git => 'https://github.com/AgoraIO-Community/iOS-UIKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_versions = ['5.0']

  s.static_framework = true
  s.source_files = 'Sources/AgoraRtmControl/*'
  s.dependency 'AgoraRtm_iOS', '~> 1.4.10'
end
