# NFRecord

implementation of an activerecord-like pattern for objective c

## Integration instructions

### Via CocoaPods

    pod 'NFRecord', :git => 'https://github.com/NextFaze/NFRecord.git'

### As a submodule / static library

The project contains a NFRecord target that compiles to a cocoa touch static
library, which can be added in the normal way.

## Usage

### Models

Your model classes should extend NFRecordBase.  For example:

    @interface Dog : NFRecordBase
    @property (nonatomic, strong) NSString *breed;
    @property (nonatomic, strong) NSNumber *age;
    @property (nonatomic, strong) NSString *color;
    @property (nonatomic, strong) NSString *raceName;
    @end

to initialize a dog from a dictionary:

    NSDictionary *attributes = @{ @"breed:: @"Doge", @"age": @(5), @"color": @"blue", @"race_name": @"Doge" };
    Dog *dog = [Dog alloc] initWithDictionary:attributes];

also, assign attributes from a dictionary:

    dog.attributes = @{ @"age": @(6) };

Underscored attributes in dictionaries are automatically mapped to camelcase properties.

## Contact

[NextFaze](http://nextfaze.com)

## License

NFRecord is licensed under the terms of the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html). Please see the [LICENSE](https://github.com/NextfazeSD/NFRecord/blob/master/LICENSE) file for full details.

