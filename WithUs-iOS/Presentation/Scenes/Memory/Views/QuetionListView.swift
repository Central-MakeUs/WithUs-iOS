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
    func didSelectQuestion(_ question: Question)
}

class QuestionListView: UIView {
    
    weak var delegate: QuestionListViewDelegate?
    
    private var questions: [Question] = []
    
    private let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.rowHeight = 72
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTableView()
        loadMockData()
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
    
    private func loadMockData() {
        questions = [
            Question(id: "1", number: 1, text: "우리가 서로 알게 된지 시간은?"),
            Question(id: "2", number: 2, text: "함께 간 여행지에서 제일 사진찍은 곳은 어디 가요 실은..."),
            Question(id: "3", number: 3, text: "애인이 사랑스럽던적은?"),
            Question(id: "4", number: 4, text: "기장 치울 반응 선물은?"),
            Question(id: "5", number: 5, text: "같이 같이 귀여워?"),
            Question(id: "6", number: 6, text: "데이트 왔소 중 머하게는 또 꿀은?"),
            Question(id: "7", number: 7, text: "거울 내용 중 가장 호감된 직?"),
            Question(id: "8", number: 8, text: "함께 간 여행지에서 제일 사진찍은 곳은 어디 가요 실은...")
        ]
        
        tableView.reloadData()
    }
    
    func updateQuestions(_ questions: [Question]) {
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
        print("선택된 질문: \(question.text)")
        // TODO: 질문 상세 화면으로 이동
        delegate?.didSelectQuestion(question)
    }
}

