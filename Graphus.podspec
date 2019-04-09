#
# Be sure to run `pod lib lint Graphus.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Graphus'
  s.version          = '0.1.0'
  s.summary          = 'GraphQL client'
  s.homepage         = 'https://github.com/ilia3546/Graphus'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ilia3546' => 'ilia3546@me.com' }
  s.source           = { :git => 'https://github.com/ilia3546/Graphus.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'
  s.ios.deployment_target = '8.0'
  s.default_subspec = 'Core'
  
  s.subspec 'Core' do |cs|
      cs.source_files  = 'Graphus/Core/**/*.{swift,h,m}'
  end
  
  s.subspec 'Codable' do |cs|
      cs.dependency      'Graphus/Core'
      cs.source_files  = 'Graphus/Codable/**/*.{swift,h,m}'
  end
  

end
