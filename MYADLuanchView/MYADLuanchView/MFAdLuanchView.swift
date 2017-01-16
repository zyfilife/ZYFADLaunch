//
//  MFAdLuanchView.swift
//  SmartCloud
//
//  Created by ZhuYiFeng on 2016/12/28.
//  Copyright © 2016年 SmartPower. All rights reserved.
//

import UIKit

enum MFAdLuanchCoolDownType {
    case progress, text
}

class MFAdLuanchView: UIView {

    var adImageView = UIImageView()
    
    var imagePath = ""
    
    var type:MFAdLuanchCoolDownType?
    
    var skipButton = UIButton()
    
    var progressView = DACircularProgressView()
    
    var fly = false
    
    var finishBlock: EmptyBlock?
    
    var backView: UIView = {
        let view = UIView(frame:UIScreen.main.bounds)
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var launchImageView: UIImageView =  {
        let view = UIImageView(frame: CGRect(x: 0, y: 20, width: kScreenWidth, height: kScreenHeight-20))
        view.image = #imageLiteral(resourceName: "启动页")
        return view
    }()
    
    init(frame: CGRect,type: MFAdLuanchCoolDownType, firstShow: Bool) {
        super.init(frame: frame)
        self.type = type
        if firstShow {
            self.addSubview(self.backView)
        }
        self.backView.addSubview(self.launchImageView)
        UserDatasource.sharedInstance.getAdURL({ (path) in
            if path.characters.count > 0 {
                self.fly = true
                self.imagePath = path
                self.displayCachedAdImageView()
                if let url = URL(string:path) {
                    self.downLoadImageView(url: url)
                }
                self.showProgressView()
                kz_dispatch_after(3) {
                    self.removeFromSuperview()
                }
            }else {
                self.fly = false
                self.removeFromSuperview()
            }
        }) { (error) in
            self.fly = false
            self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func removeFromSuperview() {
        if self.fly {
            UIView.animate(withDuration: 0.8, animations: {
                self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.alpha = 0
            }) { (done) in
                super.removeFromSuperview()
                if !self.isHidden {
                    self.finishBlock?()
                }
            }
        }else {
            super.removeFromSuperview()
            if !self.isHidden {
                self.finishBlock?()
            }
        }
    }
    
    func displayCachedAdImageView() {
        if let lastPreviousCachedImage = SDWebImageManager.shared().imageCache.imageFromDiskCache(forKey: self.imagePath) {
            self.showImageView(lastPreviousCachedImage)
        }else {
            self.isHidden = true
        }
    }
    
    func showImageView(_ image: UIImage) {
        self.adImageView = UIImageView(frame: UIScreen.main.bounds)
        if let url = URL(string: self.imagePath) {
            self.adImageView.sd_setImage(with: url)
        }
        self.addSubview(self.adImageView)
    }
    
    func downLoadImageView(url: URL) {
        SDWebImageManager.shared().downloadImage(with: url, options: SDWebImageOptions.avoidAutoSetImage, progress: nil) { (image, error, type, done, url) in
            if error == nil && image != nil {
                print("图片缓存完成")
            }else {
                print(error as Any)
            }
        }
    }
    
    func showProgressView() {
        guard let type = self.type else {
            return
        }
        switch type {
        case .progress:
            self.skipButton = UIButton(frame: CGRect(x: kScreenWidth-60, y: 20, width: 50, height: 50))
            self.skipButton.layer.cornerRadius = 25
            self.skipButton.clipsToBounds = true
            self.skipButton.backgroundColor = .black
            self.skipButton.alpha = 0.6
            self.skipButton.setTitle("跳", for: UIControlState.normal)
            self.skipButton.titleLabel?.textAlignment = .center
            self.skipButton.addTarget(self,
                                      action: #selector(MFAdLuanchView.skip),
                                      for: UIControlEvents.touchUpInside)
            self.addSubview(self.skipButton)
            self.progressView = DACircularProgressView(frame: CGRect(x: kScreenWidth-60, y: 20, width: 50, height: 50))
            self.progressView.isUserInteractionEnabled = false
            self.progressView.progress = 0
            self.addSubview(self.progressView)
            self.progressView.setProgress(1, animated: true, initialDelay: 0, withDuration: 3)
            break
        default:
            break
        }
    }
    
    func skip() {
        UIView.animate(withDuration: 0.4, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.alpha = 0
        }) { (done) in
            self.isHidden = true
            self.finishBlock?()
        }
    }
}
