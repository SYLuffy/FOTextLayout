#
#  Be sure to run `pod spec lint FOTextLayout.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "FOTextLayout"
  s.version      = "0.0.1"
  s.summary      = "This is a library of text layout."
  s.description  = <<-DESC
                   DESC
  s.homepage     = "https://github.com/SYLuffy/FOTextLayout"
  s.license      = "MIT"

  s.author             = { "shenyi" => "372713852@qq.com" }
  s.platform     = :ios
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/SYLuffy/FOTextLayout.git", :tag => "#{s.version}" }

  s.source_files  = "FOText/*"
  s.requires_arc = true


end
