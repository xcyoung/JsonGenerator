//
//  EntryCommand.swift
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
class EntryCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        exec(with: invocation, completionHandler: completionHandler)
    }

    private func exec(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
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

        let entry = rules.map { (oneNode) -> [String] in
            let entryNode = EntryNode.init()
            
            oneNode.enumerated().forEach { (node) in
                if node.offset == 0 {
                    entryNode.nodeName = node.element
                } else {
                    entryNode.addAttributes(rule: node.element)
                }
            }
            return entryNode.generateEntry()
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

