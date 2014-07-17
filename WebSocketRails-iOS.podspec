Pod::Spec.new do |s|
  s.name             = "WebSocketRails-iOS"
  s.version          = "0.3"
  s.summary          = "Port of JavaScript client provided by https://github.com/websocket-rails/websocket-rails"
  s.homepage         = "https://github.com/Mobile2b/WebSocketRails-iOS"
  s.license          = 'MIT'
  s.authors           = "patternoia", {"Joachim Kurz" => "kurz@mobile2b.de"}
  s.source           = { :git => "https://github.com/Mobile2b/WebSocketRails-iOS.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files       = 'WebSocketRails-iOS/*.{h,m,c}'

  s.frameworks = 'CFNetwork', 'Security'
  s.dependency 'SocketRocket', '0.3.1-beta2'
end
