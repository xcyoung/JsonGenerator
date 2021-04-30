//
//  RuleCommand.swift
//  Codable
//
//  Created by 肖楚🐑 on 2021/4/28.
//

import Foundation
import XcodeKit
/**
    """
    class/struct

    let/var:Key:Type(:?:Default)
    """
*/
class RuleCommand: NSObject, XCSourceEditorCommand {
    static let TERMINATOR: String = "\"\"\""
    static let SEPARATOR: String = ""

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        exec(with: invocation, completionHandler: completionHandler)
    }

    private func exec(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let lines = invocation.buffer.lines

        guard let firstSelection = invocation.buffer.selections.firstObject as? XCSourceTextRange,
            firstSelection.start.line != firstSelection.end.line else {
            completionHandler(nil)
            return
        }

        let json = lines.subarray(with: NSRange.init(location: firstSelection.start.line, length: firstSelection.end.line - firstSelection.start.line + 1)).reduce(into: "") { (res, line) in
            if let line = line as? String {
                res += line
            }
        }
        INFO(items: "获取选中部分生成的json", json)

        let jsonData = json.data(using: .utf8)
        guard let jsonDic = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers) as?
        [String: Any] else {
            completionHandler(ExecError.create("selection should be json format"))
            return
        }

        let nodes = transformNode(jsonDic: jsonDic)
        let rule = transformRule(nodes: nodes)

        lines[firstSelection.start.line] = RuleCommand.TERMINATOR
        lines[firstSelection.start.line + 1] = "Node"
        let ruleStartLine = firstSelection.start.line + 2
        for i in 0..<rule.count {
            lines[ruleStartLine + i] = rule[i]
        }
        lines[ruleStartLine + rule.count] = RuleCommand.TERMINATOR
        //  fill the rest
        for i in ruleStartLine + rule.count + 1..<firstSelection.end.line {
            lines[i] = RuleCommand.SEPARATOR
        }
        completionHandler(nil)
    }

    private func transformNode(jsonDic: [String: Any]) -> [Node] {
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

    private func transformRule(nodes: [Node]) -> [String] {
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
            rule.append(RuleCommand.SEPARATOR)
        }
        rule.append(contentsOf: childrenRule)
        return rule
    }
}
