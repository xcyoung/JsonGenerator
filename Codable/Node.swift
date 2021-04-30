//
//  Node.swift
//  Codable
//
//  Created by 肖楚🐑 on 2021/4/21.
//

import Foundation

enum NodeType: String {
    case typeString = "String"
    case typeInt64 = "Int64"
    case typeInt = "Int"
    case typeFloat = "Float"
    case typeDouble = "Double"
    case typeBool = "Bool"
    case typeArray = "Array"
    case typeDictionary = "Dictionary"
    case typeUnkown = "Unkown"
}

class Node: NSObject {
    let key: String
    let type: NodeType
    var children: [Node] = []

    init(key: String, value: Any) {
        self.key = key
        let type: NodeType
        if value is String {
            type = .typeString
        } else if value is Int {
            type = .typeInt
        } else if value is Float {
            type = .typeFloat
        } else if value is Double {
            type = .typeDouble
        } else if value is Bool {
            type = .typeBool
        } else if value is Array<[String: Any]> {
            type = .typeArray
        } else if value is Dictionary<String, Any> {
            type = .typeDictionary
        } else {
            type = .typeUnkown
        }
        self.type = type
    }

    var typeName: String {
        if type == .typeArray {
            return "\(key.capitalized)ArrayNode"
        } else if type == .typeDictionary {
            return "\(key.capitalized)Node"
        } else {
            return "\(type.rawValue)"
        }
    }

    override var description: String {
        return "let:\(key):\(typeName)"
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let node = object as? Node else {
            return false
        }
        return node.key == self.key
    }
}
