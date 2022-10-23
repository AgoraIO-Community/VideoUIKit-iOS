#
# Be sure to run `pod lib lint AgoraAppGroupDataHelper_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraAppGroupDataHelper_iOS'
  s.module_name      = 'AgoraAppGroupDataHelper'
  s.version          = ENV['LIB_VERSION']
  s.summary          = 'Helper for sharing channel data between app and app extensions.'

  s.description      = <<-DESC
Use this Pod to interact with app extensions, such as a broadcast extension for sharing screens.
                       DESC

  s.homepage         = 'https://github.com/AgoraIO-Community/VideoUIKit-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Max Cobb' => 'max@agora.io' }
  s.source           = { :git => 'https://github.com/AgoraIO-Community/VideoUIKit-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_versions = ['5.0']

  s.static_framework = true
  s.source_files = 'Sources/AgoraAppGroupDataHelper/*'
end
