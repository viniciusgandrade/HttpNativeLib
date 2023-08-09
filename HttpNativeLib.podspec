Pod::Spec.new do |spec|
  spec.name         = 'HttpNativeLib'
  spec.version      = '1.0.0'
  spec.summary      = 'Library HTTP Native'
  spec.description  = 'Library HTTP Native'
  spec.homepage     = 'https://github.com/viniciusgandrade/HttpNativeLib'
  spec.license      = 'MIT'
  spec.author       = { 'Vinícius Andrade' => 'vinicius.andrade@gs3tecnologia.com.br' }
  spec.source       = { :git => 'https://github.com/viniciusgandrade/HttpNativeLib.git', :tag => spec.version.to_s }
  spec.platform     = :ios, '13.0'
  spec.source_files = 'HttpNativeLib/**/*.{swift,h,m,c,cc,mm,cpp}'
  spec.swift_version = '5.0'
  spec.static_framework = true
  spec.dependency 'Alamofire'
  # Add any dependencies if needed
end
