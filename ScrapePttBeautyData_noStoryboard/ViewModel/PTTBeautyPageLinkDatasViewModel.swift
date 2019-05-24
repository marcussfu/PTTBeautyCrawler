//
//  PTTBeautyPageLinkDatasViewModel.swift
//  ScrapePttBeautyData_noStoryboard
//
//  Created by marcus fu on 2019/5/22.
//  Copyright © 2019 Marcus.Fu. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

protocol PTTBeautyPageLinkDatasViewModelDelegate {
    func stopActivityViewIndicatorAnimating()
}

class PTTBeautyPageLinkDatasViewModel {
    var pageLinkDataDictionary = Observable<[PageLinkData]>(value: [])
    
    var beforeURL: String!
    var pageCount: Int!
    var nowPageURL: String!
    
    var delegate: PTTBeautyPageLinkDatasViewModelDelegate!
    
    init() {
        initViewModel()
    }
    
    func initViewModel() {
        pageLinkDataDictionary.value.removeAll()
        beforeURL = "https://www.ptt.cc"
        
        nowPageURL = beforeURL + "/bbs/Beauty/index.html"
    }
    
    func start() {
        pageCount = 5
        scrapePTTData(nowPageURL)
    }
    
    func scrapePTTData(_ urlString: String) {
        guard let url = URL(string: urlString) else {return}
        
        Alamofire.request(url).responseString { response in
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
                            guard let contentURL = imageLink?["href"] else {return}
                            pageLinkDataDictionary.value.append(PageLinkData(String(imageLinkText[index...]), url: beforeURL + contentURL))
                        }
                    }
                }
                scrapePTTData(nowPageURL)
            }
            else {
                delegate.stopActivityViewIndicatorAnimating()
            }
        } catch{}
    }
}
