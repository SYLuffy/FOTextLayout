
Pod::Spec.new do |s|
  s.name         = "FOTextLayout"
  s.version      = "0.0.1"
  s.summary      = "This is a library of text layout"
  s.homepage         = "https://github.com/SYLuffy/FOTextLayout"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "shenyi" => "372713852@qq.com" }
  s.source       = { :git => "https://github.com/SYLuffy/FOTextLayout.git", :tag => "#{s.version}" }
  s.source_files  = "FOText/*.{h,m}"
  s.requires_arc     = true
  s.ios.deployment_target = "8"
  s.description  = "Free text layout, Vertical text layout"
  s.frameworks   = "UIKit", "Foundation" , "CoreText" #支持的框架
end
