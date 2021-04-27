//
//  EntryCommand.swift
//  Codable
//
//  Created by 肖楚🐑 on 2021/4/28.
//

import Foundation
import XcodeKit

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

