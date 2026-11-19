Pod::Spec.new do |s|
  s.name = 'KBZPayAPPPay'
  s.version = '1.3.0'
  s.summary = 'KBZPay native app payment SDK for iOS'
  s.homepage = 'https://www.kbzpay.com/'
  s.license = { :type => 'Proprietary' }
  s.author = 'KBZPay'
  s.source = { :path => '.' }
  s.platform = :ios, '13.0'
  s.vendored_frameworks = 'KBZPayAPPPay.xcframework'
end
