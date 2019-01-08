//
//  FawMimeType.swift
//  FawSdk
//
//  Created by season on 2018/12/7.
//  Copyright © 2018 FAW. All rights reserved.
//

import Foundation

/// 上传多媒体类型
///
/// - image: 图片 jpg/png
/// - gif: 动图
/// - video: 视频
public enum FawMimeType {
    
    case image(_ fileName: String?)
    case gif(_ fileName: String?)
    case video(_ fileName: String?)
    
    /// 文件类型
    var type: String {
        switch self {
        case .image:
            return "image/*"
        case .gif:
            return "image/gif"
        case .video:
            return "video/*"
        }
    }
    
    /// 获取上传文件的名称
    var fileName: String {
        switch self {
        case .image(let fileName):
            return "." + (fileName ?? "jpg")
        case .gif(let fileName):
            return "." + (fileName ?? "gif")
        case .video(let fileName):
            return "." + (fileName ?? "mp4")
        }
    }
}
