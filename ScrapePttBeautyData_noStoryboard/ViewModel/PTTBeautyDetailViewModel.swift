//
//  PTTBeautyDetailViewModel.swift
//  ScrapePttBeautyData_noStoryboard
//
//  Created by marcus fu on 2019/5/23.
//  Copyright © 2019 Marcus.Fu. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

class PTTBeautyDetailViewModel {
    typealias parseHandler = (_ response : String) -> Swift.Void
    
    let title = Observable<String>(value: "")
    let imageUrls = Observable<[String]>(value: [String]())
    
    var pageURL = ""
    
    var pageLinkData: PageLinkData {
        didSet {
            if pageLinkData.title != "" && pageLinkData.title != title.value {
                imageUrls.value.removeAll()
                title.value = pageLinkData.title
                pageURL = pageLinkData.url
                start()
            }
        }
    }
    
    init(pageLinkData: PageLinkData = PageLinkData()) {
        self.pageLinkData = pageLinkData
    }
    
    func start() {
        scrapePTTData(pageURL) { (response) in
            self.parseHTML(response)
        }
    }
    
    func scrapePTTData(_ urlString: String, completion: @escaping parseHandler) {
        guard let url = URL(string: urlString) else {return}
        
        Alamofire.request(url).responseString { response in
            if let responseValue = response.result.value {
                completion(responseValue)
            }
        }
    }
    
    func parseHTML(_ htmlData: String){
        do {
            for link in try Kanna.HTML(html: htmlData, encoding: String.Encoding.utf8).xpath("//div[@id='main-content']/a") {
                guard let imgUrl = link["href"] else {return}
                if imgUrl.hasSuffix("jpg") || imgUrl.hasSuffix("png") || imgUrl.hasSuffix("gif") {
                    imageUrls.value.append(imgUrl)
                }
                else if imgUrl.contains("imgur") {
                    scrapePTTData(imgUrl) { (response) in
                        self.parseImgurlHTML(response)
                    }
                }
            }
        }catch{}
    }
    
    func parseImgurlHTML(_ htmlData: String) {
        do {
//            var type: String?
//            for link in try Kanna.HTML(html: htmlData, encoding: String.Encoding.utf8).xpath("/html/head/meta[@property='og:type']") {
//                type = link["content"] ?? ""
//            }
//
//            if type == "video.other" {
//                for link in try Kanna.HTML(html: htmlData, encoding: String.Encoding.utf8).xpath("/html/head/meta[@name='twitter:player:stream']") {
//                    guard let videoUrl = link["content"] else {return}
//                    imageUrls.value.append(videoUrl)
//                }
//            }
//            else if type == "article" {
//                for link in try Kanna.HTML(html: htmlData, encoding: String.Encoding.utf8).xpath("/html/head/meta[@property='og:image']") {
//                    guard let imgUrl = link["content"]?.components(separatedBy: "?")[0] else {return}
//                    imageUrls.value.append(imgUrl)
//                }
//            }
//
            
            for link in try Kanna.HTML(html: htmlData, encoding: String.Encoding.utf8).xpath("/html/head/meta[@property='og:image']") {
                guard let imgUrl = link["content"]?.components(separatedBy: "?")[0] else {return}
                imageUrls.value.append(imgUrl)
            }
        } catch {}
    }
}
