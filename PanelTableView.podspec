#
# Be sure to run `pod lib lint PanelTableView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PanelTableView"
  s.version          = "0.9.1-1.1.1"
  s.summary          = "UIViewController with multiple UITableView in a UIScrollView"
  s.description      = <<-DESC
                       Creates a UIViewController with multiple UITableView in a UIScrollView
                       * recycle views efficiently
                       * save/restore table offsets for different panels
                       * delegate and datasource similar to that of UITableView
                       * PanelIndexPath behaves like IndexPath, but with an additional parameter, page
                       DESC
  s.homepage         = "https://github.com/cielliang/PanelTableView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "hongcheng" => "hongcheng@gmail.com" }
  s.source           = { :git => "https://github.com/cielliang/PanelTableView.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = false

  s.source_files = 'PanelTableView/Classes'
  #s.resource_bundles = {
  #  'PanelTableView2' => ['Pod/Assets/*.png']
  #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
