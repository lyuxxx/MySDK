//
//  FawImageLoadUtils.swift
//  FawSdk
//
//  Created by season on 2018/11/29.
//  Copyright © 2018 FAW. All rights reserved.
//

import Foundation
import Kingfisher

/// 图片缓存Utils
public class FawImageLoadUtils {
    
    //MARK:- 对外属性与方法
    
    /// FawImageLoadUtils初始化的单例方法
    public static let share = FawImageLoadUtils()
    private init() {}
    
    /// 清理内存缓存
    public func clearCache() {
        KingfisherManager.shared.cache.clearMemoryCache()
    }
}

// MARK: - 加载一般图片/Gif/圆角图片的方法
public extension UIImageView {
    
    /// 加载图片
    ///
    /// - Parameters:
    ///   - url: 网络图片网址
    ///   - placeholder: 占位图, 可选参数
    public func loadImage(url: String, placeholder: UIImage? = nil) {
        let uRL = URL(string: url)
        self.kf.setImage(with: uRL, placeholder: placeholder)
    }
    
    /// 加载Gif图片
    ///
    /// - Parameters:
    ///   - url: 网络图片网址
    ///   - placeholder: 占位图, 可选参数
    public func loadGifImage(url: String, placeholder: UIImage? = nil) {
        let uRL = URL(string: url)
        self.kf.setImage(with: uRL, placeholder: placeholder)
    }
    
    /// 加载圆形图片
    /// 图片的大小会根据图片较短的边一般进行倒圆角
    /// - Parameters:
    ///   - url: 网络图片网址
    ///   - placeholder: 占位图, 可选参数
    public func loadCircleImage(url: String, placeholder: UIImage? = nil) {
        guard let uRL = URL(string: url) else {
            self.image = placeholder
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: uRL, options: [], progressBlock: nil) { (image, error, cacheType, url) in
            guard let image = image else {
                self.image = placeholder
                return
            }
            
            let minLenght = min(image.size.width, image.size.height)
            let cornerRadius = minLenght / 2.0
            let targetSize = CGSize(width: minLenght, height: minLenght)
            
            self.kf.setImage(with: uRL, placeholder: placeholder, options: [.processor(RoundCornerImageProcessor(cornerRadius: cornerRadius, targetSize: targetSize))])
        }
    }
    
    
    /// 加载圆角图片
    ///
    /// - Parameters:
    ///   - url: 网络图片网址
    ///   - placeholder: 占位图, 可选参数
    ///   - cornerRadius: 倒角的大小
    ///   - corners: 倒角枚举 四个角都倒,或者根据需要倒角,详细看RectCorner
    public func loadCornerRadiusImage(url: String, placeholder: UIImage? = nil, cornerRadius: CGFloat, corners: RectCorner = .all) {
        guard let uRL = URL(string: url) else {
            self.image = placeholder
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: uRL, options: [], progressBlock: nil) { (image, error, cacheType, url) in
            guard let _ = image else {
                self.image = placeholder
                return
            }
            
            self.kf.setImage(with: uRL, placeholder: placeholder, options: [.processor(RoundCornerImageProcessor(cornerRadius: cornerRadius, roundingCorners: corners))])
        }
    }
}
