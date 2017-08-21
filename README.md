# configen

A command line tool to auto-generate configuration file code, for use in Xcode projects. To read about the motivation behind this project and the scenarios in which it might be used see our [blog post](http://www.theappbusiness.com/blog/a-robust-multi-environment-build-setup). 

The `configen` tool is used to auto-generate configuration code from a property list. It is intended to
create the kind of configuration needed for external URLs or API keys used by your app. Currently supports both Swift and Objective-C code generation.

# Installation

To add the `configen` tool to your project you must first aquire the `configen` excecutable binary. The simplest way to do this is to download the executable binary from the latest release.

Alternatively you can download or clone this repository. Once you have done so, open and build the `configen.xcodeproj` project in Xcode, right click on the `configen` product and select ‘Show in Finder’.

Once you have the executable file, make a copy and add it to the root directory of your project. Now you are ready to go! Next you need to create the relevant files and set-up your project accordingly. This is outlined below.

# Usage

## Step 1: The mapping file

Before running the `configen` tool, you need to create a mapping file (.map), in which you define the configuration variables you support. For example:

```swift
entryPointURL : URL
enableFileSharing : Bool
retryCount : Int
adUnitPrefix : String
analyticsKey : String
environment : Environment
```

The `configen` mapping file uses a custom set of types which map to Swift types. Therefore for Objective-C code generation, you must still use Swift equivalent types in the mapping file.

## Step 2: A plist for each environment

Then you need to create a property list (plist) file, in which you provide values for each of the keys defined in your mapping file, above. You need to create a property list file for each required environment. For example, you may have a `test` and a `production` environment.

Using the above example, the plist source code for a production environment may look as follows: 

```
<plist version="1.0">
<dict>
<key>entryPointURL</key>
<string>http://example.com/production</string>
<key>enableFileSharing</key>
<true/>
<key>retryCount</key>
<integer>4</integer>
<key>adUnitPrefix</key>
<string>production_ad_unit</string>
<key>analyticsKey</key>
<string>haf6d9fha8v56abs</string>
<key>environment</key>
<string>.Production</string>
</dict>
</plist>
```

Before proceeding to the next step, ensure that both the mapping file and plist files are placed inside your project directory. To keep things simple it might be best to place all these files in the same place, for example, in a `Config` sub-folder. You will need to reference the path to these files in step 3. 

## Step 3: An external build step for each environment

Finally, you need to create a build target for each of your environments. This can be done be selecting File -> New -> Target and selecting 'External Build System' from the 'Cross-Platform' tab.

In the settings of each build target point the 'Build Tool' to the location of the `configen` script that you copied to your directory earlier and invoke the arguments as follows. Note that the output directory must be created separately.

```sh
configen --plist-path <plist> --hints-path <mapping-file> --class-name <output-class-name> --output-directory <output-directory>

  -p, --plist-path:
      Path to the input plist file
  -h, --hints-path:
      Path to the input hints file
  -n, --class-name:
      The output config class name
  -o, --output-directory:
      The output config class directory
  -c, --objective-c:
      Whether to generate Objective-C files instead of Swift

# e.g.

configen --plist-path EnvironmentConfig/EnvironmentConfig_Prod.plist --hints-path EnvironmentConfig.map --class-name EnvironmentConfig --output-directory EnvironmentConfig

```

`configen` generates Swift code by default. You can generate Objective-C code by providing the `-c` or `--objective-c` switches

The best way to support multiple environments is to define a separate scheme for each one. Then add the relevant target as an external build step for each scheme ensuring that 'Parallelize Build' is disabled.

Please refer to the example project included in the repository for further guidance. 

# Standard types supported

* `Int`: Expects integer type in plist
* `String`: Expects string type in plist
* `Bool`: Expects Boolean type in plist
* `Double`: Expects floating point type in plist
* `URL`: Expects a string in the plist, which can be converted to a URL (validated at compile time) 

# Custom types

Any other type is supported, by providing a string in the plist which compiles successfully when converted to code. For example:

```
enum Environment {
  case Development
  case UAT
  case Production
}
```

Providing the mapping type `environment : Environment` in the mapping file, and the string `.Production` in the plist, the property in your configuration class will be as follows:

```
  static let environment: Environment = .Production
```

This is powerful, because it allows you to work with optionals, which are not supported by the standard types. For example:

**Mapping file:**
```
retryCount : Int?
```

You have to make the type in your plist a string, and input either a number -- e.g. `1` -- or the word `nil`, so the output property becomes, for example:

```
  let retryCount: Int? = nil
```
