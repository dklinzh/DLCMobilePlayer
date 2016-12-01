#
# Be sure to run `pod lib lint DLCMobilePlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DLCMobilePlayer'
  s.version          = '0.3.6'
  s.summary          = 'A framework of video player for iOS devices that based on VLCKit.'
  s.description      = <<-DESC
                       A framework of video player for iOS devices that based on VLCKit(https://github.com/dklinzh/VLCKit). Supported protocols include http, rtsp, rtmp etc.
                       DESC

  s.homepage         = 'https://github.com/dklinzh/DLCMobilePlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniel' => 'linzhdk@gmail.com' }
  s.source           = { :git => 'https://github.com/dklinzh/DLCMobilePlayer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'
  s.private_header_files = 'DLCMobilePlayer/Classes/Aspects/**/*.h', 'DLCMobilePlayer/Classes/MSWeakTimer/**/*.h'
  s.source_files = 'DLCMobilePlayer/Classes/**/*.{h,m}'
  s.resources = 'DLCMobilePlayer/Assets/**/*.{xib,xcassets}'

#s.resource_bundles = { 'DLCMobilePlayer' => ['DLCMobilePlayer/Assets/**/*'] }
#s.public_header_files = 'Pod/Classes/**/*.h'

  s.frameworks = 'QuartzCore', 'CoreText', 'AVFoundation', 'Security', 'CFNetwork', 'AudioToolbox', 'OpenGLES', 'CoreGraphics', 'VideoToolbox', 'CoreMedia'
  s.libraries = 'c++', 'xml2', 'z', 'bz2', 'iconv'
  s.vendored_frameworks = "DLCMobilePlayer/Libs/*.framework"
  s.xcconfig = { "ENABLE_BITCODE" => "NO" }
  s.prefix_header_file = 'DLCMobilePlayer/Classes/DLCMobilePlayer-Prefix.pch'
  s.dependency 'Reachability'
end
