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

    private var duration: Double
    private var image: UIImage {
        didSet {
            self.onImageUpdate(image)
        }
    }

    private var onImageUpdate: (UIImage) -> ()

    private var coreImage: CIImage?

    init(duration: Double, image: UIImage, onImageUpdate: @escaping (UIImage) -> ()) {
        self.duration = duration
        // Initialize onImageUpdate first because setting image will trigger
        // onImageUpdate.
        self.onImageUpdate = onImageUpdate
        self.image = image
        coreImage = CIImage(image: self.image)?.clampingToExtent()
        if let coreImage = coreImage {
            originalInputCIImage = coreImage
        }
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
        guard let extent = originalImageExtent else {
            print ("OriginalImageExtent is nil")
            image = originalSplashImage
            displayLink.invalidate()
            return
        }

        let progress = min((CACurrentMediaTime() - transitionStartTime) / duration, 1.0)

        if let rippleImage = applyRippleFilter(progress: progress, extent: extent) {
            image = rippleImage
            coreImage = CIImage(image: image)?.clampingToExtent()
            pixelFilter?.setValue(self.coreImage, forKey: kCIInputImageKey)
        }

        if let pixelImage = applyPixelFilter(progress: progress, extent: extent) {
            image = pixelImage
        }

        if progress >= 1.0 {
            image = originalSplashImage
            displayLink.invalidate()
        }
    }

    private func applyPixelFilter(progress: Double, extent: CGRect) -> UIImage? {
        guard let pixelFilter = pixelFilter else {
            print ("PixelFilter is nil")
            return nil
        }

        var result: UIImage? = nil

        pixelFilter.setValue((pixelScaleFactor * progress) + startingPixelScale, forKey: kCIInputScaleKey)

        let context = CIContext(options: nil)
        if let output = pixelFilter.outputImage?.clampingToExtent(),
            let cgImage = context.createCGImage(output, from: extent) {
            result = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        }

        return result
    }

    private func applyRippleFilter(progress: Double, extent: CGRect) -> UIImage? {
        guard let rippleFilter = rippleFilter else {
            print ("rippleFilter is nil")
            return nil
        }

        var result: UIImage? = nil

        rippleFilter.setValue(progress, forKey: kCIInputTimeKey)

        let context = CIContext(options: nil)
        if let output = rippleFilter.outputImage?.clampingToExtent(),
            let cgImage = context.createCGImage(output, from: extent) {
            result = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        }

        return result
    }

    lazy var pixelFilter: CIFilter? = {
        let pixelTransitionFilter = CIFilter(name: "CIPixellate")
        pixelTransitionFilter?.setValue(self.coreImage, forKey: kCIInputImageKey)

        return pixelTransitionFilter
    }()

    lazy var rippleFilter: CIFilter? = {
        let rippleTransitionFilter = CIFilter(name: "CIRippleTransition")
        rippleTransitionFilter?.setValue(self.coreImage, forKey: kCIInputImageKey)
        rippleTransitionFilter?.setValue(self.coreImage, forKey: kCIInputTargetImageKey)
        rippleTransitionFilter?.setValue(CIImage(), forKey: kCIInputShadingImageKey)
        rippleTransitionFilter?.setValue(
            CIVector(
                x: UIScreen.main.bounds.size.width,
                y: UIScreen.main.bounds.size.height
        ),
            forKey: kCIInputCenterKey)

        return rippleTransitionFilter
    }()

    lazy var originalImageExtent: CGRect? = {
        return CIImage(image: self.image)?.extent
    }()

}

