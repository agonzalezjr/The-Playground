//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


func dictTests(_ dict: [String: Any]) {

  guard let nestedDict = dict["c"] as? [String: Any] else {
    print("bad")
    return
  }

  print(nestedDict)
}

// --

let d1: [String: Any?] = [
  "a": 1,
  "b": 2,
  "c": [
    "m": 42,
    "n": nil
  ],
  "n": nil
]

dictTests(d1)

// --

let nested = NSMutableDictionary()
nested.setValue(42, forKey: "m")
nested.setValue(nil, forKey: "n1")
nested.setValue(NSNull.self, forKey: "n2")

let d2: [String: Any] = [
  "a": 1,
  "c": nested
]

dictTests(d2)

//let d3: [String: Any] = ["a": 1] // prints ["a": 1]
//let d3: [String: Any] = ["a": 1, "b": nil] // compile error
//let d3: NSDictionary = ["a": 1, "b": nil] // compile error
//let d3: [String: Any?] = ["a": 1, "b": nil] // prints ["b": nil, "a": Optional(1)]
print(d3)
