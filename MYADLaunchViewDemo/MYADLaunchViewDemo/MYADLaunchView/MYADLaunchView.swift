//
//  MYADLaunchView.swift
//  MYADLaunchViewDemo
//
//  Created by 朱益锋 on 2017/1/23.
//  Copyright © 2017年 朱益锋. All rights reserved.
//

import UIKit

enum MYCoolDownType {
    case progress, text
}

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

class MYADLaunchView: UIView {
    
    var coolDownType:MYCoolDownType = .progress
    
    fileprivate var isShowFlyAnimation = false
    
    fileprivate var endDisplayingBlock: (()->Void)?
    
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
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var skipButton: UIButton = {
        let button = UIButton(frame: CGRect(x: kScreenWidth-60, y: 20, width: 50, height: 50))
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.backgroundColor = .black
        button.alpha = 0.6
        button.setTitle("跳", for: UIControlState.normal)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(MYADLaunchView.skip), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var progressView: DACircularProgressView = {
        let progressView = DACircularProgressView(frame: CGRect(x: kScreenWidth-60, y: 20, width: 50, height: 50))
        progressView.isUserInteractionEnabled = false
        progressView.progress = 0
        progressView.setProgress(1, animated: true, initialDelay: 0, withDuration: 3)
        return progressView
    }()
    
    lazy var launchImageView: UIImageView =  {
        let view = UIImageView(frame: UIScreen.main.bounds)
        view.image = #imageLiteral(resourceName: "default")
        return view
    }()
    
    init(coolDownType: MYCoolDownType, isFirstLaunch: Bool, frame: CGRect, withBlock endDisplayingBlock: @escaping ()->Void) {
        super.init(frame: frame)
        self.endDisplayingBlock = endDisplayingBlock
        self.coolDownType = coolDownType
        self.isFirstLaunch = isFirstLaunch
        UIApplication.shared.keyWindow?.addSubview(self)
        self.getImagePathFromWebServers(success: { (imagePath) in
            self.isShowFlyAnimation = true
            self.displayAdImageView(imagePath: imagePath, success: { 
                self.addSubview(self.adImageView)
                self.displayProgressView()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3, execute: {
                    self.removeFromSuperview()
                })
            }, failure: { 
                self.removeFromSuperview()
            })
        }) { (error) in
            self.isShowFlyAnimation = false
            self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func getImagePathFromWebServers(success: @escaping (_ imagePath: String) -> Void, failure: @escaping (_ error: NSError) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
            let imagePath: String? = "http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1211/08/c1/15469697_1352365402404.jpg"
            if imagePath != nil && imagePath!.characters.count > 0 {
                success(imagePath!)
            }else {
                let error = NSError(domain: "www.zyfilife.com", code: 1, userInfo: nil)
                failure(error)
            }
        }
    }
    
    func displayAdImageView(imagePath: String, success: @escaping () -> Void, failure: (() -> Void)?) {
        if let lastPreviousCachedImage = SDWebImageManager.shared().imageCache?.imageFromDiskCache(forKey: imagePath) {
            self.adImageView.image = lastPreviousCachedImage
            self.addSubview(self.adImageView)
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
        switch self.coolDownType {
        case .progress:
            self.addSubview(self.skipButton)
            self.addSubview(self.progressView)
        default:
            break
        }
    }
    
    func skip() {
        self.removeFromSuperview()
    }
}
