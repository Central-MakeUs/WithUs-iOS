//
//  ToastView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//


import UIKit
import SnapKit
import Then

enum ToastPosition {
    case top(offset: CGFloat)
    case center
    case bottom(offset: CGFloat)
    
    static var top: ToastPosition { .top(offset: 100) }
    static var bottom: ToastPosition { .bottom(offset: 100) }
}

class ToastView: UIView {
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white
    }
    
    private let iconBackgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
    }
    
    private let messageLabel = UILabel().then {
        $0.font = UIFont.pretendard12SemiBold
        $0.textColor = UIColor.gray900
        $0.numberOfLines = 0
    }
    
    init(message: String, icon: UIImage? = nil) {
        super.init(frame: .zero)
        messageLabel.text = message
        iconImageView.image = icon
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
         addSubview(containerView)
         containerView.addSubview(iconBackgroundView)
         iconBackgroundView.addSubview(iconImageView)
         containerView.addSubview(messageLabel)
         
         containerView.addShadow(
             color: .black,
             opacity: 0.05,
             offset: CGSize(width: 18, height: 0),
             radius: 12
         )
     }
     
     private func setupConstraints() {
         containerView.snp.makeConstraints {
             $0.edges.equalToSuperview()
             $0.height.greaterThanOrEqualTo(48)
         }
         
         iconBackgroundView.snp.makeConstraints {
             $0.left.equalToSuperview().offset(18)
             $0.verticalEdges.equalToSuperview().inset(14)
             $0.size.equalTo(20)
         }
         
         iconImageView.snp.makeConstraints {
             $0.center.equalToSuperview()
             $0.size.equalTo(24)
         }
         
         messageLabel.snp.makeConstraints {
             $0.left.equalTo(iconBackgroundView.snp.right).offset(6)
             $0.right.equalToSuperview().offset(-18)
             $0.centerY.equalToSuperview()
         }
     }
    
       /// 토스트 표시
       /// - Parameters:
       ///   - message: 표시할 메시지
       ///   - icon: 아이콘 이미지 (옵션)
       ///   - position: 표시 위치 (기본: 상단)
       ///   - duration: 표시 시간 (기본: 2초)
       static func show(
           message: String,
           icon: UIImage? = UIImage(named: "ic_ok"),
           position: ToastPosition = .center,
           duration: TimeInterval = 2.0
       ) {
           let window: UIWindow? = UIApplication.shared.connectedScenes
               .filter { $0.activationState == .foregroundActive }
               .compactMap { $0 as? UIWindowScene }
               .flatMap { $0.windows }
               .first { $0.isKeyWindow }

           guard let window else { return }
           
           let toast = ToastView(message: message, icon: icon)
           window.addSubview(toast)
           
           // 제약조건 설정
           toast.snp.makeConstraints {
               $0.left.right.equalToSuperview().inset(20)
               
               switch position {
               case .top(let offset):
                   $0.top.equalTo(window.safeAreaLayoutGuide).offset(offset)
               case .center:
                   $0.centerY.equalToSuperview()
               case .bottom(let offset):
                   $0.bottom.equalTo(window.safeAreaLayoutGuide).offset(-offset)
               }
           }
           
           toast.alpha = 0
           toast.transform = CGAffineTransform(translationX: 0, y: -20)
           
           UIView.animate(
               withDuration: 0.5,
               delay: 0,
               usingSpringWithDamping: 0.7,
               initialSpringVelocity: 0.5,
               options: .curveEaseOut
           ) {
               toast.alpha = 1
               toast.transform = .identity
           }
           
           DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
               UIView.animate(
                   withDuration: 0.3,
                   animations: {
                       toast.alpha = 0
                       toast.transform = CGAffineTransform(translationX: 0, y: -20)
                   },
                   completion: { _ in
                       toast.removeFromSuperview()
                   }
               )
           }
       }
}

