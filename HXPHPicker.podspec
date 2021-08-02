Pod::Spec.new do |spec|
    spec.name                   = "HXPHPicker"
    spec.version                = "1.1.6"
    spec.summary                = "Photo selector - Support LivePhoto, GIF selection"
    spec.homepage               = "https://github.com/SilenceLove/HXPHPicker"
    spec.license                = { :type => "MIT", :file => "LICENSE" }
    spec.author                 = { "SilenceLove" => "294005139@qq.com" }
    spec.swift_versions         = ['5.3']
    spec.ios.deployment_target  = "10.0"
    spec.source                 = { :git => "https://github.com/SilenceLove/HXPHPicker.git", :tag => "#{spec.version}" }
    spec.framework              = 'UIKit','Photos','PhotosUI'
    spec.requires_arc           = true
    
    spec.default_subspec        = 'Full'
  
    spec.subspec 'Core' do |core|
        core.source_files   = "Sources/HXPHPicker/Core/**/*.{swift}"
        core.resources      = "Sources/HXPHPicker/Resources/*.{bundle}"
    end
  
    spec.subspec 'Picker' do |picker|
        picker.source_files   = "Sources/HXPHPicker/Picker/**/*.{swift}"
        picker.dependency 'HXPHPicker/Core'
        picker.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'HXPICKER_ENABLE_PICKER' }
    end
  
    spec.subspec 'Editor' do |editor|
        editor.source_files   = "Sources/HXPHPicker/Editor/**/*.{swift}"
        editor.dependency 'HXPHPicker/Core'
        editor.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'HXPICKER_ENABLE_EDITOR' }
    end
    
    spec.subspec 'Full' do |full|
        full.dependency 'HXPHPicker/Lite'
        full.dependency 'Kingfisher', '~> 6.0'
    end
    
    spec.subspec 'Lite' do |lite|
        lite.dependency 'HXPHPicker/Core'
        lite.dependency 'HXPHPicker/Picker'
        lite.dependency 'HXPHPicker/Editor'
    end
end
