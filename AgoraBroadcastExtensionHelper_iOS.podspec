#
# Be sure to run `pod lib lint AgoraBroadcastExtensionHelper_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraBroadcastExtensionHelper_iOS'
  s.module_name      = 'AgoraBroadcastExtensionHelper'
  s.version          = ENV['LIB_VERSION']
  s.summary          = 'Broadcast extension helper, for screen sharing.'

  s.description      = <<-DESC
Add this Pod to your app extension to easily share your screen using Agora's RTC Engine.
                       DESC

  s.homepage         = 'https://github.com/AgoraIO-Community/VideoUIKit-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Max Cobb' => 'max@agora.io' }
  s.source           = { :git => 'https://github.com/AgoraIO-Community/VideoUIKit-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_versions = ['5.0']

  s.static_framework = true
  s.source_files = 'Sources/AgoraBroadcastExtensionHelper/*'
  s.dependency 'AgoraRtcEngine_iOS', '~> 4.0.1'
  s.dependency 'AgoraAppGroupDataHelper_iOS', "#{s.version.to_s}"
end
