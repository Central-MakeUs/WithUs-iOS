//
//  SwiftUIPreview.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/4/26.
//

import SwiftUI

#warning("Dev모드 만든 후 주석 삭제")
//#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
//#endif

//#if DEBUG
extension UICollectionViewCell {
    private struct CellPreview: UIViewRepresentable {
        let cell: UICollectionViewCell
        let size: CGSize
        
        func makeUIView(context: Context) -> UIView {
            let containerView = UIView()
            containerView.backgroundColor = .systemBackground
            
            cell.frame = CGRect(origin: .zero, size: size)
            containerView.addSubview(cell)
            
            return containerView
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {}
    }
    
    /// Cell을 Preview로 보기
    func toPreview(size: CGSize = CGSize(width: 400, height: 700)) -> some View {
        CellPreview(cell: self, size: size)
            .frame(width: size.width, height: size.height)
    }
}
