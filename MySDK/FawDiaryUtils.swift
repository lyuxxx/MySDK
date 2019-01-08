//
//  FawDiaryUtils.swift
//  FawSdk
//
//  Created by season on 2018/11/27.
//  Copyright © 2018 FAW. All rights reserved.
//

import Foundation
import UIKit

/// 日志收集Utils
public class FawDiaryUtils {
    
    //MARK:- 对外属性与方法
    
    /// 日志单元单例
    public static let share = FawDiaryUtils()
    private init() {}
    
    /// 获取崩溃日志字符串
    ///
    /// - Returns: 崩溃日志字符串
    public func getExceptionLog() -> String? {
        let fileUrl = URL(fileURLWithPath: getExceptionPath())
        guard let data = try? Data.init(contentsOf: fileUrl) else {
            return nil
        }
        let exceptionLog = String(data: data, encoding: .utf8)
        return exceptionLog
    }
    
    /// 获取崩溃日志路径
    ///
    /// - Returns: 崩溃日志路径
    public func getExceptionPath() -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        let filePath = documentPath + "/" + exceptionLog
        return filePath
    }
    
    //MARK:- 对内属性与方法
    
    /// 设置崩溃日志文件格式
    var exceptionLog = "Exception.log"
    
    /// 设置崩溃日志handle
    func setExceptionHandler() {
        NSSetUncaughtExceptionHandler(uncaughtExceptionHandler())
    }
    
}

/// 崩溃异常的获取
///
/// - Parameter exception: exception
private func uncaughtExceptionHandler() -> (@convention(c) (NSException) -> Void) {
    
    return { (exception) -> Void in
        let array = exception.callStackSymbols
        let reason = exception.reason ?? "Unknown"
        let name = exception.name.rawValue
        let date = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "YYYY/MM/dd hh:mm:ss SS"
        let strNowTime = timeFormatter.string(from: date)
        let exceptionLog = String(format: "========异常错误报告========\ntime:%@\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@\nappAndDeviceInfo:\n%@\n",strNowTime,name,reason,array.joined(separator: "\n"),appAndDeviceInfo())
        let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        let filePath = documentPath + "/" + FawDiaryUtils.share.exceptionLog
        
        if !FileManager.default.fileExists(atPath: filePath) {
            
            do {
                try exceptionLog.write(toFile: filePath, atomically: true, encoding: .utf8)
            }catch {
                
            }
        }else {
            let outFile = FileHandle(forWritingAtPath: filePath)
            outFile?.seekToEndOfFile()
            if let data = exceptionLog.data(using: .utf8) {
                outFile?.write(data)
            }
            outFile?.closeFile()
        }
    }
}

/// app与设备信息
///
/// - Returns: 信息字符串
func appAndDeviceInfo() -> String {
    
    let deviceManufacturer = "deviceManufacturer: Apple"
    let systemType = "systemType: iOS"
    let deviceCode = "deviceCode: \(UIDevice.current.identifierForVendor?.uuidString ?? "unknown")"

    var deviceModel: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)

        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()
    deviceModel = "deviceModel: \(deviceModel)"

    let systemVersion = "systemVersion: \(UIDevice.current.systemVersion)"
    let packageName = "packageName: \(Bundle.main.infoDictionary?["CFBundleDisplayName"] ?? "unknown")"
    let versionName = "versionName: \(Bundle.main.infoDictionary?["CFBundleDisplayName"] ?? "unknown")"
    let versionCode = "versionCode: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknow")"
    let info = [deviceManufacturer, systemType, deviceCode, deviceModel, systemVersion, packageName, versionName, versionCode]
    return info.joined(separator: "\n")
}
