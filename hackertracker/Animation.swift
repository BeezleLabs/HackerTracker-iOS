//
//  Animation.swift
//  hackertracker
//
//  Created by Benjamin Humphries on 7/13/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class Animation {

    private var image: UIImage {
        didSet {
            self.onImageUpdate(image)
        }
    }

    private var onImageUpdate: (UIImage) -> ()

