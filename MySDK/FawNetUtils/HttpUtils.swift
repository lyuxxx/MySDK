//
//  HttpUtils.swift
//  FawSdk
//
//  Created by season on 2018/11/30.
//  Copyright © 2018 FAW. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

/// HttpUtils
class HttpUtils {
    
    /// 基本网络请求
    ///
    /// - Parameters:
    ///   - sessionManager: Alamofire.SessionManager
    ///   - method: 请求方式
    ///   - url: 请求网址
    ///   - parameters: 请求字段
    ///   - headers: 请求头
    ///   - callbackHandler: 回调
    static func request(sessionManager: SessionManager = SessionManager.default,
                        method: HTTPMethod,
                        url:String,
                        parameters: Parameters? = nil,
                        headers: HTTPHeaders? = nil,
                        callbackHandler: FawBasicCallbackHandler) {
        
        print("HttpUtils ## API Request ## \(method) ## \(url) ## parameters = \(String(describing: parameters))")
        
        //  检查网络
        guard networkIsReachable() else {
            return
        }
        
        //  菊花转
        indicatorRun()
        
        let dataRequset =  sessionManager.request(url, method: method, parameters: parameters, headers: headers)
        
        //  添加请求到请求任务列表中
        requestTasks.updateValue(dataRequset, forKey: url)
        
        dataRequset.responseJSON { (responseJSON) in
            //  菊花转结束
            indicatorStop()
            
            //  有响应 请求从任务列表中移除
            requestTasks.removeValue(forKey: url)
            
            print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: responseJSON))")
            
            switch responseJSON.result {
            
            case .success(let value):
                guard let data = responseJSON.data else {
                    callbackHandler.success?(responseJSON.data, nil, value as? [String: Any])
                    return
                }
                
                guard let jsonString = String(data: data, encoding: .utf8) else {
                    callbackHandler.success?(responseJSON.data, nil, value as? [String: Any])
                    return
                }
                
                callbackHandler.success?(responseJSON.data, jsonString, value as? [String: Any])
                
            case .failure(let error):
                callbackHandler.failure?(responseJSON.data, error, responseJSON.response?.statusCode)
            }
        }
    }
}

// MARK: - 泛型返回的网络请求
extension HttpUtils {
    
    /// 基于ObjectMapper泛型返回的网络请求
    ///
    /// - Parameters:
    ///   - sessionManage: Alamofire.SessionManage
    ///   - method: 请求方式
    ///   - url: 请求网址
    ///   - parameters: 请求字段
    ///   - headers: 请求头
    ///   - callbackHandler: 回调
    static func requestObjectMapper<T: Mappable>(sessionManage: SessionManager = SessionManager.default,
                                                 method: HTTPMethod,
                                                 url: String,
                                                 parameters: Parameters? = nil,
                                                 headers: HTTPHeaders? = nil,
                                                 callbackHandler: FawMappableCallbackHandler<T>) {
        
        print("HttpUtils ## API Request ## \(method) ## \(url) ## parameters = \(String(describing: parameters))")
        
        //  检查网络
        guard networkIsReachable() else {
            return
        }
        
        //  菊花转
        indicatorRun()
        
        let dataRequset =  sessionManage.request(url, method: method, parameters: parameters, headers: headers)
        
        //  添加请求到请求任务列表中
        requestTasks.updateValue(dataRequset, forKey: url)
        
        //  结果进行回调
        if let keyPath = callbackHandler.keyPath {
            if callbackHandler.isArray {
                dataRequset.responseArray(keyPath: keyPath) { (responseArray: DataResponse<[T]>) in
                    print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: responseArray))")
                    
                    //  有响应 请求从任务列表中移除
                    requestTasks.removeValue(forKey: url)
                    
                    responseArrayCallbackHandler(responseArray: responseArray, callbackHandler: callbackHandler)
                }
            }else {
                dataRequset.responseObject(keyPath: keyPath) { (responseObject: DataResponse<T>) in
                    print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: responseObject))")
                    
                    //  有响应 请求从任务列表中移除
                    requestTasks.removeValue(forKey: url)
                    
                    responseObjectCallbackHandler(responseObject: responseObject, callbackHandler: callbackHandler)
                }
            }
        }else {
            dataRequset.responseObject { (responseObject: DataResponse<T>) in
                print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: responseObject))")
                
                //  有响应 请求从任务列表中移除
                requestTasks.removeValue(forKey: url)
                
                responseObjectCallbackHandler(responseObject: responseObject, callbackHandler: callbackHandler)
            }
        }
        
    }
    
    /// 响应模型处理
    ///
    /// - Parameters:
    ///   - responseObject: 响应对象
    ///   - callbackHandler: 回调
    private static func responseObjectCallbackHandler<T: Mappable>(responseObject: DataResponse<T>, callbackHandler: FawMappableCallbackHandler<T>) {
        
        //  响应请求结果回调
        switch responseObject.result {
            
        //  响应成功
        case .success(let value):
            callbackHandler.success?(value, nil, responseObject.data)
        //  响应失败
        case .failure(let error):
            callbackHandler.failure?(nil, error, responseObject.response?.statusCode)
        }
    }
    
    /// 响应模型数组处理
    ///
    /// - Parameters:
    ///   - responseObject: 响应对象
    ///   - callbackHandler: 回调
    private static func responseArrayCallbackHandler<T: Mappable>(responseArray: DataResponse<[T]>, callbackHandler: FawMappableCallbackHandler<T>) {
        
        //  响应请求结果回调
        switch responseArray.result {
            
        //  响应成功
        case .success(let value):
            callbackHandler.success?(nil, value, responseArray.data)
        //  响应失败
        case .failure(let error):
            callbackHandler.failure?(responseArray.data, error, responseArray.response?.statusCode)
        }
    }
}

// MARK: - 上传网络请求
extension HttpUtils {

    /// 文件上传
    ///
    /// - Parameters:
    ///   - sessionManage: Alamofire.SessionManage
    ///   - url: 请求网址
    ///   - uploadStream: 上传的数据流
    ///   - parameters: 请求字段
    ///   - headers: 请求头
    ///   - size: 文件的size 长宽
    ///   - mimeType: 文件类型 详细看FawMimeType枚举
    ///   - callbackHandler: 上传回调
    class func uploadData(sessionManager: SessionManager = SessionManager.default,
                          url: String,
                          uploadStream: FawUploadStream,
                          parameters: Parameters? = nil,
                          headers: HTTPHeaders? = nil,
                          size: CGSize? = nil,
                          mimeType: FawMimeType,
                          callbackHandler: FawUploadCallbackHandler) {
        //  检查网络
        guard networkIsReachable() else {
            return
        }
        
        print("HttpUtils ## API Request ## post ## \(url) ## parameters = \(String(describing: parameters))")
        
        //  请求头的设置
        var uploadHeaders = ["Content-Type": "multipart/form-data;charset=UTF-8"]
        if let unwappedHeaders = headers {
            uploadHeaders.merge(unwappedHeaders) { (current, new) -> String in return current }
        }
        
        //  如果有多媒体的宽高信息,就加入headers中
        if let mediaSize = size {
            uploadHeaders.updateValue("\(mediaSize.width)", forKey: "width")
            uploadHeaders.updateValue("\(mediaSize.height)", forKey: "height")
        }
        
        //  菊花转
        indicatorRun()
        
        //  开始请求
        sessionManager.upload(multipartFormData: { multipartFormData in
            
            //  表单处理
            
            //  是否有请求字段
            if let params = parameters as? [String: String] {
                for (key, value) in params {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }
            
            //  数据上传
            for (key, value) in uploadStream {
                multipartFormData.append(value, withName: key, fileName: key + mimeType.fileName, mimeType: mimeType.type)
            }
        },
                         to: url,
                         headers: uploadHeaders,
                         encodingCompletion: { encodingResult in
                            
                            //  菊花转结束
                            indicatorStop()
                            
                            print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: encodingResult))")
                            
                            //  响应请求结果
                            switch encodingResult {
                            case .success(let uploadRequest, _ , let streamFileURL):
                                
                                //  添加请求到请求任务列表中
                                requestTasks.updateValue(uploadRequest, forKey: url)
                                
                                uploadRequest.responseJSON(completionHandler: { (response) in
                                    
                                    //  有响应 请求从任务列表中移除
                                    requestTasks.removeValue(forKey: url)
                                    
                                    switch response.result {
                                    case .success(let value):
                                        callbackHandler.result?(streamFileURL, true, nil, value as? [String: Any])
                                    case .failure(let error):
                                        callbackHandler.result?(streamFileURL, false, error ,nil)
                                    }
                                })
                                
                                uploadRequest.uploadProgress { progress in
                                    callbackHandler.progress?(streamFileURL, progress)
                                }
                                
                            case .failure(let error):
                                callbackHandler.result?(nil, false, error, nil)
                            }
        })
        
    }
}

// MARK: - 下载网络请求
extension HttpUtils {
    
    /// 文件下载
    ///
    /// - Parameters:
    ///   - sessionManager: Alamofire.SessionManage
    ///   - url: 请求网址
    ///   - parameters: 请求字段
    ///   - headers: 请求头
    ///   - callbackHandler: 下载回调
    class func downloadData(sessionManager: SessionManager = SessionManager.default,
                            url: String,
                            parameters: Parameters? = nil,
                            headers: HTTPHeaders? = nil,
                            callbackHandler: FawDownloadCallbackHandler) {
        
        //  检查网络
        guard networkIsReachable() else {
            return
        }
        
        //  创建路径
        let destination: DownloadRequest.DownloadFileDestination = { temporaryURL, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename ?? "temp.tmp")
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        print("HttpUtils ## API Request ## \(url) ## parameters = \(String(describing: parameters))")
        
        //  状态栏的菊花转开始
        indicatorRun()
        
        let downloadRequest = sessionManager.download(url, parameters: parameters, to: destination)
        
        //  添加请求到请求任务列表中
        requestTasks.updateValue(downloadRequest, forKey: url)
        
        downloadRequest.responseData { (responseData) in
            
            //  状态栏的菊花转结束
            indicatorStop()
            
            //  有响应 请求从任务列表中移除
            requestTasks.removeValue(forKey: url)
            
            print("HttpUtils ## API Response ## \(String(describing: url)) ## data = \(String(describing: responseData))")
            
            //  响应请求结果
            switch responseData.result {
            case .success(let value):
                callbackHandler.success?(responseData.temporaryURL, responseData.destinationURL, value)
            case .failure(let error):
                callbackHandler.failure?(responseData.resumeData, responseData.temporaryURL, error, responseData.response?.statusCode)
            }
        }.downloadProgress { (progress) in
            callbackHandler.progress?(progress)
        }
    }
}

// MARK: - 请求任务的暂停/恢复/取消
extension HttpUtils {
    
    /// 任务列表别名
    typealias RequestTasks = [String: Request]
    
    /// 全局的任务列表
    static var requestTasks = RequestTasks()
    
    /// 通过url暂停请求
    ///
    /// - Parameter url: 请求网址
    static func suspendRequest(url: String) {
        guard let request = requestTasks[url] else {
            return
        }
        request.suspend()
    }
    
    /// 通过url恢复请求
    ///
    /// - Parameter url: 请求网址
    static func resumeRequest(url: String) {
        guard let request = requestTasks[url] else {
            return
        }
        request.resume()
    }
    
    /// 通过url取消请求
    ///
    /// - Parameter url: 请求网址
    static func cancelRequest(url: String) {
        guard let request = requestTasks[url] else {
            return
        }
        request.cancel()
    }
}

//MARK:- 系统状态栏上的网络请求转圈
extension HttpUtils {
    
    /// 菊花转开始
    static func indicatorRun() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    /// 菊花转停止
    static func indicatorStop() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

// MARK: - 检查网络
extension HttpUtils {
    static func networkIsReachable() -> Bool {
        guard NetworkListener.shared.isReachable else {
            #if DEBUG
            print("没有网络!")
            #endif
            return false
        }
        return true
    }
}

// MARK: - 设置sessionManager的认证策略
extension HttpUtils {
    
    /// 设置sessionManager的认证策略
    ///
    /// - Parameters:
    ///   - trustPolicy: 服务器的认证策略
    ///   - p12Path: p12证书路径
    ///   - password: p12证书的密码
    static func challenge(sessionManager: SessionManager, trustPolicy: FawServerTrustPolicy, p12Path: String, p12password: String) {
        /// 设置主sessionManager的验证回调
        sessionManager.delegate.sessionDidReceiveChallenge = { session, challenge in
            return sessionDidReceiveChallenge(trustPolicy: trustPolicy, p12Path: p12Path, p12password: p12password, session: session, challenge: challenge)
        }
    }
    
    /// sessionDidReceiveChallenge的回调
    ///
    /// - Parameters:
    ///   - trustPolicy: 服务器的认证策略
    ///   - p12Path: p12证书路径
    ///   - password: p12证书的密码
    ///   - session: URLSession
    ///   - challenge: URLAuthenticationChallenge
    /// - Returns: 回调结果
    static func sessionDidReceiveChallenge(trustPolicy: FawServerTrustPolicy, p12Path: String, p12password: String, session: URLSession, challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        /// 服务器证书认证
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            print("服务器认证")
            
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            let host = challenge.protectionSpace.host
            
            if let serverTrust = challenge.protectionSpace.serverTrust {
                if trustPolicy.evaluate(serverTrust, forHost: host) {
                    disposition = .useCredential
                    credential = URLCredential(trust: serverTrust)
                } else {
                    disposition = .cancelAuthenticationChallenge
                }
            }
            
            return (disposition, credential)
        }
        /// 客户端证书验证
        else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            print("客户端验证")
            
            guard let identityAndTrust = try? FawClientTrustPolicy.extractIdentity(p12Path: p12Path, p12password: p12password) else {
                return (.cancelAuthenticationChallenge, nil)
            }
            
            let urlCredential = URLCredential(identity: identityAndTrust.identityRef, certificates: identityAndTrust.certArray as? [Any], persistence: URLCredential.Persistence.forSession)
            
            return (.useCredential, urlCredential)
            
        }
        
        return (.cancelAuthenticationChallenge, nil)
    }
}
