
# OBD2 Swift

[![GitHub Release](https://img.shields.io/badge/release-none-red.svg)](https://github.com/lemberg/obd2-swift-lib)
[![Swift Version](https://img.shields.io/badge/Swift-3.1%2B-orange.svg?style=flat)](http://cocoapods.org/pods/PermissionsService) 
[![GitHub Platforms](https://img.shields.io/badge/platform-ios%20%7C%20macos%20-brightgreen.svg)](https://github.com/lemberg/obd2-swift-lib)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/lemberg/obd2-swift-lib/blob/dev/LICENSE) 
[![By](https://img.shields.io/badge/By-Lemberg%20Solutions%20Limited-blue.svg?style=flat)](http://cocoapods.org/pods/PermissionsService)

On-board diagnostics swift library. 

1. [Why do you need it?](https://github.com/lemberg/obd2-swift-lib#why-you-need-it)
1. [Requirements](https://github.com/lemberg/obd2-swift-lib#requirements)
1. [Features](https://github.com/lemberg/obd2-swift-lib#features)
1. [How To Use](https://github.com/lemberg/obd2-swift-lib#what-do-you-need-to-do)
1. [Author](https://github.com/lemberg/obd2-swift-lib#author)
1. [License](https://github.com/lemberg/obd2-swift-lib#license)

## Why do you need it?

### OBD2?.. What?
OBD or On-board diagnostics is a vehicle's self-diagnostic and reporting capability. OBD systems give access to the status of the various vehicle subsystems. 
Simply saying, OBD-II is a sort of computer which monitors emissions, mileage, speed, and other useful data.
 
> More details you can get [here](https://en.wikipedia.org/wiki/On-board_diagnostics). 

### Ok. And what about this?

This is a library which can communicate with vehicles using OBD-II adapters. It is providing you with an opportunity for real-time vehicles diagnostics with several lines of code and without nervous. The library will create help you to connect with adapter and handle it's behaviour, like reconnect when something went wrong. And! You don't need to parse bytes response returned from adapter by yourself because OBD2 Swift will do it for your project. 

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
- [x] ODB2 full described diagnostic sensors list
- [x] Observer of connection and other metrics
- [x] Several types of returning & requesting diagnostic response
- [x] Logger, which can save your logs into a file and share it

## What do you need to do? 

- Create an `OBD2 ` object for requesting vehicles metrics. 

```swift
   let obd = OBD2()
```

- Choose `Mode` type and create an `Observer` object with it for getting and handling `OBD2` metrics.  

```swift
   let observer = Observer<Command.Mode01>()
```

- Tell him to observe with specific PID number 

```swift
  observer.observe(command: .pid(number: 12)) { (descriptor) in
          let respStr = descriptor?.shortDescription
          print("Observer : \(respStr)")
      }
```

- :exclamation: To bring `Observer` alive you must register it in `ObserverQueue`. It is needed for returning diagnostics responses.  

```swift
    ObserverQueue.shared.register(observer: observer)
```

-  Use `ODB2` object for requesting chosen metrics. Additionally, with help of different `var`s like `stateChanged` you can get the info you needed. 

```swift

  obd.request(repeat: Command.Mode01.pid(number: 12)) { (descriptor) in
         let respStr = descriptor?.stringRepresentation(metric: true, rounded : true)
         // perform what you need with  respStr
     }

```

## Installation
### Manually as Embedded Framework

* Go to your project root git folder and clone OBD2 Swift as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command from terminal.

```swift
$ git submodule add https://github.com/lemberg/obd2-swift-lib.git
```

* Open obd2-swift-lib folder which was created. In OBD2-Swift folder you will found OBD2Swift.xcodeproj. Drag it into the Project Navigator of your project.

* Select your project in the Xcode Navigation and then select your application target from the sidebar. After this, select the "General" tab and click on the + button under the "Embedded Binaries" section.

* Select OBD2 Swift.framework from dialog and thats all! 

> Don't forget to do `import OBD2Swift` in classes where you want to use this framework

## Author

### [Lemberg Solutions](http://lemberg.co.uk) 
[![Logo](http://lemberg.co.uk/sites/all/themes/lemberg/images/logo.png)](https://github.com/lemberg) 

## License

OBD2 Swift is available under the [MTI license](https://directory.fsf.org/wiki/License:MTI). See the LICENSE file for more info.
