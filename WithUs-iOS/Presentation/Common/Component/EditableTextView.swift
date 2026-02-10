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

    private var initialCenter: CGPoint = .zero
    private var isEditing: Bool = false
    private var currentScale: CGFloat = 1.0

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
        clipsToBounds = false

        addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])

        textView.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
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

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
    }

    func startEditing() {
        isEditing = true
        textView.becomeFirstResponder()
        textView.selectedRange = NSRange(location: textView.text.count, length: 0)
    }

    @objc private func handleTap() {
        if !isEditing {
            startEditing()
        }
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        UIView.animate(withDuration: 0.1, animations: {
            self.transform = self.transform.scaledBy(x: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = self.transform.scaledBy(x: 1.0 / 1.1, y: 1.0 / 1.1)
            }
        }

        delegate?.draggableViewDidTap(self)
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
        if isEditing { return }
        guard gesture.state == .changed || gesture.state == .ended else { return }

        let rotation = atan2(transform.b, transform.a) + gesture.rotation
        transform = CGAffineTransform(rotationAngle: rotation).scaledBy(x: currentScale, y: currentScale)
        gesture.rotation = 0
    }

    @objc private func keyboardWillHide() {
        isEditing = false
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            delegate?.draggableViewDidRequestDelete(self)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate
extension EditableTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let maxWidth: CGFloat = 300
        let minWidth: CGFloat = 100

        let textSize = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude))
        let requiredWidth = min(max(textSize.width + 32, minWidth), maxWidth)
        let constrainedSize = textView.sizeThatFits(CGSize(width: requiredWidth - 32, height: .greatestFiniteMagnitude))
        let requiredHeight = constrainedSize.height + 24

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
        if isEditing && !(gestureRecognizer is UITapGestureRecognizer) {
            return false
        }
        return true
    }
}
