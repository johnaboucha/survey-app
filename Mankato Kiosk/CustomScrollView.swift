//
//  CustomScrollView.swift
//  Mankato Kiosk
//
//  Created by John Boucha on 10/13/15.
//  Copyright © 2015 John Boucha. All rights reserved.
//

import UIKit

protocol PassTouchesScrollViewDelegate {
    func touchBegan()
}

class CustomScrollView: UIScrollView {
    
    var delegatePass : PassTouchesScrollViewDelegate?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // Notify it's delegate about touched
        self.delegatePass?.touchBegan()
        
        super.touchesBegan(touches, withEvent: event)
        
        if self.dragging == true {
            self.nextResponder()?.touchesBegan(touches, withEvent: event)
        } else {
            super.touchesBegan(touches, withEvent: event)
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)  {
        
        // Notify it's delegate about touched
        self.delegatePass?.touchBegan()

        
        if self.dragging == true {
            self.nextResponder()?.touchesMoved(touches, withEvent: event)
        } else {
            super.touchesMoved(touches, withEvent: event)
        }
    }
    
}