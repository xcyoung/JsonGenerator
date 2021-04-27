//
//  SourceEditorExtension.swift
//  Codable
//
//  Created by 肖楚🐑 on 2021/4/17.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {

    /*
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
    }
    */

    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        return [
            [
                XCSourceEditorCommandDefinitionKey.nameKey: "Rule",
                XCSourceEditorCommandDefinitionKey.classNameKey: SourceEditorCommand.className(),
                XCSourceEditorCommandDefinitionKey.identifierKey: "Rule",
            ],
            [
                XCSourceEditorCommandDefinitionKey.nameKey: "Entry",
                XCSourceEditorCommandDefinitionKey.classNameKey: SourceEditorCommand.className(),
                XCSourceEditorCommandDefinitionKey.identifierKey: "Entry",
            ]
        ]
    }

}
