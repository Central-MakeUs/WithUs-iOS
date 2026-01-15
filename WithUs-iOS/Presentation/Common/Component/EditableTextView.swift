//
//  EditableTextView.swift
//  WithUs-iOS
//
//  Created by Claude on 1/15/26.
//

import UIKit

class EditableTextView: UIView {
    
    weak var delegate: DraggableViewDelegate?
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 32, weight: .bold)
        textView.textAlignment = .center
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .red
        button.layer.cornerRadius = 15
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var initialCenter: CGPoint = .zero
    private var isEditing: Bool = false
    
    init(text: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        textView.text = text
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        layer.cornerRadius = 8
        
        // ✅ 경계 밖 터치를 허용
        clipsToBounds = false
        
        addSubview(textView)
        addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: -10),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        textView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        rotationGesture.delegate = self
        addGestureRecognizer(rotationGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
    
    // ✅ 경계 밖 터치를 허용하는 메서드
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // deleteButton이 보이는 상태면 그 영역도 터치 가능하게
        if !deleteButton.isHidden {
            let buttonPoint = convert(point, to: deleteButton)
            if deleteButton.bounds.contains(buttonPoint) {
                return true
            }
        }
        return super.point(inside: point, with: event)
    }
    
    // ✅ 터치를 올바른 subview로 전달
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // deleteButton이 보이는 상태에서 버튼 영역을 터치하면 버튼 반환
        if !deleteButton.isHidden {
            let buttonPoint = convert(point, to: deleteButton)
            if deleteButton.bounds.contains(buttonPoint) {
                print("🔴 삭제 버튼 터치 감지!")
                return deleteButton
            }
        }
        return super.hitTest(point, with: event)
    }
    
    func startEditing() {
        isEditing = true
        textView.becomeFirstResponder()
        textView.selectedRange = NSRange(location: textView.text.count, length: 0)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        if isEditing { return }
        
        let translation = gesture.translation(in: superview)
        
        switch gesture.state {
        case .began:
            initialCenter = center
        case .changed:
            var newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            
            if let superview = superview {
                let halfWidth = bounds.width / 2
                let halfHeight = bounds.height / 2
                
                newCenter.x = max(halfWidth, min(newCenter.x, superview.bounds.width - halfWidth))
                newCenter.y = max(halfHeight, min(newCenter.y, superview.bounds.height - halfHeight))
            }
            
            center = newCenter
        default:
            break
        }
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if isEditing { return }
        
        if gesture.state == .changed || gesture.state == .ended {
            let newScale = gesture.scale
            let currentScale = sqrt(transform.a * transform.a + transform.c * transform.c)
            let finalScale = currentScale * newScale
            
            if finalScale >= 0.5 && finalScale <= 3.0 {
                transform = transform.scaledBy(x: newScale, y: newScale)
                gesture.scale = 1.0
            }
        }
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if isEditing { return }
        
        if gesture.state == .changed || gesture.state == .ended {
            transform = transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        print("🟡 탭 제스처 감지")
        
        // ✅ 삭제 버튼 영역 체크 (확장된 터치 영역)
        let location = gesture.location(in: self)
        let buttonFrame = deleteButton.frame
        
        // 버튼 주변 20포인트까지 확장
        let expandedFrame = buttonFrame.insetBy(dx: -20, dy: -20)
        
        if expandedFrame.contains(location) && !deleteButton.isHidden {
            print("🔴 삭제 버튼 영역 터치 - 제스처 무시")
            return
        }
        
        if !isEditing {
            delegate?.draggableViewDidTap(self)
            showDeleteButton()
        } else {
            startEditing()
        }
    }
    
    @objc private func deleteTapped() {
        print("🔴 deleteTapped 호출됨!")
        print("🔴 delegate: \(String(describing: delegate))")
        
        if delegate == nil {
            print("🔴 ❌ delegate가 nil입니다!")
        } else {
            print("🔴 ✅ delegate 존재, draggableViewDidRequestDelete 호출")
            delegate?.draggableViewDidRequestDelete(self)
        }
    }
    
    @objc private func keyboardWillHide() {
        isEditing = false
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            delegate?.draggableViewDidRequestDelete(self)
        }
    }
    
    func showDeleteButton() {
        deleteButton.isHidden = false
        print("🟢 삭제 버튼 표시")
    }
    
    func hideDeleteButton() {
        deleteButton.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate
extension EditableTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // ✅ 텍스트 변경 시 크기 자동 조정 (가로 우선, 최대치 도달 시 세로 확장)
        
        // 최대 너비 설정 (화면 너비 - 여백)
        let maxWidth: CGFloat = 300
        let minWidth: CGFloat = 100
        
        // 현재 텍스트의 실제 크기 계산 (한 줄로 늘어날 때)
        let textSize = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude))
        
        // 필요한 너비 계산 (패딩 포함)
        let requiredWidth = min(max(textSize.width + 32, minWidth), maxWidth)
        
        // 높이 계산 (계산된 너비 기준으로)
        let constrainedSize = textView.sizeThatFits(CGSize(width: requiredWidth - 32, height: .greatestFiniteMagnitude))
        let requiredHeight = constrainedSize.height + 24
        
        // 크기 애니메이션
        UIView.animate(withDuration: 0.1) {
            self.frame.size = CGSize(width: requiredWidth, height: requiredHeight)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isEditing = false
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EditableTextView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isEditing {
            return false
        }
        
        // ✅ 삭제 버튼 영역이면 제스처 비활성화
        if let tapGesture = gestureRecognizer as? UITapGestureRecognizer {
            let location = tapGesture.location(in: self)
            let buttonFrame = deleteButton.frame.insetBy(dx: -20, dy: -20)
            
            if buttonFrame.contains(location) && !deleteButton.isHidden {
                return false
            }
        }
        
        return true
    }
}
