//
//  DetailViewController.swift
//  ScrapePttBeautyData_noStoryboard
//
//  Created by Marcus.Fu on 2018/2/8.
//  Copyright © 2018年 Marcus.Fu. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import Kanna

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    lazy var viewModel: PTTBeautyDetailViewModel = {
        return PTTBeautyDetailViewModel()
    }()
    
    lazy var nowTapImageView: UIImageView = {
        let nowTapImageView = UIImageView()
        nowTapImageView.frame = UIScreen.main.bounds
        nowTapImageView.backgroundColor = .black
        nowTapImageView.contentMode = .scaleAspectFit
        return nowTapImageView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.height))
        scrollView.backgroundColor = UIColor.black
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        scrollView.addGestureRecognizer(tap)
        return scrollView
    }()
    
    lazy var tableview: UITableView = {
        let tableview = UITableView()
        tableview.register(DetailTableViewCell.self, forCellReuseIdentifier: DetailTableViewCell.cellIdentifier())
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.dataSource = self
        tableview.delegate = self
        tableview.backgroundColor = .black
        tableview.tableFooterView = UIView()
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initBinding()
        setConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollView.removeFromSuperview()
    }
    
    @objc func back(){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func initView() {
        view.backgroundColor = .black
        let button = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = button
    }
    
    func initBinding() {
        viewModel.title.addObserver { [weak self] (title) in
            self?.title = title
        }
        
        viewModel.imageUrls.addObserver(fireNow: false) { (imageUrls) in
            self.tableview.reloadData()
        }
    }
    
    func setConstraints(){
        view.addSubview(tableview)
        
        tableview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.imageUrls.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.cellIdentifier()) as! DetailTableViewCell
        cell.configure(viewModel.imageUrls.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellImageView = tableView.cellForRow(at: indexPath)?.viewWithTag(1) as! UIImageView
        
        nowTapImageView.image = cellImageView.image
        scrollView.addSubview(nowTapImageView)
        view.addSubview(scrollView)
    }
}

extension DetailViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nowTapImageView
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
}
