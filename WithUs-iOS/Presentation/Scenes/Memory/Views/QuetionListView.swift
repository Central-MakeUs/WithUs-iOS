//
//  QuestionListView.swift
//  WithUs-iOS
//
//  Created on 1/28/26.
//

import UIKit
import SnapKit
import Then

protocol QuestionListViewDelegate: AnyObject {
    func didSelectQuestion(_ question: ArchiveQuestionItem)
    func didScrollToBottomQuestion()
}

class QuestionListView: UIView {
    
    weak var delegate: QuestionListViewDelegate?
    
    private var questions: [ArchiveQuestionItem] = []
    
    private let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.rowHeight = 72
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuestionCell.self, forCellReuseIdentifier: QuestionCell.identifier)
    }
    
    func updateQuestions(_ questions: [ArchiveQuestionItem]) {
        self.questions = questions
        tableView.reloadData()
    }
}

extension QuestionListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: QuestionCell.identifier,
            for: indexPath
        ) as? QuestionCell else {
            return UITableViewCell()
        }
        
        let question = questions[indexPath.row]
        cell.configure(with: question)
        return cell
    }
}

extension QuestionListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let question = questions[indexPath.row]
        print("선택된 질문: \(question.coupleQuestionId)")
        // TODO: 질문 상세 화면으로 이동
        delegate?.didSelectQuestion(question)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        if offsetY > contentHeight - height - 100 {
            delegate?.didScrollToBottomQuestion()
        }
    }
}

