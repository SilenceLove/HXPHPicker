source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'

install! 'cocoapods',
#:deterministic_uuids=>false,
disable_input_output_paths: true,
warn_for_unused_master_specs_repo: false

use_frameworks!

target 'Example' do
  # 包含所有功能，网络图片使用的是 'Kingfisher', '~> 7.0'
  pod 'HXPHPicker', :path => './'
  
  pod 'GDPerformanceView-Swift'
  
#  pod 'SwiftLint' // ${PODS_ROOT}/SwiftLint/swiftlint
#  pod 'GPUImage'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'Pods-Example'
#      Pod::UI.puts "'target':#{target}"
      target.build_configurations.each do |config|
        config.build_settings['MACH_O_TYPE'] = 'mh_dylib'
      end
    end
  end
end
