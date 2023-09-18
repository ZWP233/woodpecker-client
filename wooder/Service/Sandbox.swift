//
//  Sandbox.swift
//  wooder
//
//  Created by 张小刚 on 2023/9/18.
//  Copyright © 2023 lifebetter. All rights reserved.
//

import Foundation
import AppKit

class Sandbox: Service {
    
    override class var aliasNames: [String] {
        return [
            "sandbox", "file", "fb",
        ]
    }
    
    override class var name: String {
        return "Sandbox"
    }
    
    //wooder file Documents/file.data
    override func run() {
        var action = ""
        if let value = request.action {
            action = value
        }
        if action.isEmpty {
            action = "read"
        }
        if action == "read" {
            guard let path = request.arg1 else {
                return
            }
            let url = URL(fileURLWithPath: path)
            let filename = url.lastPathComponent
            var destPath = ""
            if let outputPath = request.output {
                if ADHFileUtil.dirExists(atPath: outputPath) {
                    destPath = outputPath.appending("/\(filename)")
                } else {
                    destPath = outputPath
                }
            } else {
                guard let downloadDir = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first else {
                    return
                }
                destPath = downloadDir.appending("/\(filename)")
            }
            var body = [AnyHashable:Any]()
            body["path"] = path
            let response = send(service: "adh.sandbox", action: "readfile", body: body, payload: nil)
            if let fileData = response.payload {
                if ADHFileUtil.fileExists(atPath: destPath) {
                    ADHFileUtil.deleteFile(atPath: destPath)
                }
                ADHFileUtil.save(fileData, atPath: destPath)
                let fileURL = URL(fileURLWithPath: destPath)
                NSWorkspace.shared.activateFileViewerSelecting([fileURL])
            } else {
                print("file \(path) not exists")
            }
        } else if action == "write" {
            guard let path = request.arg1 else {
                return
            }
            guard let inputPath = request.input else {
                return
            }
            let fileURL = URL(fileURLWithPath: inputPath)
            guard let fileData = try? Data.init(contentsOf: fileURL) else {
                return
            }
            var body = [AnyHashable:Any]()
            body["path"] = path
            let response = send(service: "adh.sandbox", action: "writefile", body: body, payload: fileData)
            guard let success = response.body?["success"] as? Int,
                    success == 1 else {
                print("write file failed")
                return
            }
            print("file write succeed")
        }
        
    }
    
}
