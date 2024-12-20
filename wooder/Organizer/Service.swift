//
//  Service.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/17.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation

class Service: NSObject {

    struct Request {
        let action: String?
        let arg1: String?
        let arg2: String?
        let input: String?
        let output: String?
    }
    
    struct Action {
        let aliasNames: [String]
        let actionName: String
        var usage: String = ""
    }
    
    let request: Request
    
    required init(request: Request) {
        self.request = request
    }
    
    class var name: String {
        return ""
    }
    
    class var aliasNames: [String] {
        return []
    }
    
    var actions: [Action] {
        return []
    }

    func validate() -> (Bool, String?) {
        return (true, nil)
    }
    
    func run() {
        var actionName = ""
        if let value = request.action {
            actionName = value
        }
        var targetAction: Action?
        let lowerActionName = actionName.lowercased()
        for action in self.actions {
            if action.aliasNames.contains(where: { name in
                return name.lowercased() == lowerActionName
            }) {
                targetAction = action
                break
            }
        }
        if targetAction == nil {
            targetAction = self.actions.first
        }
        guard let action = targetAction else {
            return
        }
//        print("[\(type(of:self).name).\(action.actionName)]")
        let sel = NSSelectorFromString(action.actionName)
        self.performSelector(onMainThread: sel, with: nil, waitUntilDone: true)
    }
    
    func send(service:String, action: String, body: [AnyHashable:Any]? = nil, payload:Data? = nil) -> IPCResponse? {
        let request = IPCRequest(service: service, action: action, body: body, payload: payload)
        if let response = IPCClient.shared.request(request) {
            return response
        }
        return nil
    }
    
    
    ///response
    func retSuccess(_ msg: String = "success") {
        print(msg)
    }
    
    func retSuccess(value: Any) {
        if let array = value as? [Any] {
            let msg = JsonUtil.json(array) ?? ""
            retSuccess(msg)
        } else if let dicts = value as? [AnyHashable:Any] {
            let msg = JsonUtil.json(dicts) ?? ""
            retSuccess(msg)
        } else {
            retSuccess("\(value)")
        }
    }
    
    func retError(_ msg: String = "error") {
        print(msg)
    }
    
}
