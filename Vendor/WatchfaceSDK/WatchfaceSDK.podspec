Pod::Spec.new do |s|
  s.name             = 'WatchfaceSDK'
  s.version          = '1.0.6'
  s.summary          = 'HuaWo Watchface / Sifli push SDK'
  s.description      = 'Local vendored WatchfaceSDK for BleSdkDemo'
  s.homepage         = 'https://github.com/HWdan/WatchfaceSDK'
  s.license          = { :type => 'MIT' }
  s.author           = { 'HWdan' => 'huangwentai@huawo-wear.com' }
  s.source           = { :path => '.' }
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.source_files = [
    'WatchfaceSDK/Classes/Watchface/**/*',
    'WatchfaceSDK/Classes/OTA/**/*'
  ]
  s.resources = ['WatchfaceSDK/Assets/*']
  s.vendored_frameworks = [
    'WatchfaceSDK/SFDialPlateSDK.framework',
    'WatchfaceSDK/eZIPSDK.framework',
    'WatchfaceSDK/SifliOTAManagerSDK.framework',
    'WatchfaceSDK/VideoWatchfaceSDK.framework'
  ]
  s.frameworks = 'AudioToolbox', 'CoreMedia', 'VideoToolbox', 'AVFoundation'
  s.libraries = 'bz2', 'z', 'c++'
  s.dependency 'Zip', '~> 2.1'
  s.dependency 'SSZipArchive'
end
