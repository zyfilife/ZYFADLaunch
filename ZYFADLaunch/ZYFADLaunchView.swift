//
//  ZYFADLaunchView.swift
//  ZYFADLaunchExample
//
//  Created by 朱益锋 on 2018/3/16.
//  Copyright © 2018年 com.zhuyifeng. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

class ZYFADLaunchView: UIView {
    
    fileprivate var isShowFlyAnimation = false
    
    fileprivate var endDisplayingBlock: (()->Void)?
    
    var manager: SessionManager?
    
    var isFirstLaunch: Bool {
        get {
            return self.isFirstLaunch
        }
        set {
            if newValue {
                self.addSubview(self.launchImageView)
            }
        }
    }
    
    var bottomDistance: CGFloat {
        get {
            return self.bottomDistance
        }
        set {
            self.adImageView.frame.size.height -= newValue
        }
    }
    
    lazy var adImageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        return imageView
    }()
    
    lazy var skipButton: UIButton = {
        let button = UIButton(frame: CGRect(x: self.frame.size.width-60, y: 20, width: 50, height: 50))
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.backgroundColor = .black
        button.alpha = 0.6
        button.setTitle("跳", for: UIControlState.normal)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(ZYFADLaunchView.skip), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var progressView: DACircularProgressView = {
        let progressView = DACircularProgressView(frame: self.skipButton.frame)
        progressView.isUserInteractionEnabled = false
        progressView.progress = 0
        progressView.setProgress(1, animated: true, initialDelay: 0, withDuration: 3)
        return progressView
    }()
    
    lazy var launchImageView: UIImageView =  {
        let view = UIImageView(frame: CGRect(x: 0, y: 20, width: kScreenWidth, height: kScreenHeight-20))
        view.image = #imageLiteral(resourceName: "default")
        return view
    }()
    
    init(isFirstLaunch: Bool, frame: CGRect, withBlock endDisplayingBlock: @escaping ()->Void) {
        super.init(frame: frame)
        self.endDisplayingBlock = endDisplayingBlock
        self.isFirstLaunch = isFirstLaunch
        let confige = URLSessionConfiguration.default
        confige.timeoutIntervalForRequest = 3
        confige.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        manager = SessionManager(configuration: confige)
        UIApplication.shared.keyWindow?.addSubview(self)
        self.displayAdImageView(imagePath: "http://p3.pstatp.com/large/37d700040edf35875d0d", success: {
            self.displayProgressView()
            self.isShowFlyAnimation = true
            self.perform(#selector(ZYFADLaunchView.removeFromSuperview), with: nil, afterDelay: 3)
        }, failure: {
            self.isShowFlyAnimation = false
            self.removeFromSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.frame = UIScreen.main.bounds
    }
    
    override func removeFromSuperview() {
        if self.isShowFlyAnimation {
            UIView.animate(withDuration: 0.8, animations: {
                self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.alpha = 0
            }) { (done) in
                super.removeFromSuperview()
                if !self.isHidden {
                    self.endDisplayingBlock?()
                }
            }
        }else {
            super.removeFromSuperview()
            if !self.isHidden {
                self.endDisplayingBlock?()
            }
        }
    }
    
    func getImagePathFromServers(success: @escaping (_ imagePath: String) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        let parameters = Parameters(dictionaryLiteral: ("unitID", ""))
        manager?.request("http://www.1905game.com/home/newsdetail/22646.html", parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                print(response.result.value as Any)
                if let dict = response.result.value as? [String: Any] {
                    if let url = dict["adurl"] as? String{
                        success(url)
                    }
                }
            }else {
                failure(response.result.error)
            }
        }
    }
    
    func displayAdImageView(imagePath: String, success: @escaping () -> Void, failure: (() -> Void)?) {
        if let lastPreviousCachedImage = SDWebImageManager.shared().imageCache?.imageFromDiskCache(forKey: imagePath) {
            self.adImageView.image = lastPreviousCachedImage
            success()
        }else {
            self.adImageView.sd_setImage(with: URL(string: imagePath), completed: { (image, error, type, url) in
                if error == nil && image != nil {
                    success()
                }else {
                    failure?()
                }
            })
        }
    }
    
    func displayProgressView() {
        self.addSubview(self.skipButton)
        self.addSubview(self.progressView)
    }
    
    @objc func skip() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ZYFADLaunchView.removeFromSuperview), object: nil)
        self.isShowFlyAnimation = true
        self.removeFromSuperview()
    }

}
