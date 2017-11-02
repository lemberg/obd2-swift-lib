# OBD2 Swift

[![GitHub Release](https://img.shields.io/badge/release-none-red.svg)](https://github.com/lemberg/obd2-swift-lib)
[![Swift Version](https://img.shields.io/badge/Swift-3.1%2B-orange.svg?style=flat)](http://cocoapods.org/pods/PermissionsService) 
[![GitHub Platforms](https://img.shields.io/badge/platform-ios%20%7C%20macos%20-brightgreen.svg)](https://github.com/lemberg/obd2-swift-lib)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/lemberg/obd2-swift-lib/blob/dev/LICENSE) 
[![By](https://img.shields.io/badge/By-Lemberg%20Solutions%20Limited-blue.svg?style=flat)](http://cocoapods.org/pods/PermissionsService)

On-board diagnostics swift library. 

* [Why do you need it?](https://github.com/lemberg/obd2-swift-lib#why-you-need-it)
* [Requirements](https://github.com/lemberg/obd2-swift-lib#requirements)
* [Features](https://github.com/lemberg/obd2-swift-lib#features)
* [How To Use](https://github.com/lemberg/obd2-swift-lib#how-to-use)
   * [Create connection](https://github.com/lemberg/obd2-swift-lib#where-to-start)
   * [Getting metrics](https://github.com/lemberg/obd2-swift-lib#and-what-about-getting-metrics)
   * [Observing](https://github.com/lemberg/obd2-swift-lib#ok-but-what-about-monitoring)
* [Installation](https://github.com/lemberg/obd2-swift-lib#installation)
   * [As Embedded Framework](https://github.com/lemberg/obd2-swift-lib#manually-as-embedded-framework)
   * [CocoaPods](https://github.com/lemberg/obd2-swift-lib#cocoapods)
* [Author](https://github.com/lemberg/obd2-swift-lib#author)
* [License](https://github.com/lemberg/obd2-swift-lib#license)

## Why do you need it?

#### OBD2?.. What?
OBD or On-board diagnostics is a vehicle's self-diagnostic and reporting capability. OBD systems give access to the status of the various vehicle subsystems. 
Simply saying, OBD-II is a sort of computer which monitors emissions, mileage, speed, and other useful data.
 
> More details you can get [here](https://en.wikipedia.org/wiki/On-board_diagnostics). 

#### Ok. And what about this?

This is a library which can communicate with vehicles using OBD-II adapters. It is providing you with an opportunity for real-time vehicles diagnostics with several lines of code and without being nervous. The library will help you to connect with adapter and handle it's behaviour, like reconnect when something went wrong. And! You don't need to parse bytes response returned from adapter by yourself because OBD2 Swift will do it for your project. 

## Requirements

- iOS 9.0+
- Swift 3.0+
- Xcode 8.0+
- Mac OS X 10.0+ 

## Features

- [x] Supporting next Modes with almost all their PIDs:

Mode | Description
-----| -----------
Mode 01(02) | Sensors / Freeze Frame
Mode 03 | Trouble Codes (DTC)
Mode 04 | Reset Trouble Codes
Mode 09 | Information
 
- [x] Real-time connection with OBD-II
- [x] OBD-II full described diagnostic sensors list
- [x] Observer of connection and other metrics
- [x] Several types of returning & requesting diagnostic response
- [x] Logger, which can save your logs into a file and share it

## How to use? 

#### Where to start? 

First of all, create an `OBD2` object for requesting vehicles metrics. 

```swift
     let obd = OBD2()
```

Create a connection between your application and adapter. 

> :exclamation: Remember that **all callbacks return not in the main thread**.   

 ```swift
      obd.connect { [weak self] (success, error) in
              if let error = error {
                  print("OBD connection failed with \(error)")

              } else {
                  //perform something
              }
        }
```
Method `connect` would return you a response with an error if something went wrong and you can simply handle it, for example, show a message with reconnecting opportunity.  

If all goes okay, you have a connection! :sunglasses:

> Class `OBD2` contain another methods for work with connection like `pauseScan()`, `resumeScan()` and `stopScan()` as well.     

#### And what about getting metrics?

There is a simple way to get data from vehicle subsystems - to use requests. You can send it using `request(_:)` method of `OBD2 ` object. Use `struct Command` for choosing what you want to request. 

```swift
      obd.request(command: Command.Mode09.vin) { (descriptor) in
            let respStr = descriptor?.VIN()
            print(respStr ?? "No value")
        }
```

#### What if I want to get another response? 

You can use `request(_:)` method with `emun Custom: CommandType`. It helps you to send and get data in `digit` and `string` format. 

 ```swift
       obd.request(command: Command.Custom.digit(mode: 09, pid: 02)) { (descr) in
            if let response = descr?.response {
                print(response)
            } 
        }
```

#### Ok, but what about monitoring? 

You can still use requests for doing this. There is a method `request(repeat:)` wich will send a request to OBD repeatedly.  

 ```swift
      obd.request(repeat: Command.Mode01.pid(number: 12))
```

#### Where is a response?! :scream: 

Response from this method will be returned to `Observer`. Choose `Mode` type and create an `Observer` object.  

```swift
      let observer = Observer<Command.Mode01>()
```

Tell him to observe with specific PID number and enjoy responses. :]  

```swift
      observer.observe(command: .pid(number: 12)) { (descriptor) in
          let respStr = descriptor?.shortDescription
          print("Observer : \(respStr)")
      }
```

> :exclamation: To bring `Observer` alive you must register it in `ObserverQueue`. It is needed for returning diagnostics responses.  
>
> ```swift
>     ObserverQueue.shared.register(observer: observer)
>```
> Don't forget to do `unregister(_:)` when you don't need `Observer` anymore.  

#### How to stop it?

`OBD2` object has method `isRepeating(repeat:)` wich takes `Command` as a parameter. Using it you can check if the specific command is repeating now and stop it.

```swift
       if obd.isRepeating(repeat: Command.Mode01.pid(number: 12)) {
           obd.stop(repeat: command)
       } 
```

#### Can I use observer for other requests?

Yep! Single request method can take `Bool` parameter `notifyObservers` wich is `true` by default. Using it you can manage which requests will return response not only in completion block but in observer block too. 

## Installation

### Manually as Embedded Framework

* Go to your project root git folder and clone OBD2 Swift as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command from the terminal.

```swift
$ git submodule add https://github.com/lemberg/obd2-swift-lib.git
```

* Open obd2-swift-lib folder which was created. In the OBD2-Swift folder, you will found OBD2Swift.xcodeproj. Drag it into the Project Navigator of your project.

* Select your project in the Xcode Navigation and then select your application target from the sidebar. After this, select the "General" tab and click on the + button under the "Embedded Binaries" section.

* Select OBD2 Swift.framework from dialogue and that's all!  :tada:

> Don't forget to do `import OBD2Swift` in classes where you want to use this framework

### CocoaPods

To install it, simply add this line to your Podfile:

```swift
  pod "OBD2-Swift"
```

> If you'll need, there is still a version written on **Swift 3** named `swift3`. 

Now you need to run `pod update` command from you project folder and that's it!

## Author

### [Lemberg Solutions](http://lemberg.co.uk) 
[![Logo](http://lemberg.co.uk/sites/all/themes/lemberg/images/logo.png)](https://github.com/lemberg) 

## License

OBD2 Swift is available under the [MTI license](https://directory.fsf.org/wiki/License:MTI). See the LICENSE file for more info.
