//: Playground - noun: a place where people can play

import UIKit

var params: [String: Any] = [:]

print("--- with let alone ---")

if let hardBool = params["myBool"] as? Bool {
  print("uninitialized check passes")
}

params["myBool"] = false
if let hardBool = params["myBool"] as? Bool {
  print("false check passes")
}

params["myBool"] = true
if let hardBool = params["myBool"] as? Bool {
  print("true check passes")
}


print("--- optional binding ---")

params["myBool"] = nil

if let hardBool = params["myBool"] as? Bool, hardBool {
  print("uninitialized check passes")
}

params["myBool"] = false
if let hardBool = params["myBool"] as? Bool, hardBool {
  print("false check passes")
}

params["myBool"] = true
if let hardBool = params["myBool"] as? Bool, hardBool {
  print("true check passes")
}

print("done")
