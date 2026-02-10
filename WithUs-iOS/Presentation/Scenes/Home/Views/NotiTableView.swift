//
//  NotiTableView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/10/26.
//

import UIKit
import SnapKit
import Then

// MARK: - Model
struct NotiItem {
    let image: UIImage?
    let title: String
    let body: String
    let time: String
    let isRead: Bool
}

// MARK: - Cell
final class NotiTableViewCell: UITableViewCell {

    static let identifier = "NotiTableViewCell"

    private let notiImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .gray200
    }

    private let titleLabel = UILabel().then {
        $0.font = .pretendard16SemiBold
        $0.textColor = .gray900
        $0.numberOfLines = 1
    }

    private let bodyLabel = UILabel().then {
        $0.font = .pretendard14Regular
        $0.textColor = .gray500
        $0.numberOfLines = 1
    }

    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
    }

    private let timeLabel = UILabel().then {
        $0.font = .pretendard14Regular
        $0.textColor = .gray500
        $0.textAlignment = .right
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .white

        contentView.addSubview(notiImageView)
        contentView.addSubview(infoStackView)
        contentView.addSubview(timeLabel)

        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(bodyLabel)

        notiImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }

        infoStackView.snp.makeConstraints {
            $0.leading.equalTo(notiImageView.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-16)
        }

        timeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }

    func configure(with item: NotiItem) {
        notiImageView.image = item.image
        titleLabel.text = item.title
        bodyLabel.text = item.body
        timeLabel.text = item.time
        backgroundColor = item.isRead ? .white : .gray100
    }
}

final class NotiTableView: UIView {

    private let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.separatorStyle = .none
        $0.rowHeight = 93
        $0.register(NotiTableViewCell.self, forCellReuseIdentifier: NotiTableViewCell.identifier)
    }

    private var items: [NotiItem] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(tableView)
        tableView.dataSource = self

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(with items: [NotiItem]) {
        self.items = items
        tableView.reloadData()
    }
}

extension NotiTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotiTableViewCell.identifier,
            for: indexPath
        ) as? NotiTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: items[indexPath.row])
        return cell
    }
}
