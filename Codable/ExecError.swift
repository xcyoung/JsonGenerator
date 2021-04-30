//
//  ExecError.swift
//  Codable
//
//  Created by 肖楚🐑 on 2021/4/30.
//

import Foundation
class ExecError: NSError {
    class func create(_ message: String) -> ExecError {
        let domain = "me.xcyoung.JsonGenerator.Codable.error"
        let userInfo = [NSLocalizedDescriptionKey: description]
        return ExecError.init(domain: domain, code: -1, userInfo: userInfo)
    }
}
