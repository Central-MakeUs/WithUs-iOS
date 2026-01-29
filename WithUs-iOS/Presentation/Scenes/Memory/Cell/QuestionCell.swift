//
//  QuestionCell.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/28/26.
//

import UIKit
import SnapKit
import Then

class QuestionCell: UITableViewCell {
    static let identifier = "QuestionCell"
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let numberLabel = UILabel().then {
        $0.font = UIFont.pretendard14SemiBold
        $0.textColor = UIColor.redWarning
    }
    
    private let questionLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray900
        $0.numberOfLines = 2
    }
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = UIColor.gray200
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(numberLabel)
        containerView.addSubview(questionLabel)
        containerView.addSubview(separatorLine)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        numberLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        questionLabel.snp.makeConstraints {
            $0.leading.equalTo(numberLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        separatorLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func configure(with question: Question) {
        numberLabel.text = "#\(String(format: "%02d", question.number))"
        questionLabel.text = question.text
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        numberLabel.text = nil
        questionLabel.text = nil
    }
}
