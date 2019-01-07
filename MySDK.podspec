#
#  Be sure to run `pod spec lint MySDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "MySDK"
  s.version      = "0.0.1"
  s.summary      = "A short description of MySDK."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  MySDK test
                   DESC

  s.homepage     = "https://github.com/lyuxxx/MySDK"

  s.license      = { :type => 'Apache-2.0', :file => 'LICENSE' }

  s.author             = { "yxliu" => "yuxuan.liu2@pactera.com" }

  s.source       = { :http => 'https://raw.githubusercontent.com/lyuxxx/MySDK/master/MySDK.zip' }
  s.ios.deployment_target = '9.0'
  s.ios.vendored_frameworks = 'MySDK.framework'

end
