import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Loading
    private lazy var loadingDimView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.isHidden = true
    }
    
    private lazy var loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.color = .white
        $0.hidesWhenStopped = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setNavigation()
        setupLoadingView()
    }
    
    private func setupLoadingView() {
        view.addSubview(loadingDimView)
        loadingDimView.addSubview(loadingIndicator)
        
        loadingDimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func showLoading() {
        view.bringSubviewToFront(loadingDimView)
        loadingDimView.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingDimView.isHidden = true
        loadingIndicator.stopAnimating()
    }
    
    // MARK: - Setup
    func setupUI() {
        view.backgroundColor = .white
    }
    
    func setupConstraints() {}
    
    func setupActions() {}
    
    func setNavigation() {}
    
    /// 네비게이션 바 왼쪽에 버튼 추가
    /// - Parameters:
    ///   - title: 버튼 타이틀
    ///   - attributedTitle: Attributed 타이틀 (title보다 우선)
    ///   - image: 버튼 이미지
    ///   - action: 버튼 클릭 시 실행될 액션 (nil이면 기본 pop 동작)
    ///   - tintColor: 버튼 색상
    func setLeftBarButton(
        title: String? = nil,
        attributedTitle: NSAttributedString? = nil,
        image: UIImage? = nil,
        action: Selector? = nil,
        tintColor: UIColor? = nil
    ) {
        let button = UIButton(type: .custom)
        
        if let attributedTitle = attributedTitle {
            button.setAttributedTitle(attributedTitle, for: .normal)
        } else if let title = title {
            button.setTitle(title, for: .normal)
            button.setTitleColor(tintColor ?? .systemBlue, for: .normal)
        }
        
        if let image = image {
            button.setImage(image, for: .normal)
            button.tintColor = tintColor ?? .black
        }
        
        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(defaultBackAction), for: .touchUpInside)
        }
        
        button.sizeToFit()
        
        let barButtonItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButtonItem
        if #available(iOS 26.0, *) {
            navigationItem.leftBarButtonItem?.hidesSharedBackground = true
        }
    }
    
    /// 네비게이션 바 오른쪽에 버튼 추가
    /// - Parameters:
    ///   - title: 버튼 타이틀
    ///   - attributedTitle: Attributed 타이틀 (title보다 우선)
    ///   - image: 버튼 이미지
    ///   - action: 버튼 클릭 시 실행될 액션 (nil이면 클릭 불가)
    ///   - tintColor: 버튼 색상
    func setRightBarButton(
        title: String? = nil,
        attributedTitle: NSAttributedString? = nil,
        image: UIImage? = nil,
        action: Selector? = nil,
        tintColor: UIColor? = nil
    ) {
        let button = UIButton(type: .custom)
        
        if let attributedTitle = attributedTitle {
            button.setAttributedTitle(attributedTitle, for: .normal)
        } else if let title = title {
            button.setTitle(title, for: .normal)
            button.setTitleColor(tintColor ?? .systemBlue, for: .normal)
        }
        
        if let image = image {
            button.setImage(image, for: .normal)
            button.tintColor = tintColor ?? .systemBlue
        }
        
        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        } else {
            button.isUserInteractionEnabled = false
        }
        
        button.sizeToFit()
        
        let barButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButtonItem
        if #available(iOS 26.0, *) {
            navigationItem.rightBarButtonItem?.hidesSharedBackground = true
        }
    }
    
    func setCenterLogo(image: UIImage?, width: CGFloat? = nil, height: CGFloat = 20) {
        guard let logoImage = image else { return }
        
        let imageView = UIImageView(image: logoImage)
        imageView.contentMode = .scaleAspectFit
        
        let imageRatio = logoImage.size.width / logoImage.size.height
        let finalWidth = width ?? (height * imageRatio)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: finalWidth, height: height))
        imageView.frame = containerView.bounds
        containerView.addSubview(imageView)
        
        self.navigationItem.titleView = containerView
    }
    
    @objc private func defaultBackAction() {
        navigationController?.popViewController(animated: true)
    }
    
    func openExternalBrowser(urlStr: String) {
        guard let url = URL(string: urlStr) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
