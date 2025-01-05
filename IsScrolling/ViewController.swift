//
//  ViewController.swift
//  IsScrolling
//
//  Created by 김정민 on 1/5/25.
//

import UIKit
import SnapKit

extension UIScrollView {
    var isScrolling: Bool {
        if #available(iOS 17.4, *) {
            return isScrollAnimating
        } else {
            return isDecelerating ||
                   isDragging ||
                   isTracking ||
                   (layer.animation(forKey: "bounds") != nil)
        }
    }
}

class ViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.register(
            TableViewCell.self,
            forCellReuseIdentifier: TableViewCell.className
        )
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.setupUI()
    }

    private func setupUI() {
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TableViewCell.className,
            for: indexPath
        ) as? TableViewCell else { return UITableViewCell() }
        
        cell.config(row: indexPath.row)
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isScrolling else { return }
        print("### 선택된 셀: \(indexPath.row)")
    }
}

final class TableViewCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(18)
            make.leading.equalToSuperview().offset(18)
        }
    }
    
    func config(row: Int) {
        self.titleLabel.text = "\(row + 1)번째 셀"
    }
}

extension UIView {
    static var className: String {
        return String(describing: self)
    }
}
