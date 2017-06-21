#
# Be sure to run `pod lib lint OBD2-Swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OBD2-Swift'
  s.version          = '0.1.0'
  s.summary          = 'OBD or On-board diagnostics is a vehicle's self-diagnostic and reporting capability.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
OBD or On-board diagnostics is a vehicle's self-diagnostic and reporting capability. OBD systems give access to the status of the various vehicle subsystems. Simply saying, OBD-II is a sort of computer which monitors emissions, mileage, speed, and other useful data.
                       DESC

  s.homepage         = 'https://github.com/lemberg/obd2-swift-lib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'overswift' => 'sergiy.loza@lemberg.co.uk' }
  s.source           = { :git => 'https://github.com/lemberg/obd2-swift-lib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'OBD2-Swift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'OBD2-Swift' => ['OBD2-Swift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
