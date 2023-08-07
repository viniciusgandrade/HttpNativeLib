Pod::Spec.new do |spec|
  spec.name         = 'HttpNativeLib'
  spec.version      = '0.0.2'
  spec.summary      = 'A brief description of MyLibrary'
  spec.description  = 'A longer description of MyLibrary'
  spec.homepage     = 'https://github.com/viniciusgandrade/HttpNativeLib'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Your Name' => 'your@email.com' }
  spec.source       = { :git => 'https://github.com/viniciusgandrade/HttpNativeLib.git', :tag => spec.version.to_s }
  spec.platform     = :ios, '13.0'
  spec.source_files = 'HttpNativeLib/**/*'
  spec.swift_version = '5.0'
  # Add any dependencies if needed
end
