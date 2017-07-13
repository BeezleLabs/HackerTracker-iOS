//
//  Animation.swift
//  hackertracker
//
//  Created by Benjamin Humphries on 7/13/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class Animation {

    let pixelScaleFactor = 10.0
    let startingPixelScale = 3.0

    var originalSplashImage: UIImage!
    var transitionStartTime = CACurrentMediaTime()
    var originalInputCIImage = CIImage()

    private var duration: Float
    private var image: UIImage {
        didSet {
            self.onImageUpdate(image)
        }
    }

    private var onImageUpdate: (UIImage) -> ()

    init(duration: Float, image: UIImage, onImageUpdate: @escaping (UIImage) -> ()) {
        self.duration = duration
        // Initialize onImageUpdate first because setting image will trigger
        // onImageUpdate.
        self.onImageUpdate = onImageUpdate
        self.image = image
    }

    func startHackerAnimation() {
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(Animation.hackerAnimationTimerFired(displayLink:))
        )

        originalSplashImage = image
        transitionStartTime = CACurrentMediaTime()

        displayLink.add(to: .main, forMode: .defaultRunLoopMode)
    }

    @objc func hackerAnimationTimerFired(displayLink: CADisplayLink) {
        guard let pixelFilter = pixelFilter,
            let extent = originalImageExtent else {
                print ("PixelFilter is nil")
                displayLink.invalidate()
                return
        }

        let progress = min((CACurrentMediaTime() - transitionStartTime) / duration, 1.0)
        pixelFilter.setValue((pixelScaleFactor * progress) + startingPixelScale, forKey: kCIInputScaleKey)

        // After we set a value on our filter, the filter applies that value to
        // the image and filters it accordingly so we get a new outputImage
        // immediately after the setValue finishes running.
        let context = CIContext(options: nil)
        if let output = pixelFilter.outputImage?.clampingToExtent(),
            let cgImage = context.createCGImage(output, from: extent) {
            image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        }

        if progress >= 1.0 {
            image = originalSplashImage
            displayLink.invalidate()
        }
    }

    lazy var pixelFilter: CIFilter? = {
        guard let coreImage = CIImage(image: self.image)?.clampingToExtent() else {
            print ("Unable to add image pixel filter.")
            return nil
        }

        self.originalInputCIImage = coreImage

        let pixelTransitionFilter = CIFilter(name: "CIPixellate")
        pixelTransitionFilter?.setValue(coreImage, forKey: kCIInputImageKey)

        return pixelTransitionFilter
    }()


}

