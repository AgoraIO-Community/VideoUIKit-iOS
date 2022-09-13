#
# Be sure to run `pod lib lint AgoraUIKit_macOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraUIKit_macOS'
  s.module_name      = 'AgoraUIKit'
  s.version          = ENV['LIB_VERSION'] || '1.8.4'
  s.summary          = 'Agora video session AppKit template.'

  s.description      = <<-DESC
Use this Pod to create a video AppKit view that can be easily added to your macOS application.
                       DESC

  s.homepage         = 'https://github.com/AgoraIO-Community/VideoUIKit-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Max Cobb' => 'max@agora.io' }
  s.source           = { :git => 'https://github.com/AgoraIO-Community/VideoUIKit-iOS.git', :tag => s.version.to_s }

  s.macos.deployment_target = '10.15'
  s.swift_versions = ['5.0']

  s.static_framework = true
  s.source_files = 'Sources/Agora-UIKit/*'
  s.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES' }
  s.dependency 'AgoraRtcEngine_macOS/RtcBasic', '~> 3.7.0'
  s.default_subspec = 'UIKitFull'

  s.subspec 'UIKitBasic' do |cs|
  end
  s.subspec 'UIKitFull' do |cs|
    cs.dependency 'AgoraRtmControl_macOS', "#{s.version.to_s}"
  end
end
