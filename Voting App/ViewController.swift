//
//  ViewController.swift
//  Voting App
//
//  Created by John Cederholm on 10/24/17.
//  Copyright © 2017 d2i LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var scroller: PagingScrollView!
    @IBOutlet weak var explanationLabel: ExplanationLabel!
    var bottomView: BottomFadeAwayView?
    let explanationString = "This sample is an adaptation of a zoomable scrolling framework (UIScrollView-based) I made for d2i product displays. We originally incorporated the Parse framework with custom UIImageView subclasses that asynchronously added pictures, but for this example they are locally loaded for simplicity."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scroller.pagingDelegate = self
        explanationLabel.text = explanationString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scroller.reloadView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func changeLabelAlpha(alpha: CGFloat) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.explanationLabel.alpha = alpha
            }, completion: nil)
        }
    }
    
    func showBottomView(_ message: String) {
        if bottomView != nil {bottomView?.dismiss(); return}
        bottomView = BottomFadeAwayView()
        bottomView?.delegate = self
        let h:CGFloat = 50
        let startFrame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: h)
        let frame = CGRect(x: 0, y: self.view.bounds.height - h, width: self.view.bounds.width, height: h)
        bottomView?.setView(startFrame, frame: frame, message: message, superview: self.view)
    }
}

extension ViewController: PagingScrollViewDelegate {
    func pagingScroll(zoomable pagingScroll: PagingScrollView) -> Bool {
        return true
    }
    
    func pagingScroll(getPageNumber pagingScroll: PagingScrollView) -> Int {
        return 0
    }
    
    func pagingScroll(getItems pagingScroll: PagingScrollView) -> [UIImage] {
        return [UIImage(named: "d2i")!, UIImage(named: "dcIOS")!, UIImage(named: "YourCrowd")!]
    }
    
    func pagingScroll(didTap pagingScroll: PagingScrollView, tapIndex: Int) {
        let numS = HelperMethods.getNumberPlacementString(number: tapIndex + 1)
        self.showBottomView("You tapped the \(tapIndex + 1)\(numS) picture.")
    }
    
    func pagingScroll(isZoomed pagingScroll: PagingScrollView, shouldDim: Bool) {
        self.bottomView?.dismiss()
        var alpha:CGFloat!
        if shouldDim {
            alpha = 0.2
        } else {
            alpha = 1.0
        }
        self.changeLabelAlpha(alpha: alpha)
    }
}

extension ViewController: BottomFadeAwayViewDelegate {
    func dismissed() {
        bottomView = nil
    }
}
