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
    let mCellReuseIdentifier = "detailCell"
    var titleStr = ""
    var imageDirURLs = [String]()
    var pageURLStr = ""
    var isUpdateImage = false
    
    typealias parseHandler = (_ response : String) -> Swift.Void
    
    lazy var nowTapImageView: UIImageView = {
        let nowTapImageView = UIImageView()
        nowTapImageView.frame = UIScreen.main.bounds
        nowTapImageView.backgroundColor = .black
        nowTapImageView.contentMode = .scaleAspectFit
        return nowTapImageView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height))
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
        tableview.register(DetailTableViewCell.self, forCellReuseIdentifier: "DetailTableViewCell")
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.dataSource = self
        tableview.delegate = self
        tableview.allowsSelection = true
        tableview.allowsMultipleSelection = false
        tableview.isScrollEnabled = true
        tableview.backgroundColor = .black
        tableview.tableFooterView = UIView()
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setConstraints()
        
        let button = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = button
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = titleStr
        if isUpdateImage {
            scrapePTTData(pageURLStr) { (response) in
                self.parseHTML(response)
            }
        }
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
    
    func setConstraints(){
        view.addSubview(tableview)
        
        tableview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func scrapePTTData(_ pageURL: String, completion: @escaping parseHandler) {
        guard let url = URL(string: pageURL) else {return}
        
        Alamofire.request(url).responseString { response in
            if let responseValue = response.result.value {
               completion(responseValue)
            }
        }
    }
    
    func parseHTML(_ htmlData: String){
        do {
            for link in try Kanna.HTML(html: htmlData, encoding: String.Encoding.utf8).xpath("//div[@id='main-content']/a") {
                guard let imgURL = link["href"] else {return}
                if imgURL.hasSuffix("jpg") || imgURL.hasSuffix("png") || imgURL.hasSuffix("gif") {
                    imageDirURLs.append(imgURL)
                }
                else if imgURL.contains("imgur") {
                    scrapePTTData(imgURL) { (response) in
                        self.parseImgurlHTML(response)
                    }
                }
            }
            reloadData()
        }catch{}
    }
    
    func parseImgurlHTML(_ htmlData: String) {
        do {
            for link in try Kanna.HTML(html: htmlData, encoding: String.Encoding.utf8).xpath("/html/head/link[@rel='image_src']") {
                guard let imgurlLink = link["href"] else {return}
                self.imageDirURLs.append(imgurlLink)
                self.reloadData()
            }
        } catch{}
    }
    
    func reloadData() {
        if imageDirURLs.isEmpty {return}
        DispatchQueue.main.async {
            self.tableview.reloadData()
            //self.tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageDirURLs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell") as! DetailTableViewCell
        if isUpdateImage {
            cell.configure(imageDirURLs.count > 0 ? imageDirURLs[indexPath.row] : "")
        }
        
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
