//
//  BottomFadeAwayView.swift
//  Voting App
//
//  Created by John Cederholm on 10/25/17.
//  Copyright © 2017 d2i LLC. All rights reserved.
//

import UIKit

protocol BottomFadeAwayViewDelegate: class {
    func dismissed()
}

class BottomFadeAwayView: UIView {
    var delegate: BottomFadeAwayViewDelegate?
    
    func setView(_ startFrame: CGRect, frame: CGRect, message: String, superview: UIView) {
        self.frame = startFrame
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.red.cgColor,
                           UIColor.red.withAlphaComponent(0.25).cgColor]
        self.layer.insertSublayer(gradient, at: 0)
        
        self.backgroundColor = UIColor.red.withAlphaComponent(0.75)
        
        UIView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.frame = frame
        }, completion: {done in
            
        })
        
        let label = UILabel()
        label.frame = self.bounds
        label.font = UIFont(name: "Arial", size: 12)
        label.text = message
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let closeButton = UIButton()
        let buttonSize = self.bounds.height / 2
        let buttonX = self.bounds.width - buttonSize
        closeButton.frame = CGRect(x: buttonX, y: 0, width: buttonSize, height: buttonSize)
        closeButton.setTitle("x", for: UIControlState())
        closeButton.setTitleColor(UIColor.white, for: UIControlState())
        closeButton.addTarget(self, action: #selector(BottomFadeAwayView.dismiss), for: .touchUpInside)
        
        self.addSubview(closeButton)
        self.addSubview(label)
        
        superview.addSubview(self)
    }
    
    @objc func dismiss() {
        guard let superview = self.superview else {return}
        UIView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.frame = CGRect(x: 0, y: superview.bounds.height, width: superview.bounds.width, height: self.frame.height)
        }, completion: {complete in
            self.removeFromSuperview()
            self.delegate?.dismissed()
            return
        })
    }
}
