![The App Business](Assets/logo.png)

# configen

A command line tool to auto-generate configuration file code, for use in Xcode projects.

The `configen` tool is used to auto-generate configuration code from a Swift file. It is intended to
create the kind of configuration needed for external URLs or API keys used by your app. It only supports Swift code.

# Installation

To add the `configen` tool to your project, you must first aquire the `configen` excecutable binary and the necessary frameworks. The simplest way to do this is to download the executable binary and frameworks from the latest release.

Alternatively, you can download or clone this repository. Once you have done so, open and build the `configen.xcodeproj` project in Xcode, right click on the `configen` product and select ‘Show in Finder’.

Once you have the executable file and the frameworks, make a copy and add it to the root directory of your project. Now you are ready to go! 

Next you need to create the relevant files and set-up your project accordingly. This is outlined below.

# Usage

## Step 1: The protocol

The protocol file ensures all your configuration files have the same variables. The protocol file contains a Swift protocol declaration, where you define the configuration variables you support.

An example protocol file will look like this:

```swift
// ConfigProtocol.swift
protocol ConfigProtocol {
    static var showDebugScreen: Bool { get }
	static var apiBaseUrl: URL { get }
}
```

## Step 2: A struct for each environment

Once you have created a protocol, you need to create a struct, which conforms to your protocol and in which you provide values for each of the keys defined in your protocol. For example, you may have a `staging` and a `production` environment, in which case you will have to create two separate structs.

Using the above example, the struct will look like this: 

```swift
// StagingConfig.swift
struct StagingConfig: ConfigProtocol {
	static let showDebugScreen: Bool = true
	static let apiBaseUrl: URL = URL(string: "http://api-staging.client.com/v1")!
}
```

```swift
// ProdConfig.swift
struct ProdConfig: ConfigProtocol {
	static let showDebugScreen: Bool = false
	static let apiBaseUrl: URL = URL(string: "http://api-prod.client.com/v1")!
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

The best way to support multiple environments is to define a separate scheme for each one. Then add the relevant target as an external build step for each scheme.

Please refer to the example project included in the repository for further guidance.