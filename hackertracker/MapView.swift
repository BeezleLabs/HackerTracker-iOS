//
//  MapView.swift
//  hackertracker
//
//  Created by Christopher Mays on 5/31/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class MapView: UIView {

    override class var layerClass: Swift.AnyClass {
        
        get{
            return CATiledLayer.self
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tempTiledLayer = self.layer as! CATiledLayer
        tempTiledLayer.levelsOfDetail = 5
        tempTiledLayer.levelsOfDetailBias = 2
    }

    
    override func draw(_ rect: CGRect) {
            let newframe = CGRect(x: 0, y: 0, width: 375, height: 535);
            Map.drawCanvas1(withFrame: newframe , resizing: MapResizingBehaviorAspectFit)
    }

}
