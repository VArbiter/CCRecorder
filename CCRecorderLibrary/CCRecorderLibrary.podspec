Pod::Spec.new do |s|

  s.name         = "CCRecorderLibrary"
  s.version      = "0.4.25"
  s.summary      = "CCRecorder."

  s.description  = <<-DESC
    CCRecorderLibrary for CCRecorder .
                   DESC

  s.homepage     = "https://github.com/VArbiter"
  s.license      = "MIT"

  s.author  = { "冯明庆" => "elwinfrederick@163.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :path => "CCRecorderLibrary/*"}

  s.source_files  = "CCRecorderLibrary", "*"

end
