//
//  UIFont+Extension.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//

import UIKit
import SwiftUI

extension UIFont {
    enum PretendardWeight {
        case regular
        case bold
        case semiBold
        case extraBold
        
        var fontName: String {
            switch self {
            case .regular:
                return "Pretendard-Regular"
            case .bold:
                return "Pretendard-Bold"
            case .semiBold:
                return "Pretendard-SemiBold"
            case .extraBold:
                return "Pretendard-ExtraBold"
            }
        }
    }
    
    static func pretendard(_ weight: PretendardWeight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.fontName, size: size) ?? .systemFont(ofSize: size)
    }
    
    /*10px*/
    static let pretendard10Regular = pretendard(.regular, size: 10)
    static let pretendard10SemiBold = pretendard(.semiBold, size: 10)
    
    /*12px*/
    static let pretendard12Regular = pretendard(.regular, size: 12)
    static let pretendard12SemiBold = pretendard(.semiBold, size: 12)
    
    /*14px*/
    static let pretendard14Regular = pretendard(.regular, size: 14)
    static let pretendard14SemiBold = pretendard(.semiBold, size: 14)
    
    /*16px*/
    static let pretendard16Regular = pretendard(.regular, size: 16)
    static let pretendard16SemiBold = pretendard(.semiBold, size: 16)
    
    /*18px*/
    static let pretendard18Regular = pretendard(.regular, size: 18)
    static let pretendard18SemiBold = pretendard(.semiBold, size: 18)
    
    /*20px*/
    static let pretendard20Regular = pretendard(.regular, size: 20)
    static let pretendard20SemiBold = pretendard(.semiBold, size: 20)
    
    /*24px*/
    static let pretendard24Regular = pretendard(.regular, size: 24)
    static let pretendard24Bold = pretendard(.bold, size: 24)
    static let pretendard24ExtraBold = pretendard(.extraBold, size: 24)
}
