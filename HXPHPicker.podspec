Pod::Spec.new do |spec|
    spec.name                   = "HXPHPicker"
    spec.version                = "2.0.0"
    spec.summary                = "Photo selector - Support LivePhoto, GIF selection"
    spec.homepage               = "https://github.com/SilenceLove/HXPHPicker"
    spec.license                = { :type => "MIT", :file => "LICENSE" }
    spec.author                 = { "SilenceLove" => "294005139@qq.com" }
    spec.swift_versions         = ['5.0']
    spec.ios.deployment_target  = "12.0"
    spec.source                 = { :git => "https://github.com/SilenceLove/HXPHPicker.git", :tag => "#{spec.version}" }
    spec.framework              = 'UIKit','Photos','PhotosUI'
    spec.requires_arc           = true
    
    spec.default_subspec        = 'Full'
  
    spec.subspec 'Core' do |core|
        core.source_files   = "Sources/HXPHPicker/Core/**/*.{swift}"
        core.resources      = "Sources/HXPHPicker/Resources/*.{bundle}"
    end
  
    spec.subspec 'Picker' do |picker|
        picker.subspec 'Lite' do |lite|
            lite.source_files   = "Sources/HXPHPicker/Picker/**/*.{swift}"
            lite.dependency 'HXPHPicker/Core'
            lite.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'HXPICKER_ENABLE_PICKER' }
        end
        picker.subspec 'KF' do |kf|
            kf.dependency 'HXPHPicker/Picker/Lite'
            kf.dependency 'Kingfisher', '~> 7.0'
        end
    end
  
    spec.subspec 'Editor' do |editor|
        editor.subspec 'Lite' do |lite|
            lite.source_files   = "Sources/HXPHPicker/Editor/**/*.{swift}"
            lite.dependency 'HXPHPicker/EditorView/Lite'
            lite.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'HXPICKER_ENABLE_EDITOR' }
        end
        editor.subspec 'KF' do |kf|
            kf.dependency 'HXPHPicker/EditorView/KF'
            kf.dependency 'HXPHPicker/Editor/Lite'
            kf.dependency 'Kingfisher', '~> 7.0'
        end
    end
    
    spec.subspec 'EditorView' do |editor_view|
        editor_view.subspec 'Lite' do |lite|
            lite.source_files   = "Sources/HXPHPicker/Editor+View/**/*.{swift}"
            lite.dependency 'HXPHPicker/Core'
            lite.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'HXPICKER_ENABLE_EDITOR_VIEW' }
        end
        editor_view.subspec 'KF' do |kf|
            kf.dependency 'HXPHPicker/EditorView/Lite'
            kf.dependency 'Kingfisher', '~> 7.0'
        end
    end
    
    spec.subspec 'Camera' do |camera|
        camera.subspec 'Lite' do |lite|
            lite.source_files   = "Sources/HXPHPicker/Camera/**/*.{swift,metal}"
            lite.dependency 'HXPHPicker/Core'
            lite.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'HXPICKER_ENABLE_CAMERA' }
        end
        camera.subspec 'Location' do |loca|
            loca.source_files   = "Sources/HXPHPicker/Camera+Location/**/*.{swift}"
            loca.pod_target_xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'HXPICKER_ENABLE_CAMERA_LOCATION' }
            loca.dependency 'HXPHPicker/Camera/Lite'
        end
    end
    
    spec.subspec 'Lite' do |lite|
        lite.dependency 'HXPHPicker/Picker/Lite'
        lite.dependency 'HXPHPicker/Editor/Lite'
        lite.dependency 'HXPHPicker/Camera/Lite'
    end
    
    spec.subspec 'NoLocation' do |noLocation|
        noLocation.dependency 'HXPHPicker/Picker'
        noLocation.dependency 'HXPHPicker/Editor'
        noLocation.dependency 'HXPHPicker/Camera/Lite'
    end
    
    
    spec.subspec 'Full' do |full|
        full.dependency 'HXPHPicker/Picker'
        full.dependency 'HXPHPicker/Editor'
        full.dependency 'HXPHPicker/Camera'
    end
end
