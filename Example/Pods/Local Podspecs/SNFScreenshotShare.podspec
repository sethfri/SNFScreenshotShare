Pod::Spec.new do |s|
  s.name             = 'SNFScreenshotShare'
  s.version          = '0.1.0'
  s.summary          = 'A small iOS library for helping users do things with their screenshots.'
  s.homepage         = 'https://github.com/sethfri/SNFScreenshotShare'
  s.license          = 'MIT'
  s.author           = { "Seth Friedman" => "sethfri@gmail.com" }
  s.source           = { :git => 'https://github.com/sethfri/SNFScreenshotShare.git', :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Classes/ios/*'
  # s.resources = 'Assets/*.png'

  s.ios.exclude_files = 'Classes/osx'
  s.public_header_files = 'Classes/**/*.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  # s.dependency 'JSONKit', '~> 1.4'
end
