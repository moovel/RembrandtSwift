#
# Be sure to run `pod lib lint rembrandt.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'rembrandt'
  s.version          = '0.1.2'
  s.summary          = 'A lightweight image comparison lib.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Rembrandt is an image library for swift 3 with objective-C bindings, based on RembrandtJS see http://rembrandtjs.com.
                       DESC

  s.homepage         = 'https://github.com/imgly/RembrandtSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Carsten Przyluczky' => 'carsten.przyluczky@9elements.com' }
  s.source           = { :git => 'https://github.com/imgly/RembrandtSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0.0'

  s.source_files = 'rembrandt/Classes/**/*'

end
