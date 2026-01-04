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
