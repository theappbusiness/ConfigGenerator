# configen

A command line tool to auto-generate configuration file code, for use in Xcode projects.

The `configen` tool is used to auto-generate configuration code from a property list. It is intended to
create the kind of configuration needed for external URLs or API keys used by your app.

# Usage

Before running the `configen` tool, you need to create a mapping file, in which you define the configuration variables you support. For example:

```swift
entryPointURL : NSURL
searchURL : NSURL
retryCount : Int
adUnitPrefix : String
pushKey : String
analyticsKey : String
environment : Environment
```

Then you need to create a property list file, in which you provide values for each of the keys defined in your mapping file, above.

Finally, invoke the `configen` tool as follows:

```sh
configen <plist> <mapping-file> <output-class-name> <output-directory>

# e.g.

configen EnvironmentConfig/EnvironmentConfig.plist EnvironmentConfig.map EnvironmentConfig EnvironmentConfig
```

# Standard types supported

* `Int`: Expects integer type in plist
* `String`: Expects string type in plist
* `Bool`: Expects Boolean type in plist
* `Double`: Expects floating point type in plist
* `NSURL`: Expects a string in the plist, which can be converted to an NSURL (validated at compile time)

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
  static let retryCount: Int? = nil
```

# Supporting multiple environments

The best way to support multiple environments is to define a separate scheme for each one.
Then create an external build step for each scheme. In the external build step, you run
`configen` with different parameters depending on the environment being built.

# To-do list

* Change the way arguments are passed to the script on the command line. We should pass named parameters.
* Support Objective-C code generation.
