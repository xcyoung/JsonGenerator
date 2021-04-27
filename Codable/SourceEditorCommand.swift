//
//  SourceEditorCommand.swift
//  Codable
//
//  Created by 肖楚🐑 on 2021/4/17.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    var ruleLine: Int = 0
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) -> Void {
        if invocation.commandIdentifier == "Rule" {
            rule(with: invocation, completionHandler: completionHandler)
        } else if invocation.commandIdentifier == "Entry" {
            entry(with: invocation, completionHandler: completionHandler)
        }
    }

    func rule(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let lines = invocation.buffer.lines

        guard let firstSelection = invocation.buffer.selections.firstObject as? XCSourceTextRange,
            firstSelection.start.line != firstSelection.end.line else {
            return
        }
        var json: String = ""
        for lineIndex in firstSelection.start.line...firstSelection.end.line {
            if let line = lines[lineIndex] as? String {
                json += line
            }
        }
        print("生成的json:\(json)")
        let jsonData = json.data(using: .utf8)
        guard let jsonDic = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers) as?
        [String: Any] else {
            return
        }

        let nodes = transformNode(jsonDic: jsonDic)
        let rule = transformRule(nodes: nodes)

        lines[firstSelection.start.line] = "\"\"\""
        lines[firstSelection.start.line + 1] = "Node"
        let ruleStartLine = firstSelection.start.line + 2
        for i in 0..<rule.count {
            lines[ruleStartLine + i] = rule[i]
        }
        lines[ruleStartLine + rule.count] = "\"\"\""
        for i in ruleStartLine + rule.count + 1..<lines.count {
            lines[i] = ""
        }
        completionHandler(nil)
    }

    func transformNode(jsonDic: [String: Any]) -> [Node] {
        let children = jsonDic.reduce(into: [Node]()) { (children, dic) in
            let node = Node.init(key: dic.key, value: dic.value)
            if node.type == .typeDictionary, let valueDic = dic.value as? [String: Any] {
                let childrenNodes = transformNode(jsonDic: valueDic)
                node.children.append(contentsOf: childrenNodes)
            } else if node.type == .typeArray, let valueArray = dic.value as? Array<[String: Any]> {
                if let max = valueArray.max(by: { (dic1, dic2) -> Bool in
                    return dic1.count < dic2.count
                }) {
                    let childrenNodes = transformNode(jsonDic: max)
                    node.children.append(contentsOf: childrenNodes)
                }
            }
            children.append(node)
        }
        return children
    }

    func transformRule(nodes: [Node]) -> [String] {
        var rule = [String]()
        var childrenRule = [String]()
        nodes.forEach { (node) in
            if !node.children.isEmpty {
                rule.append(node.description)
                let rules = transformRule(nodes: node.children)
                childrenRule.append("\(node.typeName)")
                childrenRule.append(contentsOf: rules)
            } else {
                rule.append(node.description)
            }
        }
        if !childrenRule.isEmpty {
            rule.append("")
        }
        rule.append(contentsOf: childrenRule)
        return rule
    }

    func entry(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let lines = invocation.buffer.lines

        guard let firstSelection = invocation.buffer.selections.firstObject as? XCSourceTextRange,
            firstSelection.start.line != firstSelection.end.line else {
            return
        }

        let selectionLines = lines.subarray(with: NSRange.init(location: firstSelection.start.line, length: firstSelection.end.line - firstSelection.start.line + 1)).compactMap { (any) -> String? in
            if let selection = any as? String, selection != "\"\"\"\n" {
                return selection.replacingOccurrences(of: "\n", with: "")
            } else {
                return nil
            }
        }

        let rules = selectionLines.split(separator: "")

        let entry = rules.map { (array) -> [String] in
            var initParams = [String]()
            var initCode = [String]()
            var a = array.enumerated().map { (entry) -> String in
                if entry.offset == 0 {
                    return "class \(entry.element): NSObject, Codable {"
                } else {
                    let entrySplit = entry.element.split(separator: ":").map({ "\($0)" })
                    initParams.append("\(entrySplit[0]): \(entrySplit[1])")
                    initCode.append("self.\(entrySplit[0]) = \(entrySplit[0])")
                    return "    let \(entrySplit[0]): \(entrySplit[1])"
                }
            }
            a.append("\n")
            initParams.enumerated().forEach { (entry) in
                if entry.offset == 0 {
                    a.append("    init(\(entry.element),")
                } else if entry.offset == initParams.count - 1 {
                    a.append("         \(entry.element)) {")
                } else {
                    a.append("         \(entry.element),")
                }
            }
            initCode.enumerated().forEach { (entry) in
                a.append("         \(entry.element)")
            }
            a.append("    }")
            a.append("\n")
            a.append("}")
            return a
        }
        var entryLine = firstSelection.start.line
        entry.forEach { (entry) in
            entry.forEach { (code) in
                lines[entryLine] = code
                entryLine += 1
            }
        }

        completionHandler(nil)
    }
}
