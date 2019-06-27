//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

let properties: [wh: Any?] = [1: "Foo", 2: 1, 3: nil]

for (key, value) in properties {
    print("key: \(key), value: \(value)")
}

func p() {
    let p2: NSDictionary = [1: "Foo", 2: 2]

    guard let p2d = p2 as? [Int: String] else {
        print("bad cast")
        return
    }

    for (key, value) in p2 {
        print("key: \(key), value: \(value as! String)")
    }
}

p()

guard let properties = properties as? [String: AnyObject] else {
    throw ODataErrors.genericError(ErrorMessage.CREATE_MEDIA_WRONG_FORMAT)
}

// Now no need to worry about types no more!

for (key, value) in properties {
    let property = entityType.property(withName: key)
    property.setDataValue(in: entity, to: try DataServiceUtils.convert(value: value, type: (property.dataType.code)))
}
