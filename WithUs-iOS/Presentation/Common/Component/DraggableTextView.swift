//
//  DraggableTextView.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/15/26.
//

import UIKit

protocol DraggableViewDelegate: AnyObject {
    func draggableViewDidTap(_ view: UIView)
    func draggableViewDidRequestDelete(_ view: UIView)
}

class DraggableTextView: UIView {
    
    weak var delegate: DraggableViewDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    init(text: String) {
        super.init(frame: .zero)
        label.text = text
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        layer.cornerRadius = 8
        
        addSubview(label)
        addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: -10),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        // 크기 자동 조정
        label.sizeToFit()
        frame.size = CGSize(
            width: label.frame.width + 32,
            height: label.frame.height + 24
        )
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        addGestureRecognizer(rotationGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        
        switch gesture.state {
        case .began:
            initialCenter = center
        case .changed:
            var newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            
            // ✅ superview 범위 내로 제한
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
        if gesture.state == .changed || gesture.state == .ended {
            let newScale = gesture.scale
            
            // ✅ 최소/최대 크기 제한
            let currentScale = sqrt(transform.a * transform.a + transform.c * transform.c)
            let finalScale = currentScale * newScale
            
            if finalScale >= 0.5 && finalScale <= 3.0 {
                transform = transform.scaledBy(x: newScale, y: newScale)
                gesture.scale = 1.0
            }
        }
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if gesture.state == .changed || gesture.state == .ended {
            transform = transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
        }
    }
    
    @objc private func handleTap() {
        delegate?.draggableViewDidTap(self)
        showDeleteButton()
    }
    
    @objc private func deleteTapped() {
        delegate?.draggableViewDidRequestDelete(self)
    }
    
    func showDeleteButton() {
        deleteButton.isHidden = false
    }
    
    func hideDeleteButton() {
        deleteButton.isHidden = true
    }
}
