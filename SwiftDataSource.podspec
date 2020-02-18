Pod::Spec.new do |spec|
  spec.name                  = 'SwiftDataSource'
  spec.version               = '0.9.1'
  spec.summary               = 'DataSource framework for Particle projects in Swift.'
  spec.description           = 'Adds convience methods for common objects in UIKit, Foundation.'
  spec.homepage              = 'https://github.com/ParticleApps/SwiftDataSource'
  spec.license               = { :type => 'MIT' , :file => 'LICENSE'}
  spec.author                = { 'Rocco Del Priore' => 'rocco@particleapps.co' }
  spec.source                = { :git => 'https://github.com/ParticleApps/SwiftDataSource.git', :tag => "#{spec.version}" }
  spec.social_media_url      = 'https://twitter.com/ParticleAppsCo'
  spec.frameworks            = 'Foundation', 'UIKit'
  spec.ios.deployment_target = '10.0'
  spec.source_files          = "SwiftDataSource", "SwiftDataSource/**/*.{swift,h,m}"
  spec.swift_version         = '4.2'
end
