platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

target 'Notes' do
    pod "MagicalRecord"
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.name == 'Debug'
                config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)']
                config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
            end

            if config.name == 'Release'
                config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
            end

            config.build_settings['SWIFT_VERSION'] = '4.3'
        end
    end
end
