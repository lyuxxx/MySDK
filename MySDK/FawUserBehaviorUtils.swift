//
//  FawUserBehaviorUtils.swift
//  FawSdk
//
//  Created by season on 2018/11/27.
//  Copyright © 2018 FAW. All rights reserved.
//

import UIKit

/// 用户行为Utils
public class FawUserBehaviorUtils {
    
    //MARK:- 对外属性与方法
    
    /// FawUserBehaviorUtils的单例
    public static let share = FawUserBehaviorUtils()
    private init() {}
    
    /// 获取UserBehavior.plist的路径
    ///
    /// - Returns: UserBehavior.plist的路径
    public func getUserBehaviorPlistPath() -> String {
        return userBehaviorPlistPath
    }
    
    /// 获取UserBehavior.plist的文件信息(字符串)
    ///
    /// - Returns: 文件信息(json字符串)
    public func getUserBehaviorInfo() -> String? {
        guard let dictArray = NSArray(contentsOfFile: userBehaviorPlistPath) as? [[String: String]],
            let data = try? JSONSerialization.data(withJSONObject: dictArray, options: .prettyPrinted) else {
            return nil
        }
        
        let userBehaviorInfo = String(data: data, encoding: .utf8)
        return userBehaviorInfo
    }
    
    /// 设置按钮的点击统计
    public func setButtonClickStatistics() {
        FawSdk.share.isOpenButtonClickStatistics = true
        UIButton.clickStatistics()
    }
    
    /// 设置控制器的停留统计
    public func setViewControllerHoldStatistics() {
        FawSdk.share.isOpenViewControllerHoldStatistics = true
        UIViewController.holdStatistics()
    }
    
    /// 设置控制器的停留统计的白名单 加入名单的不进行统计
    ///
    /// - Parameter whiteList: 白名单
    public func setViewControllerHoldWhiteList(_ whiteList: [String]) {
        FawSdk.share.whiteList = whiteList
        UIViewController.setWhitList(whiteList)
    }
}


// MARK: - 按钮点击的统计
private let userBehaviorPlistPath = NSHomeDirectory() + "/Documents/UserBehavior.plist"

extension UIButton {
    
    /// 业务标识符,如果该按钮需要统计点击次数,请务必对该属性赋一个非空字符串,否则将不统计该按钮的点击次数
    public var businessCode: String {
        get {
            return (objc_getAssociatedObject(self, &UIButtonKey.businessCodeKey) as? String) ?? ""
        }
        set {
            objc_setAssociatedObject(self, &UIButtonKey.businessCodeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 交换UIButton.sendAction(_:to:for:) 请在AppDelegate Launch中使用
    static func clickStatistics() {
        DispatchQueue.once(token: "UIButton") {
            let sysSendActionFunc = Selector.sysSendActionFunc
            let mySendActionFunc = Selector.mySendActionFunc
            changeMethod(sysSendActionFunc, mySendActionFunc, self)
        }
    }
    
    /// 结构体静态key
    private struct UIButtonKey {
        static var clickCountKey = "clickCountKey"
        static var businessCodeKey = "businessCodeKey"
    }
    
    /// 统计的按钮被点击的次数
    private var clickCount: Int {
        get {
            return (objc_getAssociatedObject(self, &UIButtonKey.clickCountKey) as? Int) ?? 0
        }
        set {
            objc_setAssociatedObject(self, &UIButtonKey.clickCountKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 自己的sendAction(_:to:for:)
    ///
    /// - Parameters:
    ///   - action: 方法
    ///   - target: 目标
    ///   - event: 事件枚举
    @objc fileprivate func mySendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        synchronized(self) {
            self.clickCountSave()
        }
        mySendAction(action, to: target, for: event)
    }
    
    /// 保存点击的次数
    private func clickCountSave() {
        let date = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nowTime = timeFormatter.string(from: date)
        
        guard !businessCode.isEmpty else {
            return
        }
        
        clickCount += 1
        print("\(businessCode)被点击了\(clickCount)次")
        
        var buttonClickBehavior = [String: String]()
        buttonClickBehavior.updateValue(nowTime, forKey: "Time")
        buttonClickBehavior.updateValue(businessCode, forKey: "ButtonClick")
        
        let ioQueueName = "com.chinaunicom.smartconnection.CuscSDK.buttonClickCount"
        let ioQueue = DispatchQueue(label: ioQueueName)
        ioQueue.async {
            if var dictArray = NSArray(contentsOfFile: userBehaviorPlistPath) as? [[String: String]] {
                dictArray.append(buttonClickBehavior)
                (dictArray as NSArray).write(toFile: userBehaviorPlistPath, atomically: true)
            }else {
               ([buttonClickBehavior] as NSArray).write(toFile: userBehaviorPlistPath, atomically: true)
            }
        }
    }
}

// MARK: - UIButton的方法的静态值
private extension Selector {
    static let sysSendActionFunc = #selector(UIButton.sendAction(_:to:for:))
    static let mySendActionFunc = #selector(UIButton.mySendAction(_:to:for:))
}

// MARK: - 页面停留事件的统计
extension UIViewController {
    /// 交换方法WillAppear和WillDisappear方法 请在AppDelegate Launch中使用
    static func holdStatistics() {
        DispatchQueue.once(token: "UIViewController") {
            
            let sysViewWillAppearFunc = Selector.sysViewWillAppearFunc
            let myViewWillAppearFunc = Selector.myViewWillAppearFunc
            changeMethod(sysViewWillAppearFunc, myViewWillAppearFunc, self)
            
            let sysViewWillDisappearFunc = Selector.sysViewWillDisappearFunc
            let myViewWillDisappearFunc = Selector.myViewWillDisappearFunc
            changeMethod(sysViewWillDisappearFunc, myViewWillDisappearFunc, self)
        }
    }
    
    /// 该页面是否需要统计埋点
    /// 备注: 也考虑过使用OC的NSStringForClass的方法来进行 其实在Swift中就是写一个白名单数组
    /// - Returns: 默认返回true 如果该页面不需要进行埋点,请重写其方法,返回false
    @objc func needStatisticsTheHoldTime() -> Bool {
        return true
    }
    
    /// 设置白名单
    ///
    /// - Parameter whiteList: 白名单
    static func setWhitList(_ whiteList: [String]) {
        self.whiteList = whiteList
    }
    
    /// 自己的viewWillAppear
    ///
    /// - Parameter animated: animated
    @objc fileprivate
    func viewHoldWillAppear(_ animated: Bool) {
        if !needStatisticsTheHoldTime() || UIViewController.whiteList.contains(className) { return }
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    /// 自己的viewWillDisAppear
    ///
    /// - Parameter animated: animated
    @objc fileprivate
    func viewHoldWillDisappear(_ animated: Bool) {
        if !needStatisticsTheHoldTime() || UIViewController.whiteList.contains(className) { return }
        let holdTime = Int(CFAbsoluteTimeGetCurrent() - startTime)
        print("\(className)停留了\(Int(holdTime))s")
        timeSave(holdTime)
    }
    
    /// 保存停留时间
    ///
    /// - Parameter holdTime: 停留时间
    private func timeSave(_ holdTime: Int) {
        
        let date = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nowTime = timeFormatter.string(from: date)
        
        var viewControllerHoldBehavior = [String: String]()
        viewControllerHoldBehavior.updateValue(nowTime, forKey: "Time")
        viewControllerHoldBehavior.updateValue("\(className)-\(holdTime)s", forKey: "viewControllerHold")
        
        let ioQueueName = "com.chinaunicom.smartconnection.CuscSDK.viewControllerHold"
        let ioQueue = DispatchQueue(label: ioQueueName)
        ioQueue.async {
            if var dictArray = NSArray(contentsOfFile: userBehaviorPlistPath) as? [[String: String]] {
                dictArray.append(viewControllerHoldBehavior)
                (dictArray as NSArray).write(toFile: userBehaviorPlistPath, atomically: true)
            }else {
                ([viewControllerHoldBehavior] as NSArray).write(toFile: userBehaviorPlistPath, atomically: true)
            }
        }
    }
    
    /// 结构体静态key
    private struct UIViewControllerKey {
        static var startTimeKey = "startTimeKey"
    }
    
    /// 统计页面进入的时间
    private var startTime: CFAbsoluteTime {
        get {
            return (objc_getAssociatedObject(self, &UIViewControllerKey.startTimeKey) as? CFAbsoluteTime) ?? 0
        }
        set {
            objc_setAssociatedObject(self, &UIViewControllerKey.startTimeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 不进行埋点的白名单
    private static var whiteList = [String]()
}

// MARK: - UIViewController的方法的静态值
private extension Selector {
    static let sysViewWillAppearFunc = #selector(UIViewController.viewWillAppear(_:))
    static let myViewWillAppearFunc = #selector(UIViewController.viewHoldWillAppear(_:))
    
    static let sysViewWillDisappearFunc = #selector(UIViewController.viewWillDisappear(_:))
    static let myViewWillDisappearFunc = #selector(UIViewController.viewHoldWillDisappear(_:))
}


// MARK: - 辅助分类
extension DispatchQueue {
    private static var onceTracker = [String]()
    
    fileprivate class func once(token: String, block:() -> ()) {
        //注意defer作用域，调用顺序——即一个作用域结束，该作用域中的defer语句自下而上调用。
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        
        if onceTracker.contains(token) {
            return
        }
        onceTracker.append(token)
        block()
    }
}

// MARK: - NSObject获取类的字符串的方法
extension NSObject {
    
    /// 对象方法获类的字符串
    public var className: String {
        return type(of: self).className
    }
    
    /// 类方法获类的字符串
    public static var className: String {
        return String(describing: self)
    }
    
    /// Runtime方法交换
    ///
    /// - Parameters:
    ///   - original: 原方法
    ///   - swizzled: 交换方法
    ///   - object: 对象
    static func changeMethod(_ original: Selector, _ swizzled: Selector, _ object: AnyClass) -> () {
        
        guard let originalMethod = class_getInstanceMethod(object, original),
            let swizzledMethod = class_getInstanceMethod(object, swizzled) else {
                return
        }
        
        let didAddMethod = class_addMethod(object, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(object, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

extension String {
    
    /// 空串
    var isBlank: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    /// 非空串
    var isNotBlank:Bool{
        return !isBlank
    }
}


//MARK:- 加线程锁

/// 加线程锁
///
/// - Parameters:
///   - lock: 需要加锁的参数 泛型
///   - callback: 闭包,在参数加锁的情况的行为操作
private func synchronized<T>(_ lock: T, callback: () -> ()) {
    objc_sync_enter(lock)
    callback()
    objc_sync_exit(lock)
}
