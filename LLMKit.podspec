#
# Be sure to run `pod lib lint LLMKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LLMKit'
  s.version          = '0.1.0'
  s.summary          = 'LLMKit is a CocoaPod wrapper around LLM.swift and specific models'
  s.description      = <<-DESC
LLMKit is a CocoaPod wrapper around LLM.swift and specific models
                       DESC

  s.homepage         = 'https://github.com/peakresponse/peak-ios-llmkit'
  s.license          = { :type => 'LGPL-2.1', :file => 'LICENSE.md' }
  s.author           = { 'Francis Li' => 'mail@francisli.com' }
  s.source           = { :git => 'https://github.com/peakresponse/peak-ios-llmkit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.5'

  s.source_files = 'LLMKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LLMKit' => ['LLMKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.spm_dependency 'LLM/LLM'
end
