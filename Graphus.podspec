#
# Be sure to run `pod lib lint Graphus.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Graphus'
  s.version          = '2.1.3'
  s.summary          = 'Powerful and strongly-typed, pure-Swift GraphQL client for iOS'
  s.homepage         = 'https://github.com/ilia3546/Graphus'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ilya Kharlamov' => 'ilia3546@me.com' }
  s.source           = { :git => 'https://github.com/ilia3546/Graphus.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = ['4.2', '5.0']
  s.default_subspec = 'Core'
  s.dependency 'Alamofire', '~> 5.4'
 
  s.subspec 'Core' do |cs|
      cs.source_files  = 'Source/Core/**/*.{swift,h,m}'
  end
  
  s.subspec 'Codable' do |cs|
      cs.dependency      'Graphus/Core'
      cs.source_files  = 'Source/Codable/**/*.{swift,h,m}'
  end
  
  s.pod_target_xcconfig = {
    'SWIFT_INSTALL_OBJC_HEADER' => 'NO'
  }

end
