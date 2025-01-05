//
//  ViewController.swift
//  IsScrolling
//
//  Created by 김정민 on 1/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

extension UIView {
    var isParentScrolling: Bool {
        return (superview as? UIScrollView)?.isScrolling ?? false
    }
}

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
    
    private lazy var cellButton: UIButton = {
        let button = UIButton()
        button.setTitle("Button", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        return button
    }()
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.setupUI()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(self.titleLabel)
        contentView.addSubview(self.cellButton)
        
        self.titleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(18)
            make.leading.equalToSuperview().offset(18)
        }
        
        self.cellButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(18)
            make.size.equalTo(CGSize(width: 60, height: 30))
            make.centerY.equalToSuperview()
        }
    }
    
    private func bind() {
        self.cellButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in
                guard !owner.isParentScrolling else { return }
                print("### 셀 버튼 탭 - 오너: \(owner)")
            })
            .disposed(by: self.disposeBag)
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
