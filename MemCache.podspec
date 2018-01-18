Pod::Spec.new do |s|
  s.name         = 'MemCache'
  s.summary      = 'High performance cache framework for iOS.'
  s.version      = '1.0.7'
  s.license      = "MIT"
    s.platform     = :ios, '8.0'
  s.authors      = { 'GodL' => '547188371@qq.com' }
  s.social_media_url = 'https://github.com/GodL/MemCache'
  s.homepage     = 'https://github.com/GodL/MemCache'
  s.source       = { :git => 'https://github.com/GodL/MemCache.git', :tag => s.version.to_s }
  s.dependency  'FHLinkedList'
  s.requires_arc = true
  s.source_files = 'MemCache/*.{h,m}'
  s.frameworks   = 'UIKit', 'CoreFoundation' 
end
