# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'ilumore' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  use_modular_headers!

  # Pods for ilymore
  pod 'FirebaseCore'
  pod 'FirebaseFirestore'
  pod 'FirebaseAuth'
  pod 'SDWebImageSwiftUI'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0' # or 5.7 depending on your Xcode
    end
  end
end

end
