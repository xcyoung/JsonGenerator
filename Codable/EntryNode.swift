//
//  EntryNode.swift
//  Codable
//
//  Created by 肖楚🐑 on 2021/4/30.
//

import Foundation
class EntryNode: NSObject {
    var nodeName: String = ""
    var needDecoder: Bool = false
    var nodeParams: [String] = [String]()
    var nodeDecoders: [String] = [String]()

    func generateEntry() -> [String] {
        var entry: [String] = [String]()
        entry.append("class \(nodeName): NSObject, Codable {")
        entry.append(contentsOf: nodeParams.map({ "    \($0)" }))
        if needDecoder {
            entry.append("    required init(from decoder: Decoder) throws{")
            entry.append("        let container = try decoder.container(keyedBy: CodingKeys.self)")
            entry.append(contentsOf: nodeDecoders.map({ "        \($0)" }))
            entry.append("    }")
        }
        entry.append("\n")
        entry.append("}")
        return entry
    }

    func addAttributes(rule: String) {
        //  TODO: emmmmm，这个判断有点扯
        if rule.contains("?:"), !needDecoder {
            needDecoder = true
        }
        let entrySplit: [String] = rule.split(separator: ":").map({ "\($0)" })
        if entrySplit.count < 3 {

        } else if entrySplit.count == 3 {
            let result = parseEntryCount3(entrySplit: entrySplit)
            nodeParams.append(result.define)
            nodeDecoders.append(result.decodeCode)
        } else if entrySplit.count == 4 {
            let result = parseEntryCount4(entrySplit: entrySplit)
            nodeParams.append(result.define)
            nodeDecoders.append(result.decodeCode)
        } else {
            let result = parseEntryCount5(entrySplit: entrySplit)
            nodeParams.append(result.define)
            nodeDecoders.append(result.decodeCode)
        }
    }

    private func parseEntryCount3(entrySplit: [String]) -> (define: String, decodeCode: String) {
        let type: String
        if entrySplit[2].contains("Array") {
            type = "[\(entrySplit[2])]"
        } else {
            type = entrySplit[2]
        }
        let define = "\(entrySplit[0]) \(entrySplit[1]): \(type)"
        let decodeCode = "self.\(entrySplit[1]) = try container.decode(\(type).self, forKey: .\(entrySplit[1]))"
        return (define, decodeCode)
    }

    private func parseEntryCount4(entrySplit: [String]) -> (define: String, decodeCode: String) {
        let type: String
        if entrySplit[2].contains("Array") {
            type = "[\(entrySplit[2])]"
        } else {
            type = entrySplit[2]
        }

        let define: String
        let decodeCode: String
        if entrySplit[3] == "?" {
            define = "\(entrySplit[0]) \(entrySplit[1]): \(type)?"
            decodeCode = "self.\(entrySplit[1]) = try container.decodeIfPresent(\(type).self, forKey: .\(entrySplit[1]))"
        } else {
            define = "\(entrySplit[0]) \(entrySplit[1]): \(type)\(entrySplit[0] == "let" ? "" : " = \(entrySplit[3])")"
            decodeCode = "self.\(entrySplit[1]) = try container.decodeIfPresent(\(type).self, forKey: .\(entrySplit[1])) ?? \(entrySplit[3])"
        }

        return (define, decodeCode)
    }

    private func parseEntryCount5(entrySplit: [String]) -> (define: String, decodeCode: String) {
        let type: String
        if entrySplit[2].contains("Array") {
            type = "[\(entrySplit[2])]"
        } else {
            type = entrySplit[2]
        }

        let define: String
        let decodeCode: String
        if entrySplit[3] == "?" {
            define = "\(entrySplit[0]) \(entrySplit[1]): \(type)"
            decodeCode = "self.\(entrySplit[1]) = try container.decodeIfPresent(\(type).self, forKey: .\(entrySplit[1])) ?? \(entrySplit[4])"
        } else {
            define = "\(entrySplit[0]) \(entrySplit[1]): \(type)"
            decodeCode = "self.\(entrySplit[1]) = try container.decodeIfPresent(\(type).self, forKey: .\(entrySplit[1])) ?? \(entrySplit[3])"
        }

        return (define, decodeCode)
    }
}
