//
//  FawSdk.swift
//  FawSdk
//
//  Created by season on 2018/11/29.
//  Copyright © 2018 FAW. All rights reserved.
//

import Foundation
import Kingfisher
import Alamofire

/// FawSdk类,用于各个模块的初始化以及参数配置
public class FawSdk {
    
    //MARK:- 对外方法和属性
    
    /// FawSdk初始化的单例方法
    public static let share = FawSdk()
    private init() {
        let _ = FawDiaryUtils.share
        let _ = FawUserBehaviorUtils.share
        let _ = FawImageLoadUtils.share
        let _ = NetworkListener.shared.listenStatus { (type) in  print(type) }
    }
    
    /// 是否开启崩溃日志拦截
    ///
    /// - Parameter isOpenExceptionHandler: 是否开启 传入Bool值 true为开启
    /// - Returns: 对象自己
    @discardableResult
    public func crashSwitchOn(_ isOpenExceptionHandler: Bool) -> FawSdk {
        self.isOpenExceptionHandler = isOpenExceptionHandler
        if isOpenExceptionHandler {
            FawDiaryUtils.share.setExceptionHandler()
        }
        return FawSdk.share
    }
    
    /// 添加基本请求网址
    ///
    /// - Parameter baseUrl: 基本请求网址
    /// - Returns: 对象自己
    @discardableResult
    public func setBaseUrl(_ baseUrl: String) -> FawSdk {
        self.baseUrl = baseUrl
        return FawSdk.share
    }
    
    /// 添加图片的内存缓存大小
    ///
    /// - Parameter maxImageCacheSize: 缓存大小 MB为单位 例如传入50 * 1024 * 1024 那么缓存为50MB
    /// - Returns: 对象自己
    @discardableResult
    public func setMaxImageMemoryCacheSize(_ maxMemoryCost: UInt) -> FawSdk {
        if maxMemoryCost <= 0 {
            KingfisherManager.shared.cache.maxMemoryCost = 50 * 1024 * 1024
            return self
        }
        self.maxMemoryCost = maxMemoryCost
        KingfisherManager.shared.cache.maxMemoryCost = maxMemoryCost
        return FawSdk.share
    }
    
    /// 添加的请求头
    ///
    /// - Parameter addHeads: 请求头
    /// - Returns: 对象自己
    @discardableResult
    public func addHeads(_ addHeads: HTTPHeaders) -> FawSdk {
        addHeads.forEach { (key, value) in
            self.addHeads[key] = value
        }
        return FawSdk.share
    }
    
    /// 设置认证策略
    ///
    /// - Parameters:
    ///   - trustPolicy: 服务器的认证策略
    ///   - p12Path: p12证书路径
    ///   - password: p12证书的密码
    /// - Returns: 对象自己
    @discardableResult
    public func challenge(trustPolicy: FawServerTrustPolicy, p12Path: String, p12password: String) -> FawSdk {
        HttpUtils.challenge(sessionManager: SessionManager.main, trustPolicy: trustPolicy, p12Path: p12Path, p12password: p12password)
        return FawSdk.share
    }
    
    /// 更新认证策略
    ///
    /// - Parameters:
    ///   - trustPolicy: 服务器的认证策略
    ///   - p12Path: p12证书路径
    ///   - password: p12证书的密码
    /// - Returns: 对象自己
    @discardableResult
    public func updateChallenge(trustPolicy: FawServerTrustPolicy, p12Path: String, p12password: String) -> FawSdk {
        return challenge(trustPolicy: trustPolicy, p12Path: p12Path, p12password: p12password)
    }
    
    //MARK:- 对内方法和属性
    
    /// 是否开启崩溃日志拦截
    var isOpenExceptionHandler = false
    
    /// 是否开启按钮点击统计
    var isOpenButtonClickStatistics = false
    
    /// 是否开启页面停留统计
    var isOpenViewControllerHoldStatistics = false
    
    /// 添加控制器停留时间白名单
    var whiteList = [String]()
    
    /// 添加基本请求网址
    var baseUrl = ""
    
    /// 添加NetUtils.defaul的中的请求头中的参数
    var addHeads: HTTPHeaders = [:]
    
    /// 添加图片的内存缓存大小
    var maxMemoryCost: UInt = 50 * 1024 * 1024
    
}
