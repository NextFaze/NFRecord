Pod::Spec.new do |s|
  s.name         			= "NFRecord"
  s.version      			= "0.0.1a"
  s.summary      			= "implementation of an activerecord-like pattern for objective c"
  s.description  			= <<-DESC
                   			  implementation of an activerecord-like pattern for objective c.
                   			  DESC

  s.homepage     			= "https://github.com/NextFaze/NFRecord"
  s.license      			= 'Apache 2.0'
  s.author       			= { "NextFaze Pty Ltd" => "contact@nextfaze.com" }

  s.platform     			= :ios, "6.0"
  s.source       			= { :git => "https://github.com/NextfazeSD/NFRecord.git", :tag => "0.0.1a" }
  s.source_files 			= "NFRecord", "NFRecord/**/*.{h,m}"
  s.frameworks   			= "AVFoundation"
  s.requires_arc 			= true
  s.prefix_header_contents 	= '#import "NFRecord.h"'
end
