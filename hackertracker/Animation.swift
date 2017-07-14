//
//  Animation.swift
//  hackertracker
//
//  Created by Benjamin Humphries on 7/13/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class Animation {

    let pixelDuration = 0.3
    let pixelScaleFactor = 70.0
    let startingPixelScale = 1.0

    let exposureIntensityScale = 2.0

    let context = CIContext(options: nil)

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
    private var presentingCoreImage: CIImage?

    init(duration: Double, image: UIImage, presentingImage: UIImage, onImageUpdate: @escaping (UIImage) -> ()) {
        self.duration = duration
        // Initialize onImageUpdate first because setting image will trigger
        // onImageUpdate.
        self.onImageUpdate = onImageUpdate
        self.image = image
        self.presentingCoreImage = CIImage(image: presentingImage)?.clampingToExtent()
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
            image = originalSplashImage
            displayLink.invalidate()
            return
        }

        var progress = min((CACurrentMediaTime() - transitionStartTime) / pixelDuration, 1.0)

        if progress > 0.3 {
            progress = 1.0 - progress
        }

        // Calculate pixel effect.
        if let pixelImage = applyPixelFilter(progress: progress),
            let exposureImage = applyExposureFilter(progress: progress, on: pixelImage),
            // Convert the final ciImage to cgImage to fix size issues...
            let cgImage = context.createCGImage(exposureImage, from: extent) {

            image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        }

        if progress >= 1.0 {
            //image = UIImage(ciImage: presentingCoreImage!, scale: UIScreen.main.scale, orientation: .up)
            displayLink.invalidate()
        }
    }

    private func applyPixelFilter(progress: Double) -> CIImage? {
        guard let pixelFilter = pixelFilter else {
            print ("PixelFilter is nil")
            return nil
        }

        pixelFilter.setValue((pixelScaleFactor * progress) + startingPixelScale, forKey: kCIInputScaleKey)
        pixelFilter.setValue(self.coreImage, forKey: kCIInputImageKey)

        return pixelFilter.outputImage?.clampingToExtent()
    }

    private func applyExposureFilter(progress: Double, on image: CIImage) -> CIImage? {
        guard let exposureFilter = exposureFilter else {
            print ("exposureFilter is nil")
            return nil
        }

        exposureFilter.setValue((exposureIntensityScale * progress), forKey: kCIInputEVKey)
        exposureFilter.setValue(image, forKey: kCIInputImageKey)

        return exposureFilter.outputImage?.clampingToExtent()
    }

    lazy var pixelFilter: CIFilter? = {
        let pixelTransitionFilter = CIFilter(name: "CIPixellate")
        pixelTransitionFilter?.setValue(self.coreImage, forKey: kCIInputImageKey)

        return pixelTransitionFilter
    }()

    lazy var exposureFilter: CIFilter? = {
        let exposureFilter = CIFilter(name: "CIExposureAdjust")
        exposureFilter?.setValue(self.coreImage, forKey: kCIInputImageKey)
        exposureFilter?.setValue(self.coreImage, forKey: kCIInputEVKey)

        return exposureFilter
    }()

    lazy var originalImageExtent: CGRect? = {
        return CIImage(image: self.image)?.extent
    }()

}

