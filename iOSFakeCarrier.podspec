Pod::Spec.new do |s|
  s.platform     = "ios"
  s.name         = "iOSFakeCarrier"
  s.version      = "1.1"
  s.summary      = "Automatically set carrier info based on locales and other custom settings - usefull for generating nice screenshots"
  s.description  = <<-DESC
                   Small class, that let you change standard iOS status bar information. Works in both simulator and device.
                   Supposed to be used when creating screenshots
                   for App Store - to have nice localized carrier info, time and other status bar information based on your needs.

                   We recommend to create different target for creating screenshots, where you will include this POD. Don't forgot to
                   remove this package from production build! It is using private API, so that it will not pass App Store review (it also
                   doesn't have sense to be included in production builds)/
                   DESC
  s.homepage     = "https://github.com/sarsonj/iosFakeCarrier.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jindrich Sarson" => "jindra@tappytaps.com" }
  s.source       = { :git => "https://github.com/sarsonj/iosFakeCarrier.git", :tag => "1.1"}
  s.source_files  = "iosFakeCarrier/Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.resource_bundle = { 'iosFakeCarrier' => 'iosFakeCarrier/Resources/*.lproj' }
  s.requires_arc = true
end
