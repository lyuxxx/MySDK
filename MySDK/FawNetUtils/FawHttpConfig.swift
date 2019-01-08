//
//  FawHttpConfig.swift
//  FawSdk
//
//  Created by season on 2018/11/30.
//  Copyright © 2018 FAW. All rights reserved.
//

import Foundation
import Alamofire

/// 请求参数设置类
public class FawHttpConfig {
    
    /// 详细构造器
    public class Builder {
        
        /// 超时时间
        var timeout: TimeInterval = 15
        
        /// 添加请求头
        var addHeads: HTTPHeaders = [:]
        
        /// 添加请求体
        var addBodys: Parameters = [:]
        
        /// 请求Api,配合CuscSDK类中设置的setBaseUrl一起使用
        var api = ""
        
        /// 判断是否用Api
        var useApi = true
        
        /// 请求使用直接的url
        var url = ""
        
        /// 判断是否用url
        var useUrl = false
        
        /// 请求方式
        var requestType: HTTPMethod = .get
        
        /// 服务器的认证策略
        var trustPolicy: FawServerTrustPolicy?
        
        /// p12证书路径
        var p12Path: String?
        
        /// p12证书的密码
        var p12password: String?
        
        /// 初始化方法
        public init() {}
        
        /// 设置超时时间
        ///
        /// - Parameter timeout: 超时时间
        /// - Returns: 对象自己
        @discardableResult
        public func setTimeout(_ timeout: TimeInterval) -> Builder {
            self.timeout = timeout
            return self
        }
        
        /// 添加的请求头
        ///
        /// - Parameter addHeads: 请求头
        /// - Returns: 对象自己
        @discardableResult
        public func addHeads(_ addHeads: HTTPHeaders) -> Builder {
            addHeads.forEach { (key, value) in
                self.addHeads[key] = value
            }
            return self
        }
        
        /// 添加请求体
        ///
        /// - Parameter addBodys: 请求体
        /// - Returns: 对象自己
        @discardableResult
        public func addBodys(_ addBodys: Parameters) -> Builder {
            addBodys.forEach { (key, value) in
                self.addBodys[key] = value
            }
            return self
        }
        
        /// 设置请求Api
        ///
        /// - Parameter api: 请求Api
        /// - Returns: 对象自己
        @discardableResult
        public func setApi(_ api: String) -> Builder {
            self.api = api
            self.useApi = true
            self.useUrl = false
            return self
        }
        
        /// 设置请求url
        ///
        /// - Parameter url: 请求url
        /// - Returns: 对象自己
        @discardableResult
        public func setUrl(_ url: String) -> Builder {
            self.url = url
            self.useApi = false
            self.useUrl = true
            return self
        }
        
        /// 设置请求方式
        ///
        /// - Parameter requestType: 请求方法
        /// - Returns: 对象自己
        @discardableResult
        public func setRequestType(_ requestType: HTTPMethod) -> Builder {
            self.requestType = requestType
            return self
        }
        
        /// 设置认证策略
        /// 因为 cerPath/p12Path/p12password 三个是关联的,所以并没有进行单个的链式,而是一次性链式,这样统一
        /// - Parameters:
        ///   - trustPolicy: 服务器的认证策略
        ///   - p12Path: p12证书路径
        ///   - p12password: p12证书的密码
        /// - Returns: 对象自己
        @discardableResult
        public func setCertification(trustPolicy: FawServerTrustPolicy?, p12Path: String?, p12password: String?) -> Builder {
            self.trustPolicy = trustPolicy
            self.p12Path = p12Path
            self.p12password = p12password
            return self
        }
        
        /// 构造方法的计算属性方法
        public var constructor: FawHttpConfig {
            return FawHttpConfig(builder: self)
        }
        
        /// 构造方法
        ///
        /// - Returns: 一个FawHttpConfig对象
        func construction() -> FawHttpConfig {
            return FawHttpConfig(builder: self)
        }
    }
    
    /// 超时时间
    let timeout: TimeInterval
    
    /// 添加请求头
    let addHeads: HTTPHeaders
    
    /// 添加请求体
    let addBodys: Parameters
    
    /// 请求Api,配合CuscSDK类中设置的setBaseUrl一起使用
    let api: String
    
    /// 判断是否用Api
    let useApi: Bool
    
    /// 请求使用直接的url
    let url: String
    
    /// 判断是否用url
    let useUrl: Bool
    
    /// 请求方式
    let requestType: HTTPMethod
    
    /// 服务器的认证策略
    var trustPolicy: FawServerTrustPolicy?
    
    /// p12证书路径
    var p12Path: String?
    
    /// p12证书的密码
    var p12password: String?
    
    /// 初始化
    ///
    /// - Parameter builder: 详细构造器
    private init(builder: Builder) {
        self.timeout = builder.timeout
        self.addHeads = builder.addHeads
        self.addBodys = builder.addBodys
        self.api = builder.api
        self.useApi = builder.useApi
        self.url = builder.url
        self.useUrl = builder.useUrl
        self.requestType = builder.requestType
        self.trustPolicy = builder.trustPolicy
        self.p12Path = builder.p12Path
        self.p12password = builder.p12password
    }
}
