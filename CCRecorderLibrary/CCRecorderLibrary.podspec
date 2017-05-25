Pod::Spec.new do |s|

  s.name         = "CCRecorderLibrary"
  s.version      = "0.5.37"
  s.summary      = "CCRecorder."

  s.description  = <<-DESC
    CCRecorderLibrary for CCRecorder .
                   DESC

  s.homepage     = "https://github.com/VArbiter"
  s.license      = "MIT"

  s.author  = { "冯明庆" => "elwinfrederick@163.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :path => "CCRecorderLibrary"}

  s.source_files  = "CCRecorderLibrary", "CCRecorderLibrary/**/*"

  s.resource     = "CCRecorderLibraryBundle.bundle"

  s.frameworks   = "AVFoundation", "QuartzCore" , "CoreGraphics" , "CoreMedia" , "MediaPlayer" , "Foundation" , "UIKit"

  s.requires_arc = true

end
