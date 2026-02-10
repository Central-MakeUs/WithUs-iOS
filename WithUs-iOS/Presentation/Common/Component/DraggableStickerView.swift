//
//  DraggableStickerView.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/15/26.
//

import UIKit

class DraggableStickerView: UIView {

    weak var delegate: DraggableViewDelegate?

    private let stickerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var initialCenter: CGPoint = .zero
    private var currentScale: CGFloat = 1.0

    init(image: UIImage) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        stickerImageView.image = image
        setupUI()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(stickerImageView)

        NSLayoutConstraint.activate([
            stickerImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stickerImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stickerImageView.widthAnchor.constraint(equalTo: widthAnchor),
            stickerImageView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
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

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
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
        guard gesture.state == .changed || gesture.state == .ended else { return }

        let newScale = currentScale * gesture.scale
        guard newScale >= 0.3 && newScale <= 5.0 else {
            gesture.scale = 1.0
            return
        }

        currentScale = newScale
        let rotation = atan2(transform.b, transform.a)
        transform = CGAffineTransform(rotationAngle: rotation).scaledBy(x: currentScale, y: currentScale)
        gesture.scale = 1.0
    }

    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.state == .changed || gesture.state == .ended else { return }

        let rotation = atan2(transform.b, transform.a) + gesture.rotation
        transform = CGAffineTransform(rotationAngle: rotation).scaledBy(x: currentScale, y: currentScale)
        gesture.rotation = 0
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        UIView.animate(withDuration: 0.1, animations: {
            self.transform = self.transform.scaledBy(x: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = self.transform.scaledBy(x: 1.0 / 1.1, y: 1.0 / 1.1)
            }
        }

        delegate?.draggableViewDidTap(self)
    }
}

extension DraggableStickerView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
