//
//  PictureImageView.swift
//  Voting Framework
//
//  Created by John Cederholm on 10/24/17.
//  Copyright © 2017 d2i LLC. All rights reserved.
//

import Foundation
import UIKit

class PictureImageView: UIImageView {
    var done = Bool()
    var activityIndicator: UIActivityIndicatorView! = nil
    let activityIndicatorSize:CGFloat = 100
    
    func setActivityIndicator() {
        if activityIndicator != nil {return}
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.frame = CGRect(x: (self.bounds.width / 2) - (activityIndicatorSize / 2),
                                         y: (self.bounds.height / 2) - (activityIndicatorSize / 2),
                                         width: activityIndicatorSize,
                                         height: activityIndicatorSize)
        self.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    override func draw(_ rect: CGRect) {
        if activityIndicator == nil {return}
        self.backgroundColor = UIColor.white
        activityIndicator.frame = CGRect(x: (rect.size.width / 2) - (activityIndicatorSize / 2),
                                         y: (rect.size.height / 2) - (activityIndicatorSize / 2),
                                         width: activityIndicatorSize,
                                         height: activityIndicatorSize)
    }
    
    func removeActivityIndicator() {
        if activityIndicator == nil {return}
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    func fadeIn() {
        DispatchQueue.main.async {
            self.alpha = 0
            UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.alpha = 1.0
            }, completion: nil)
        }
    }
    
}

class PictureScrollView: UIScrollView {
    
    var imageView: UIImageView!
    
    override func draw(_ rect: CGRect) {
        
        self.delegate = self
        let image = UIImage(named: "RightOverlay")!
        imageView = PictureImageView(image: image)
        imageView.backgroundColor = UIColor.white
        imageView.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size:image.size)
        
        // 2
        self.addSubview(imageView)
        self.contentSize = image.size
        
        // 3
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PictureScrollView.scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleTapRecognizer)
        
        // 4
        let scrollViewFrame = self.bounds
        let scaleWidth = scrollViewFrame.size.width / self.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / self.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        self.minimumZoomScale = minScale
        self.maximumZoomScale = 2.0
        // 5
        self.zoomScale = minScale
        
        // 6
        centerScrollViewContents()
        
    }
    
    func centerScrollViewContents() {
        let boundsSize = self.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
        
    }
    
    @objc func scrollViewDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.location(in: imageView)
        
        // 2
        var newZoomScale = self.zoomScale * 1.5
        newZoomScale = min(newZoomScale, self.maximumZoomScale)
        
        // 3
        let scrollViewSize = self.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h);
        
        // 4
        self.zoom(to: rectToZoomTo, animated: true)
    }
}

extension PictureScrollView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
