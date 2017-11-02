#
# Be sure to run `pod lib lint OBD2-Swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OBD2-Swift'
  s.module_name      = 'OBD2'
  s.version          = '0.2.0'
  s.summary          = 'Library which is manage connection to OBD2 and allow to observe obd data'
  s.homepage         = 'https://github.com/lemberg/obd2-swift-lib'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'overswift' => 'sergiy.loza@lemberg.co.uk' }
  s.source           = { :git => 'https://github.com/lemberg/obd2-swift-lib.git', :tag => s.version }

  s.ios.deployment_target = '9.3'

  s.source_files = 'OBD2-Swift/Classes/**/*'

end
