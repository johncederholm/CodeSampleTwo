//
//  PagingScroll.swift
//  Voting Framework
//
//  Created by John Cederholm on 10/24/17.
//  Copyright © 2017 d2i LLC. All rights reserved.
//
import Foundation
import UIKit

protocol PagingScrollViewDelegate: class {
    func pagingScroll(getItems pagingScroll: PagingScrollView) -> [UIImage]
    func pagingScroll(getPageNumber pagingScroll: PagingScrollView) -> Int
    func pagingScroll(zoomable pagingScroll: PagingScrollView) -> Bool
    func pagingScroll(didTap pagingScroll: PagingScrollView, tapIndex: Int)
    func pagingScroll(isZoomed pagingScroll: PagingScrollView, shouldDim: Bool)
}

extension PagingScrollViewDelegate {
    func pagingScroll(getItems pagingScroll: PagingScrollView) -> [UIImage] {
        return []
    }
    func pagingScroll(getPageNumber pagingScroll: PagingScrollView) -> Int {
        return 0
    }
    func pagingScroll(zoomable pagingScroll: PagingScrollView) -> Bool {
        return false
    }
}

class PagingScrollView: UIScrollView {
    var pagingDelegate: PagingScrollViewDelegate?
    var pageControl = UIPageControl()
    var pageViews: [ZoomableScrollView?] = []
    var usableImages: [UIImage] {
        get {
            return pagingDelegate?.pagingScroll(getItems: self) ?? []
        }
    }
    var pageNumber: Int {
        get {
            return pagingDelegate?.pagingScroll(getPageNumber: self) ?? 0
        }
    }
    
    func reloadView() {
        self.backgroundColor = UIColor.white
        self.setUp()
    }
    
    func setUp() {
        let pageCount = usableImages.count
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        let pagesScrollViewSize = self.frame.size
        self.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageCount), height: pagesScrollViewSize.height)
        self.isUserInteractionEnabled = true
        self.isPagingEnabled = true
        self.delegate = self
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        self.contentOffset.x = CGFloat(pageNumber) * self.frame.size.width
        loadVisiblePages()
    }
    
    func loadPage(_ page: Int) {
        if page < 0 || page >= pageViews.count {
            return
        }
        if let _ = pageViews[page] { } else {
            var frame = self.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            let imageFrame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height))
            let newPageView = ZoomableScrollView()
            newPageView.frame = imageFrame
            newPageView.zoomDelegate = self
            self.addSubview(newPageView)
            if usableImages.indices.contains(page) {
                newPageView.setImage(image: usableImages[page])
                pageViews[page] = newPageView
                let tap = PagingScrollTap(target: self, action: #selector(PagingScrollView.tapped(tap:)))
                tap.tapIndex = page
                newPageView.addGestureRecognizer(tap)
            }
        }
    }
    @objc func tapped(tap: PagingScrollTap) {
        guard let tapIndex = tap.tapIndex else {return}
        self.pagingDelegate?.pagingScroll(didTap: self, tapIndex: tapIndex)
    }
    func loadVisiblePages() {
        let pageWidth = self.frame.size.width
        let page = Int(floor((self.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        pageControl.currentPage = page
        let firstPage = page - 1
        let lastPage = page + 1
        
        if firstPage > 0 {
            for index in 0 ..< firstPage {
                purgePage(index)
            }
        }
        if firstPage <= lastPage {
            for index in firstPage ... lastPage {
                loadPage(index)
            }
        }
        if (lastPage + 1) < pageViews.count {
            for index in lastPage + 1 ..< pageViews.count {
                purgePage(index)
            }
        }
    }
    
    func purgePage(_ page: Int) {
        if page < 0 || page >= pageViews.count {
            return
        }
        
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
}

extension PagingScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadVisiblePages()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.pagingDelegate?.pagingScroll(isZoomed: self, shouldDim: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.pagingDelegate?.pagingScroll(isZoomed: self, shouldDim: false)
    }
}

extension PagingScrollView: ZoomableScrollViewDelegate {
    func zoomableScrollView(shouldDimExplanation zoomableScrollView: ZoomableScrollView, shouldDim: Bool) {
        self.pagingDelegate?.pagingScroll(isZoomed: self, shouldDim: shouldDim)
    }
}
