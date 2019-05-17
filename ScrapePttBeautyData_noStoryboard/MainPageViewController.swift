//
//  MainPageViewController.swift
//  ScrapePttBeautyData_noStoryboard
//
//  Created by Marcus.Fu on 2018/2/7.
//  Copyright © 2018年 Marcus.Fu. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class MainPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let mCellReuseIdentifier = "mCell"
    let beforeURL = "https://www.ptt.cc"
    var array_Titles = [String]()
    var array_URLs = [String]()
    var pageCount = 0
    var nowPageURL = ""
    
    lazy var tableview: UITableView = {
        let tableview = UITableView()
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: mCellReuseIdentifier)
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.dataSource = self
        tableview.delegate = self
        tableview.backgroundColor = .black
        return tableview
    }()
    
    let detailViewController = DetailViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BEAUTY BOARD"
        view.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let backBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(tapUpdate(_:)))
        self.navigationItem.rightBarButtonItem = backBarButtonItem
        
        updateList()
        setConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func tapUpdate(_ sender: UIBarButtonItem) {
        updateList()
    }
    
    func updateList() {
        pageCount = 5
        if !array_Titles.isEmpty {
            array_Titles.removeAll()
        }
        if !array_URLs.isEmpty {
            array_URLs.removeAll()
        }
        nowPageURL = "\(beforeURL)/bbs/Beauty/index.html"
        scrapePTTData(nowPageURL)
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
        return array_Titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: mCellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = array_Titles[indexPath.row]
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentDataToDestinationViewController(indexPath.row)
    }
    
    func scrapePTTData(_ urlString: String) {
        guard let url = URL(string: urlString) else {return}
        
        Alamofire.request(url)
            .responseString { response in
                if let resultValue = response.result.value {
                    self.parseHTML(resultValue)
                }
        }
    }

    func parseHTML(_ htmlData: String) {
        do {
                if (pageCount > 0) {
                    pageCount -= 1
                    // previous page
                    for link in try Kanna.HTML(html: htmlData, encoding: String.Encoding.utf8).xpath("//div[@class='btn-group btn-group-paging']/a") {
                        if (link.text?.contains("上頁") == true) {
                            guard let lastPageURL = link["href"] else {return}
                            nowPageURL = beforeURL + lastPageURL
                        }
                    }
                    
                    for link in try Kanna.HTML(html: htmlData, encoding: String.Encoding.utf8).xpath("//div[@class='r-ent']") {
                        let imageLink = link.at_xpath("div[@class='title']/a")
                        if imageLink?.text?.hasPrefix("[正妹") == true {
                            if let imageLinkText = imageLink?.text {
                                let index = imageLinkText.index(imageLinkText.startIndex, offsetBy: 4)
                                array_Titles.append(String(imageLinkText[index...]))
                                guard let contentURL = imageLink?["href"] else {return}
                                array_URLs.append(beforeURL + contentURL)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                    scrapePTTData(nowPageURL)
                }
        } catch{}
    }
    
    func presentDataToDestinationViewController(_ indexPathRow: Int) {
        detailViewController.isUpdateImage = false
        if detailViewController.titleStr != array_Titles[indexPathRow] {
            detailViewController.titleStr = array_Titles[indexPathRow]
            detailViewController.pageURLStr = array_URLs[indexPathRow]
            detailViewController.imageDirURLs.removeAll()
            detailViewController.isUpdateImage = true
        }
        DispatchQueue.main.async {
            self.navigationController?.show(self.detailViewController, sender: self)
            self.detailViewController.tableview.reloadData()
        }
    }
}

