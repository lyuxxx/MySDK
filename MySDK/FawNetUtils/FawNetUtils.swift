//
//  HttpUtils.swift
//  FawSdk
//
//  Created by season on 2018/11/29.
//  Copyright © 2018 FAW. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

/// 网络请求FawNetUtils
public class FawNetUtils {
    
    /// 请求参数设置
    let httpConfig: FawHttpConfig
    
    /// Alamofire.SessionManager
    let sessionManager: SessionManager
    
    /// 请求头
    var headers: HTTPHeaders = [:]
    
    /// 最终的请求网址
    var url = ""
    
    /// 默认的网络请求实体,设置的默认超时时间为15s,仅添加了在FawSdk类中添加的公共请求头,没有传入api.
    /// 不要使用以下方法进行请求!!!
    /// request(parameters: Parameters? = nil, callbackHandler: CallbackHandler)
    /// requestByObjectMapper<T: Mappable>(parameters: Parameters? = nil, callbackHandler: MappableCallbackHandler<T>)进行请求!
    /// upload(uploadStream: UploadStream, parameters: Parameters? = nil, size: CGSize?, mimeType: MimeType, callbackHandler: UploadCallbackHandler)
    /// download(parameters: Parameters? = nil, callbackHandler: DownloadCallbackHandler)
    public static let `default` = FawNetUtils()
    
    /// 初始化方法
    ///
    /// - Parameter FawHttpConfig: 请求参数设置
    public init(httpConfig: FawHttpConfig) {
        
        self.httpConfig = httpConfig
        
        //  headers的处理
        var headers = ["Content-Type": "application/json"]
        headers.merge(httpConfig.addHeads) { (current, new) -> String in return new }
        headers.merge(SessionManager.defaultHTTPHeaders) { (current, new) -> String in return new }
        print("headers: \(headers)")
        self.headers = headers
        
        //  url的处理
        if httpConfig.useApi {
            url = FawSdk.share.baseUrl + httpConfig.api
        }
        
        if httpConfig.useUrl {
            url = httpConfig.url
        }
        
        //  处理SessionManager
        let manager: SessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = httpConfig.timeout
            configuration.httpAdditionalHeaders = headers
            return SessionManager(configuration: configuration)
        }()
        
        //  设置sessionManager的认证策略
        if let trustPolicy = httpConfig.trustPolicy, let p12Path = httpConfig.p12Path, let p12password = httpConfig.p12password {
            /// 设置创建的manager的验证回调
            HttpUtils.challenge(sessionManager: manager, trustPolicy: trustPolicy, p12Path: p12Path, p12password: p12password)
        }
        
        //  将创建的manager赋值给SessionManager.custom以保证对象一直存活
        SessionManager.custom = manager
        sessionManager = SessionManager.custom
    }
    
    /// FawNetUtils.default的初始化方法,私有的初始化方法
    private init() {
        httpConfig = FawHttpConfig.Builder().addHeads(FawSdk.share.addHeads).constructor
        sessionManager = SessionManager.main
    }
    
    deinit {
        #if DEBUG
        print("FawNetUtils被销毁了")
        #endif
    }
}

// MARK: - 请求方法,回调为基本数据类型
extension FawNetUtils {
    
    /// 自定义请求方法
    /// 使用FawNetUtils.default请求时不要使用该方法,因为没有将Api传入
    /// - Parameters:
    ///   - parameters: 请求参数
    ///   - callbackHandler: 回调
    public func request(parameters: Parameters? = nil, callbackHandler: FawBasicCallbackHandler) {
        /// 检查url为非空串
        guard url.isNotBlank else { assert(false, "url不能为空"); return }
        /// body的处理
        let params = requestParametersSet(parameters: parameters)
        /// 自定义的请求
        HttpUtils.request(sessionManager: sessionManager, method: httpConfig.requestType, url: url, parameters: params, headers: headers, callbackHandler: callbackHandler)
    }
    
    /// get请求方法
    ///
    /// - Parameters:
    ///   - api: 具体业务Api
    ///   - parameters: 请求参数
    ///   - callbackHandler: 回调
    public func get(api: String, parameters: Parameters? = nil, callbackHandler: FawBasicCallbackHandler) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.request(sessionManager: sessionManager, method: .get, url: FawSdk.share.baseUrl + api, parameters: parameters, headers: headers, callbackHandler: callbackHandler)
    }
    
    /// post请求方法
    ///
    /// - Parameters:
    ///   - api: 具体业务Api
    ///   - parameters: 请求参数
    ///   - callbackHandler: 回调
    public func post(api: String, parameters: Parameters? = nil, callbackHandler: FawBasicCallbackHandler) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.request(sessionManager: sessionManager, method: .post, url: FawSdk.share.baseUrl + api, parameters: parameters, headers: headers, callbackHandler: callbackHandler)
    }
    
    /// put请求方法
    ///
    /// - Parameters:
    ///   - api: 具体业务Api
    ///   - parameters: 请求参数
    ///   - callbackHandler: 回调
    public func put(api: String, parameters: Parameters? = nil, callbackHandler: FawBasicCallbackHandler) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.request(sessionManager: sessionManager, method: .put, url: FawSdk.share.baseUrl + api, parameters: parameters, headers: headers, callbackHandler: callbackHandler)
    }
    
    /// delete请求方法
    ///
    /// - Parameters:
    ///   - api: 具体业务Api
    ///   - parameters: 请求参数
    ///   - callbackHandler: 回调
    public func delete(api: String, parameters: Parameters? = nil, callbackHandler: FawBasicCallbackHandler) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.request(sessionManager: sessionManager, method: .delete, url: FawSdk.share.baseUrl + api, parameters: parameters, headers: headers, callbackHandler: callbackHandler)
    }
}

// MARK: - 请求方法,回调为泛型的数据类型(可直达模型)
extension FawNetUtils {
    /// 自定义请求方法
    /// 使用FawNetUtils.default请求时不要使用该方法,因为没有将Api传入
    /// - Parameters:
    ///   - parameters: 请求参数
    ///   - callbackHandler: 回调
    public func requestByObjectMapper<T: Mappable>(parameters: Parameters? = nil, callbackHandler: FawMappableCallbackHandler<T>) {
        /// 检查url为非空串
        guard url.isNotBlank else { assert(false, "url不能为空"); return }
        /// body的处理
        let params = requestParametersSet(parameters: parameters)
        /// 自定义的请求
        HttpUtils.requestObjectMapper(sessionManage: sessionManager, method: httpConfig.requestType, url: url, parameters: params, headers: headers, callbackHandler: callbackHandler)
    }
    
    /// get请求方法
    ///
    /// - Parameters:
    ///   - api: 具体业务Api
    ///   - parameters: 请求参数
    ///   - callbackHandler: 回调
    public func getByObjectMapper<T: Mappable>(api: String, parameters: Parameters? = nil, callbackHandler: FawMappableCallbackHandler<T>) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.requestObjectMapper(sessionManage: sessionManager, method: .get, url: FawSdk.share.baseUrl + api, parameters: parameters, headers: headers, callbackHandler: callbackHandler)
    }
    
    /// post请求方法
    ///
    /// - Parameters:
    ///   - api: 具体业务Api
    ///   - parameters: 请求参数
    ///   - callbackHandler: 回调
    public func postByObjectMapper<T: Mappable>(api: String, parameters: Parameters? = nil, callbackHandler: FawMappableCallbackHandler<T>) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.requestObjectMapper(sessionManage: sessionManager, method: .post, url: FawSdk.share.baseUrl + api, parameters: parameters, headers: headers, callbackHandler: callbackHandler)
    }
    
    /// put请求方法
    ///
    /// - Parameters:
    ///   - api: 具体业务Api
    ///   - parameters: 请求参数
    ///   - callbackHandler: 回调
    public func putByObjectMapper<T: Mappable>(api: String, parameters: Parameters? = nil, callbackHandler: FawMappableCallbackHandler<T>) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.requestObjectMapper(sessionManage: sessionManager, method: .put, url: FawSdk.share.baseUrl + api, parameters: parameters, headers: headers, callbackHandler: callbackHandler)
    }
    
    /// delete请求方法
    ///
    /// - Parameters:
    ///   - api: 具体业务Api
    ///   - parameters: 请求参数
    ///   - callbackHandler: 回调
    public func deleteByObjectMapper<T: Mappable>(api: String, parameters: Parameters? = nil, callbackHandler: FawMappableCallbackHandler<T>) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.requestObjectMapper(sessionManage: sessionManager, method: .delete, url: FawSdk.share.baseUrl + api, parameters: parameters, headers: headers, callbackHandler: callbackHandler)
    }
}

// MARK: - 文件上传请求
extension FawNetUtils {
    
    /// 自定义上传请求方法
    /// 使用FawNetUtils.default请求时不要使用该方法,因为没有将Api传入
    /// - Parameters:
    ///   - uploadStream: 上传的数据流
    ///   - parameters: 请求字段
    ///   - size: 文件的size 长宽
    ///   - mimeType: 文件类型 详细看FawMimeType枚举
    ///   - callbackHandler: 上传回调
    public func upload(uploadStream: FawUploadStream,
                       parameters: Parameters? = nil,
                       size: CGSize? = nil,
                       mimeType: FawMimeType,
                       callbackHandler: FawUploadCallbackHandler) {
        /// 检查url为非空串
        guard url.isNotBlank else { assert(false, "url不能为空"); return }
        /// body的处理
        let params = requestParametersSet(parameters: parameters)
        /// 自定义的上传请求
        HttpUtils.uploadData(sessionManager: sessionManager, url: url, uploadStream: uploadStream, parameters: params, headers: headers, size: size, mimeType: mimeType, callbackHandler: callbackHandler)
    }
    
    /// 上传请求
    ///
    /// - Parameters:
    ///   - api: 具体业务Api
    ///   - uploadStream: 上传的数据流
    ///   - parameters: 请求字段
    ///   - size: 文件的size 长宽
    ///   - mimeType: 文件类型 详细看FawMimeType枚举
    ///   - callbackHandler: 上传回调
    public func upload(api: String,
                       uploadStream: FawUploadStream,
                       parameters: Parameters? = nil,
                       size: CGSize? = nil,
                       mimeType: FawMimeType,
                       callbackHandler: FawUploadCallbackHandler) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.uploadData(sessionManager: sessionManager, url: FawSdk.share.baseUrl + api, uploadStream: uploadStream, parameters: parameters, headers: headers, size: size, mimeType: mimeType, callbackHandler: callbackHandler)
    }
}

// MARK: - 文件下载请求
extension FawNetUtils {
    
    /// 自定义下载请求
    /// 使用FawNetUtils.default请求时不要使用该方法,因为没有将Api传入
    /// - Parameters:
    ///   - parameters: 请求字段
    ///   - callbackHandler: 下载回调
    public func download(parameters: Parameters? = nil, callbackHandler: FawDownloadCallbackHandler) {
        /// 检查url为非空串
        guard url.isNotBlank else { assert(false, "url不能为空"); return }
        /// body的处理
        let params = requestParametersSet(parameters: parameters)
        /// 自定义的上传请求
        HttpUtils.downloadData(sessionManager: sessionManager, url: url, parameters: params, headers: headers, callbackHandler: callbackHandler)
    }
    
    /// 下载请求
    ///
    /// - Parameters:
    ///   - api:
    ///   - parameters: 具体业务Api
    ///   - callbackHandler: 下载回调
    public func download(api: String, parameters: Parameters? = nil, callbackHandler: FawDownloadCallbackHandler) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.downloadData(sessionManager: sessionManager, url: FawSdk.share.baseUrl + api, parameters: parameters, headers: headers, callbackHandler: callbackHandler)
    }
}

// MARK: - 请求任务的暂停/恢复/取消
extension FawNetUtils {
    /// 通过url暂停请求
    ///
    /// - Parameter url: 请求网址
    public static func suspendRequestByUrl(_ url: String) {
        /// 检查url为非空串
        guard url.isNotBlank else { assert(false, "url不能为空"); return }
        HttpUtils.suspendRequest(url: url)
    }
    
    /// 通过url恢复请求
    ///
    /// - Parameter url: 请求网址
    public static func resumeRequestByUrl(_ url: String) {
        /// 检查url为非空串
        guard url.isNotBlank else { assert(false, "url不能为空"); return }
        HttpUtils.resumeRequest(url: url)
    }
    
    /// 通过url取消请求
    ///
    /// - Parameter url: 请求网址
    public static func cancelRequestByUrl(_ url: String) {
        /// 检查url为非空串
        guard url.isNotBlank else { assert(false, "url不能为空"); return }
        HttpUtils.cancelRequest(url: url)
    }
    
    /// 通过api暂停请求
    ///
    /// - Parameter api: 具体业务Api
    public static func suspendRequestByApi(_ api: String) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.suspendRequest(url: FawSdk.share.baseUrl + api)
    }
    
    /// 通过api恢复请求
    ///
    /// - Parameter api: 具体业务Api
    public static func resumeRequestByApi(_ api: String) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.resumeRequest(url: FawSdk.share.baseUrl + api)
    }
    
    /// 通过api取消请求
    ///
    /// - Parameter api: 具体业务Api
    public static func cancelRequestByApi(_ api: String) {
        /// 检查baseUrl为非空串
        guard FawSdk.share.baseUrl.isNotBlank else { assert(false, "FawSdk.share.baseUrl不能为空"); return }
        HttpUtils.cancelRequest(url: FawSdk.share.baseUrl + api)
    }
}

// MARK: - 处理请求体的方法
extension FawNetUtils {
    
    /// 处理请求体
    ///
    /// - Parameter parameters: 追加的请求体参数
    /// - Returns: 最终的请求参数
    private func requestParametersSet(parameters: Parameters?) -> Parameters {
        var params: Parameters = [:]
        if var parameters = parameters {
            httpConfig.addBodys.forEach { (key, value) in
                parameters[key] = value
            }
            params = parameters
        }else {
            params = httpConfig.addBodys
        }
        print("params: \(params)")
        return params
    }
}

// MARK: - 定义两个SessionManager,一个是App使用的主sessionManager,一个是自定义的sessionManager.其目的是为了让FawNetUtils中的sessionManager活着
extension SessionManager {
    
    /// 主sessionManager
    static let main: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
    
    /// 自定义的sessionManager
    static var custom: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
}
