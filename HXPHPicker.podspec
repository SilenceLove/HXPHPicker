Pod::Spec.new do |spec|
    spec.name         = "HXPHPicker"
    spec.version      = "1.0.0"
    spec.summary      = "Photo selector - Support LivePhoto, GIF selection"
    spec.homepage     = "https://github.com/SilenceLove/HXPHPicker"
    spec.license      = { :type => "MIT", :file => "LICENSE" }
    spec.author       = { "SilenceLove" => "294005139@qq.com" }
    spec.platform     = :ios, "9.0"
    spec.ios.deployment_target = "9.0"
    spec.source       = { :git => "https://github.com/SilenceLove/HXPHPicker.git", :tag => "#{spec.version}" }
    spec.framework    = 'UIKit','Photos','PhotosUI'
    spec.requires_arc = true
    
    spec.default_subspec = 'Default'
  
    spec.subspec 'Default' do |de|
        de.source_files = "Sources/HXPHPicker/**/*.swift"
        de.resources    = "Sources/HXPHPicker/Resources/*.{bundle}"
    end
end
