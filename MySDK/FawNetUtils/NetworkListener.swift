//
//  NetworkListener.swift
//  FawSdk
//
//  Created by season on 2018/9/17.
//  Copyright © 2018年 FAW. All rights reserved.
//

import Foundation
import Alamofire

/// 网络状态枚举
enum NetworkType {
    case
    unknown,
    notReachable,
    wifi,
    mobile
}

// MARK: - 网络状态枚举的字符串化
extension NetworkType: CustomStringConvertible {
    var description: String {
        switch self {
        case .unknown: return "未知"
        case .notReachable: return "没有网络"
        case .wifi: return "wifi网络"
        case .mobile: return "手机网络"
        }
    }
}

// MARK: - 获取网络状态
extension NetworkType {
    fileprivate static func getType(by reachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus) -> NetworkType {
        let status: NetworkType
        switch reachabilityStatus {
        case .unknown:
            status = .unknown
        case .notReachable:
            status = .notReachable
        case .reachable(NetworkReachabilityManager.ConnectionType.ethernetOrWiFi):
            status = .wifi
        case .reachable(NetworkReachabilityManager.ConnectionType.wwan):
            status = .mobile
        }
        return status
    }
}

/// 网络监听器
class NetworkListener {
    
    /// 监听管理器
    private let manager = NetworkReachabilityManager()!
    
    /// 是否在监听
    private var isListening = false
    
    /// 单例
    static let shared = NetworkListener()
    private init() {}
    
    /// 是否连接上了
    var isReachable: Bool {
        return manager.isReachable
    }
    
    /// 是手机信号?
    var isMobile: Bool {
        return manager.isReachableOnWWAN
    }
    
    /// 是Wifi
    var isWifi: Bool {
        return manager.isReachableOnEthernetOrWiFi
    }
    
    /// 开始监听
    func startListen() {
        if isListening { return }
        isListening = manager.startListening()
    }
    
    /// 结束监听
    func stopListen() {
        if !isListening { return }
        manager.stopListening()
        isListening = false
    }
    
    /// 获取监听的网络状态
    var  status: NetworkType {
        let reachabilityStatus = manager.networkReachabilityStatus
        return NetworkType.getType(by: reachabilityStatus)
    }
    
    /// 刷新状态
    @discardableResult
    public func refreshStatus() -> NetworkType {
        let reachabilityStatus = manager.networkReachabilityStatus
        let newStatus = NetworkType.getType(by: reachabilityStatus)
        return newStatus
    }
    
    /// 获取网络状态,一旦改变就会进行回调,可以说是全局的监听
    ///
    /// - Parameter callback: 回调
    func listenStatus(_ callback: @escaping (_ type: NetworkType) -> ()) {
        manager.listener = { status in
            let status = NetworkType.getType(by: status)
            callback(status)
        }
        startListen()
    }
}
