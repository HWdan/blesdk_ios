Pod::Spec.new do |s|
  s.name = 'Zip'
  s.version = '2.1.2'
  s.summary = 'Swift framework for zipping and unzipping files.'
  s.homepage = 'https://github.com/marmelroy/Zip'
  s.license = { :type => 'MIT' }
  s.author = 'marmelroy'
  s.source = { :path => '.' }
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files = 'Zip/*.{swift,h}', 'Zip/minizip/*.{c,h}', 'Zip/minizip/include/*.{h}'
  s.public_header_files = 'Zip/*.h'
  s.libraries = 'z'
  s.pod_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Zip/Zip/minizip/** $(PODS_TARGET_SRCROOT)/Zip/minizip/**',
    'LIBRARY_SEARCH_PATHS' => '$(inherited) $(PODS_TARGET_SRCROOT)/Zip/'
  }
  s.preserve_paths = 'Zip/minizip/module/module.modulemap', 'Zip/minizip/include/*'
end
