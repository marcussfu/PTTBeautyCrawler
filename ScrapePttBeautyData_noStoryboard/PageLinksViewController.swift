//
//  PageLinksViewController.swift
//  ScrapePttBeautyData_noStoryboard
//
//  Created by Marcus.Fu on 2018/2/7.
//  Copyright © 2018年 Marcus.Fu. All rights reserved.
//

import UIKit

class PageLinksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    lazy var viewModel: PTTBeautyPageLinkDatasViewModel = {
        let viewModel = PTTBeautyPageLinkDatasViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    
    lazy var tableview: UITableView = {
        let tableview = UITableView()
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.cellIdentifier())
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.dataSource = self
        tableview.delegate = self
        tableview.backgroundColor = .black
        return tableview
    }()
    
    lazy var detailViewController: DetailViewController = {
        return DetailViewController()
    }()
    
    lazy var activityViewIndicator: UIActivityIndicatorView = {
        let activityViewIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityViewIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityViewIndicator
    }()
    
    lazy var loadMoreView: UIView = {
        let loadMoreView = UIView(frame: CGRect(x:0, y:tableview.contentSize.height,width:tableview.bounds.size.width, height:0))
        loadMoreView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        loadMoreView.backgroundColor = .black
        loadMoreView.addSubview(self.activityViewIndicator)
        self.activityViewIndicator.centerXAnchor.constraint(equalTo: loadMoreView.centerXAnchor).isActive = true
        self.activityViewIndicator.centerYAnchor.constraint(equalTo: loadMoreView.centerYAnchor).isActive = true
        
        return loadMoreView
    }()
    
    var isReachingEnd = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initBinding()
        setConstraint()
        viewModel.start()
    }
    
    @objc func tapUpdate(_ sender: UIBarButtonItem) {
        viewModel.initViewModel()
        viewModel.start()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0 && scrollView.contentSize.height > 0 {
            if scrollView.contentOffset.y >= (scrollView.contentSize.height - (scrollView.frame.size.height * 0.82)) {
                loadMorePageLinks()
            }
        }
    }
    
    func loadMorePageLinks() {
        guard isReachingEnd else {return}
        isReachingEnd = false
        
        activityViewIndicator.startAnimating()
        tableview.tableFooterView = self.loadMoreView
        tableview.tableFooterView?.frame.size.height = 60
        
        viewModel.start()
    }
    
    func initView() {
        title = "BEAUTY BOARD"
        view.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let backBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(tapUpdate(_:)))
        navigationItem.rightBarButtonItem = backBarButtonItem
    }
    
    func initBinding() {
        viewModel.pageLinkDataDictionary.addObserver(fireNow: false) { [weak self] (pageLinkDataDictionary) in
            self?.tableview.reloadData()
        }
    }
    
    func setConstraint() {
        view.addSubview(tableview)
        NSLayoutConstraint(item: tableview, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: tableview, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint(item: tableview, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: tableview, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        }
        else {
            NSLayoutConstraint(item: tableview, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: tableview, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pageLinkDataDictionary.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.cellIdentifier(), for: indexPath)
        
        cell.configure(title: viewModel.pageLinkDataDictionary.value[indexPath.row].title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        detailViewController.viewModel.pageLinkData = viewModel.pageLinkDataDictionary.value[indexPath.row]
        
        DispatchQueue.main.async {
            self.navigationController?.show(self.detailViewController, sender: self)
        }
    }
}

extension PageLinksViewController: PTTBeautyPageLinkDatasViewModelDelegate {
    func stopActivityViewIndicatorAnimating() {
        activityViewIndicator.stopAnimating()
        tableview.tableFooterView?.frame.size.height = 0
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
        isReachingEnd = true
    }
}

