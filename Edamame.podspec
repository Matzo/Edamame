#
# Be sure to run `pod lib lint Edamame.podspec' to ensure this is a
# valid spec before submitting.
#
Pod::Spec.new do |s|
  s.name             = "Edamame"
  s.version          = "1.4.0"
  s.summary          = "Edamame makes UICollectionView easy to use."
  s.description      = <<-DESC
  Edamame supports followings.
  - Easily specify Cell class based on section or each cell.
  - Culclate cell size in background thread. (yet)
  - You can use original layout.
                       DESC
  s.homepage         = "https://github.com/Matzo/Edamame"
  s.license          = 'MIT'
  s.author           = { "Matzo" => "ksk.matsuo@gmail.com" }
  s.source           = { :git => "https://github.com/Matzo/Edamame.git", :tag => s.version.to_s }
  s.platform     = :ios, '10.0'
  s.requires_arc = true
  s.swift_version = "4.2"
  s.source_files = 'Pod/Classes/**/*'
end
