//
//  PagingScrollZoomable.swift
//  Voting Framework
//
//  Created by John Cederholm on 10/24/17.
//  Copyright © 2017 d2i LLC. All rights reserved.
//

import Foundation
import UIKit

protocol ZoomableScrollViewDelegate: class {
    func zoomableScrollView(useImage zoomableScrollView: ZoomableScrollView) -> UIImage
    func zoomableScrollView(shouldDimExplanation zoomableScrollView: ZoomableScrollView, shouldDim: Bool)
}

extension ZoomableScrollViewDelegate {
    func zoomableScrollView(useImage zoomableScrollView: ZoomableScrollView) -> UIImage {
        return UIImage()
    }
}

class ZoomableScrollView: UIScrollView {
    var imageView = UIImageView()
    var zoomDelegate: ZoomableScrollViewDelegate?
    
    func setImage(image: UIImage) {
        self.delegate = self
        self.addSubview(imageView)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size:self.bounds.size)
        self.contentSize = imageView.frame.size
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ZoomableScrollView.scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleTapRecognizer)
        let scrollViewFrame = self.bounds
        let scaleWidth = scrollViewFrame.size.width / self.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / self.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        self.minimumZoomScale = minScale
        self.maximumZoomScale = PagingScrollOptions.options.zoomFactor
        self.zoomScale = minScale
        imageView.image = image
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
        let pointInView = recognizer.location(in: imageView)
        var newZoomScale = self.zoomScale * 1.5
        newZoomScale = min(newZoomScale, self.maximumZoomScale)
        let scrollViewSize = self.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h);
        self.zoom(to: rectToZoomTo, animated: true)
    }
}

extension ZoomableScrollView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale == 1.0 {
            self.zoomDelegate?.zoomableScrollView(shouldDimExplanation: self, shouldDim: false)
        } else {
            self.zoomDelegate?.zoomableScrollView(shouldDimExplanation: self, shouldDim: true)
        }
    }
}
