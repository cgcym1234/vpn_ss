//
//  WebViewController.swift
//  Lead
//
//  Created by yuany on 2019/3/13.
//  Copyright © 2019 yicheng. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class WebViewController: UIViewController {

    var url: URL!
    
    fileprivate lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration().then {
            $0.allowsInlineMediaPlayback = true
            $0.mediaTypesRequiringUserActionForPlayback = []
        }
        let web: WKWebView = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        return web
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        view.insertSubview(webView, at: 0)
        webView.load(.init(url: url))
        webView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }
    
    static func push(with url: String, title: String? = nil) {
        guard let fromVC = UIViewController.appTopViewController else {
            return
        }
        
        let web = WebViewController()
        web.url = URL(string: url)
        web.title = title
        fromVC.navigationController?.pushViewController(web, animated: true)
    }

}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        print(url)
        decisionHandler(.allow)
    }
}
