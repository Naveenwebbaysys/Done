# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'Done' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for Done
  pod 'IQKeyboardManagerSwift'
  pod 'Kingfisher'
  #pod 'SVProgressHUD'
  pod "KRProgressHUD"
  pod 'AWSS3'
  #pod 'AWSCore'
  #pod 'AWSCognito'
  pod 'AWSUserPoolsSignIn'
  pod 'iOSDropDown'
  pod "SwiftyCam"
  pod 'HMSegmentedControl'
  pod 'SDWebImage'
  pod 'DropDown'
  pod 'MaterialComponents/ProgressView'
  pod "AlignedCollectionViewFlowLayout"
  pod 'MGStarRatingView'
end
#

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
               end
          end
   end
end
