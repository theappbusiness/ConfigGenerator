![The App Business](Assets/logo.png)

# configen

A command line tool to auto-generate configuration file code, for use in Xcode projects.

The `configen` tool is used to auto-generate configuration code from a Swift file. It is intended to
create the kind of configuration needed for external URLs or API keys used by your app. It only supports Swift code.

# Installation

To add the `configen` tool to your project you must first aquire the `configen` excecutable binary. The simplest way to do this is to download the executable binary from the latest release.

Alternatively you can download or clone this repository. Once you have done so, open and build the `configen.xcodeproj` project in Xcode, right click on the `configen` product and select ‘Show in Finder’.

Once you have the executable file, make a copy and add it to the root directory of your project. Now you are ready to go! Next you need to create the relevant files and set-up your project accordingly. This is outlined below.

# Usage

## Step 1: The protocol

Before running the `configen` tool, you need to create a protocol, in which you define the configuration variables you support. For example:

```swift
protocol ConfigProtocol {
	static var showDebugScreen: Bool { get }
	static var apiBaseUrl: URL { get }
}
```

## Step 2: A struct for each environment

Then you need to create a struct, which conforms to the above protocol and in which you provide values for each of the keys defined in the protocol. For example, you may have a `staging` and a `production` environment.

Using the above example, the struct would look like this: 

```swift
struct StagingConfig: ConfigProtocol {
	static let showDebugScreen: Bool = true
	static let apiBaseUrl: URL = URL(string: "http://api-staging.client.com/v1")!
}
```

Before proceeding to the next step, ensure that both the protocol file and struct files are placed inside your project directory. To keep things simple it might be best to place all these files in the same place, for example, in a `Config` sub-folder. You will need to reference the path to these files in step 3. 

## Step 3: An external build step for each environment

Finally, you need to create a build target for each of your environments. This can be done be selecting File -> New -> Target and selecting 'External Build System' from the 'Cross-Platform' tab.

In the settings of each build target point the 'Build Tool' to the location of the `configen` script that you copied to your directory earlier and invoke the arguments as follows. Note that the output directory must be created separately.

```sh
configen --swift-path <struct> --struct-name <output-struct-name> --output-directory <output-directory>

  -s, --swift-path:
      Path to the input plist file
  -n, --struct-name:
      The output config struct name
  -o, --output-directory:
      The output config struct directory

# Example

configen --swift-path Config/StagingConfig.swift --class-name AppConfig --output-directory Config

```

The best way to support multiple environments is to define a separate scheme for each one. Then add the relevant target as an external build step for each scheme ensuring that 'Parallelize Build' is disabled.

Please refer to the example project included in the repository for further guidance. 