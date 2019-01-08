//
//  CallbackHandler.swift
//  FawSdk
//
//  Created by season on 2018/11/30.
//  Copyright © 2018 FAW. All rights reserved.
//

import Foundation
import ObjectMapper

/// 基本数据的成功回调,回调的是Data, String和[String: Any]类型的数据
public typealias FawBasicSuccessCallback = (Data?, String?, [String: Any]?) -> ()

/// 失败的回调,回调的是Data, Error和statusCode
public typealias FawFailureCallback = (Data?, Error?, Int?) -> ()

/// 基本回调
public class FawBasicCallbackHandler {
    
    /// 初始化方法
    public init() {}
    
    /// 成功的回调
    ///
    /// - Parameter callback: 回调的数据
    /// - Returns: 对象自己
    @discardableResult
    public func onSuccess(_ callback: @escaping FawBasicSuccessCallback) -> Self {
        success = callback
        return self
    }
    
    /// 失败的回调
    ///
    /// - Parameter callback: 回调数据
    /// - Returns: 对象自己
    public func onFailure(_ callback: @escaping FawFailureCallback) -> Self {
        failure = callback
        return self
    }
    
    /// 成功回调属性
    var success: FawBasicSuccessCallback?
    
    /// 失败回调属性
    var failure: FawFailureCallback?
}

/// 模型数据的成功回调,回调的是模型, 模型数组, Data数据
public typealias FawMappableSuccessCallback<T: Mappable> = (T?, [T]?, Data?) -> ()

/// Mappable回调
public class FawMappableCallbackHandler<T: Mappable> {
    
    /// 初始化方法
    public init() {}
    
    /// 设置直达路径,需要在两个on方法前进行设置,否则结果会有误
    ///
    /// - Parameter keyPath: 直达路径
    /// - Returns: 对象自己
    public func setKeyPath(_ keyPath: String) -> Self {
        self.keyPath = keyPath
        return self
    }
    
    /// 获取的是否是模型数组,需要在两个on方法前进行设置,否则结果会有误
    /// 由于ObjectMapper解析的原因,必须告诉它你解析的是模型数组还是模型
    /// - Parameter isArray: 是否是模型数组
    /// - Returns: 对象自己
    public func setIsArray(_ isArray: Bool) -> Self {
        self.isArray = isArray
        return self
    }
    
    /// 成功的回调
    ///
    /// - Parameter callback: 回调的数据
    /// - Returns: 对象自己
    @discardableResult
    public func onSuccess(_ callback: @escaping FawMappableSuccessCallback<T>) -> Self {
        success = callback
        return self
    }
    
    /// 失败的回调
    ///
    /// - Parameter callback: 回调数据
    /// - Returns: 对象自己
    public func onFailure(_ callback: @escaping FawFailureCallback) -> Self {
        failure = callback
        return self
    }
    
    /// 成功回调属性
    var success: FawMappableSuccessCallback<T>?
    
    /// 失败回调属性
    var failure: FawFailureCallback?
    
    var keyPath: String?
    
    var isArray: Bool = false
}

/// 上传数据流 [文件名: 数据]的字典
public typealias FawUploadStream = [String: Data]

/// 上传结果的回调,回调的是上传的网址,上传是否成功true表示成功,false表示失败, error和[String: Any]?
public typealias FawUploadResultCallback = (URL?, Bool, Error?, [String: Any]?) -> ()

/// 上传进度的回调,回调的是上传的网址,上传进度
public typealias FawUploadProgressCallback = (URL?, Progress) -> ()

/// 上传的回调
public class FawUploadCallbackHandler {
    /// 初始化方法
    public init() {}
    
    /// 上传结果的回调
    ///
    /// - Parameter callback: 回调的数据
    /// - Returns: 对象自己
    @discardableResult
    public func onUploadResult(_ callback: @escaping FawUploadResultCallback) -> Self {
        result = callback
        return self
    }
    
    /// 上传进度的回调
    ///
    /// - Parameter callback: 回调数据
    /// - Returns: 对象自己
    public func onUploadProgress(_ callback: @escaping FawUploadProgressCallback) -> Self {
        progress = callback
        return self
    }
    
    /// 上传结果回调属性
    var result: FawUploadResultCallback?
    
    /// 上传进度回调属性
    var progress: FawUploadProgressCallback?
}

/// 下载成功结果的回调,回调的是文件临时路径(临时路径一般没有使用),文件保存路径和下载文件的二进制
public typealias FawDownloadSuccessCallback = (URL?, URL?, Data?) -> ()

/// 下载失败结果的回调,回调的是文件临时数据 文件临时路径(临时路径一般没有使用),Error和statusCode
public typealias FawDownloadFailureCallback = (Data?, URL?, Error?, Int?) -> ()

/// 下载进度的回调,回调的是下载进度
public typealias FawDownloadProgressCallback = (Progress) -> ()

/// 下载回调
public class FawDownloadCallbackHandler {
    /// 初始化方法
    public init() {}
    
    /// 成功的回调
    ///
    /// - Parameter callback: 回调的数据
    /// - Returns: 对象自己
    @discardableResult
    public func onSuccess(_ callback: @escaping FawDownloadSuccessCallback) -> Self {
        success = callback
        return self
    }
    
    /// 失败的回调
    ///
    /// - Parameter callback: 回调数据
    /// - Returns: 对象自己
    public func onFailure(_ callback: @escaping FawDownloadFailureCallback) -> Self {
        failure = callback
        return self
    }
    
    /// 上传进度的回调
    ///
    /// - Parameter callback: 回调数据
    /// - Returns: 对象自己
    public func onDownloadProgress(_ callback: @escaping FawDownloadProgressCallback) -> Self {
        progress = callback
        return self
    }
    
    /// 成功回调属性
    var success: FawDownloadSuccessCallback?
    
    /// 失败回调属性
    var failure: FawDownloadFailureCallback?
    
    /// 下载进度回调属性
    var progress: FawDownloadProgressCallback?
}
