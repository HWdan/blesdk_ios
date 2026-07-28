Pod::Spec.new do |s|
  s.name = 'SSZipArchive'
  s.version = '2.4.3'
  s.summary = 'Utility class for zipping and unzipping files on iOS, tvOS, watchOS, and macOS.'
  s.homepage = 'https://github.com/ZipArchive/ZipArchive'
  s.license = { :type => 'MIT' }
  s.author = 'SSZipArchive'
  s.source = { :path => '.' }
  s.ios.deployment_target = '12.0'
  s.source_files = 'SSZipArchive/*.{m,h}', 'SSZipArchive/include/*.{m,h}', 'SSZipArchive/minizip/*.{c,h}'
  s.public_header_files = 'SSZipArchive/*.h'
  s.libraries = 'z', 'iconv'
  s.frameworks = 'Security'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) HAVE_INTTYPES_H HAVE_PKCRYPT HAVE_STDINT_H HAVE_WZAES HAVE_ZLIB'
  }
end
