install! 'cocoapods', :deterministic_uuids => false

source 'https://github.com/CocoaPods/Specs.git'

workspace 'BLE-Experiments'
project 'BLE-Experiments/BLE-Experiments.xcodeproj'
project 'BLE-Peripheral/BLE-Peripheral.xcodeproj'
project 'BLE-Central-OSX/BLE-Central-OSX.xcodeproj'

use_frameworks!
inhibit_all_warnings!

def import_pods
    pod 'CocoaLumberjack/Swift', '~> 2.2.0'
end

target 'BLE-Experiments' do
    platform :ios, '8.0'

    project 'BLE-Experiments/BLE-Experiments.xcodeproj'
    
    pod 'FLEX', '~> 2.3.0'
    pod 'Operations', '~> 2.7.0'
    import_pods
end

target 'BLE-Peripheral' do
    platform :ios, '8.0'

    project 'BLE-Peripheral/BLE-Peripheral.xcodeproj'
    
    pod 'FLEX', '~> 2.3.0'
    pod 'Operations', '~> 2.7.0'
    import_pods
end

target 'BLE-Central-OSX' do
    platform :osx, '10.10'
    
    project 'BLE-Central-OSX/BLE-Central-OSX.xcodeproj'
    
    import_pods
end

