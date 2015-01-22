# NFRecord

implementation of an activerecord-like pattern for objective c

## Integration instructions

### Via CocoaPods

    pod 'NFRecord', :git => 'https://github.com/NextFaze/NFRecord.git'

### Via Submodules

1. Add submodule to your project:

    `$ git submodule add git@github.com:NextfazeSD/NFRecord.git ThirdParty/NFRecord`
    
2. Drag the NFRecord.xcodeproj project file from Finder to the ThirdParty folder in your project tree.
3. Add `NFRecord` to target's Target Dependencies in Build Phases. 
4. Add `libNFRecord.a` in Link Binary with Libraries.
5. Also, in Link Binary with Libraries add `AVFoundation.framework`.
6. Add to other linker flags `-ObjC`.
7. Add to header search paths `ThirdParty/` with recursive selected.

Optionally, in your pre-compiled header (prefix.pch) add `#import "NFRecord.h"` to have access to all the classes throughout your project.


## Contact

[NextFaze](http://nextfaze.com)

## License

NFRecord is licensed under the terms of the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html). Please see the [LICENSE](https://github.com/NextfazeSD/NFRecord/blob/master/LICENSE) file for full details.

