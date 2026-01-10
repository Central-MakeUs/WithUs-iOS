//
//  UIView+Shadow.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//


import UIKit

extension UIView {
    
    func addShadow() {
        addShadow(
            color: .black,
            opacity: 0.1,
            offset: CGSize(width: 0, height: 2),
            radius: 4
        )
    }
    
    /// 그림자 추가 (커스텀)
    /// - Parameters:
    ///   - color: 그림자 색상 (기본: 검은색)
    ///   - opacity: 그림자 투명도 0.0 ~ 1.0 (기본: 0.1)
    ///   - offset: 그림자 위치 (기본: 아래로 2pt)
    ///   - radius: 그림자 블러 반경 (기본: 4pt)
    func addShadow(
        color: UIColor = .black,
        opacity: Float = 0.1,
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = 4
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    /// 그림자 제거
    func removeShadow() {
        layer.shadowOpacity = 0
    }
}
