# Uncomment the next line to define a global platform for your project
platform :ios, '18.0'

target 'Filterit' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Filterit
  pod 'RxSwift', '~> 6.0'
  pod 'RxCocoa', '~> 6.0'
  pod 'MBProgressHUD', '~> 1.2.0'
  pod 'moa', '~> 12.0'
  pod 'FCAlertView', :inhibit_warnings => true
  pod 'SwifterSwift'
  
  target 'FilteritTests' do
    inherit! :search_paths
    # Pods for testing
    
    post_install do |installer|
        installer.generated_projects.each do |project|
            project.targets.each do |target|
                target.build_configurations.each do |config|
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
                end
            end
        end
    end
  end

end
