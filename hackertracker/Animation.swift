//
//  Animation.swift
//  hackertracker
//
//  Created by Benjamin Humphries on 7/13/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class Animation {

    let context = CIContext(options: nil)

    let pixelScaleFactor = 50.0
    let startingPixelScale = 1.0

    let exposureIntensityScale = 2.0
    let maskedSplashImage = CIImage(image: #imageLiteral(resourceName: "splashMask"))?.clampingToExtent()

    let stripeCutWidth = 25.0
    let stripeMoveSpeed = 15.0
    let stripeScaleBump = 50.0
    var stripeXPostion = 0.0

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
        // Initialize onImageUpdate before image because setting image will trigger onImageUpdate.
        self.onImageUpdate = onImageUpdate
        self.image = image
        self.presentingCoreImage = presentingImage.ciImage?.clampingToExtent()
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
            print("originalImageExtent is nil")
            image = originalSplashImage
            displayLink.invalidate()
            return
        }

        let progress = min((CACurrentMediaTime() - transitionStartTime) / duration, 1.0)

        var pixellation = 0.0
        var stripProgress = 0.0

        if progress > 0.3 && progress < 0.4 {
            pixellation = 1.0 - progress
        } else if progress > 0.5 && progress < 0.7 {
            stripProgress = progress
        } else if progress > 0.6 && progress < 0.8 {
            stripProgress = progress
            pixellation = 1.0 - progress
        }

        print("pixellation \(pixellation), stripProgress\(stripProgress)")

        if let stripedImage = applyStripeFilter(progress: stripProgress),
            let blendedStripes = applyBlendFilter(with: originalInputCIImage, backgroundImage: nil, mask: stripedImage),
            let linearBumpedStripes = applyLinearBumpFilter(on: blendedStripes, progress: stripProgress),

            let pixelImage = applyPixelFilter(on: originalInputCIImage, progress: pixellation),
            let exposureImage = applyExposureFilter(on: pixelImage, progress: pixellation),
            let combinedMask = applyBlendFilter(with: stripedImage, backgroundImage: nil, mask: maskedSplashImage),
            let combinedImage = applyBlendFilter(with: linearBumpedStripes, backgroundImage: exposureImage, mask: stripProgress > 0 ? combinedMask : nil),
            let cgImage = context.createCGImage(combinedImage, from: extent) {

            image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        }

        if progress >= 1.0 {
            displayLink.invalidate()
        }
    }

    private func applyPixelFilter(on image: CIImage, progress: Double) -> CIImage? {
        guard let pixelFilter = pixelFilter else {
            print ("PixelFilter is nil")
            return nil
        }

        pixelFilter.setValue(image, forKey: kCIInputImageKey)
        pixelFilter.setValue((pixelScaleFactor * progress) + startingPixelScale, forKey: kCIInputScaleKey)

        return pixelFilter.outputImage?.clampingToExtent()
    }

    private func applyExposureFilter(on image: CIImage, progress: Double) -> CIImage? {
        guard let exposureFilter = exposureFilter else {
            print ("exposureFilter is nil")
            return nil
        }

        exposureFilter.setValue((exposureIntensityScale * progress), forKey: kCIInputEVKey)
        exposureFilter.setValue(image, forKey: kCIInputImageKey)

        return exposureFilter.outputImage?.clampingToExtent()
    }

    func applyStripeFilter(progress: Double) -> CIImage? {
        guard let stripeFilter = stripeFilter else {
            print ("stripeFilter is nil")
            return nil
        }

        guard progress > 0.0 else {
            return whiteImage
        }

        let sign = sin(progress * .pi * 2 * drand48()) < 0.5 ? 1.0 : -1.0
        stripeXPostion += drand48() * stripeMoveSpeed * sign

        stripeFilter.setValue(CIVector(x: CGFloat(stripeXPostion), y: 0), forKey: kCIInputCenterKey)
        stripeFilter.setValue(stripeCutWidth + drand48() * sign * 2, forKey: kCIInputWidthKey)


        let output = stripeFilter.outputImage?.clampingToExtent()
        return output?.applying(CGAffineTransform(rotationAngle: .pi / 2))
            .applying(CGAffineTransform(translationX: CGFloat(stripeXPostion * 500), y: 0))
    }

    func applyLinearBumpFilter(on image: CIImage, progress: Double) -> CIImage? {
        guard let linearBumpFilter = linearBumpFilter else {
            print ("linearBumpFilter is nil")
            return nil
        }

        linearBumpFilter.setValue(image, forKey: kCIInputImageKey)
        linearBumpFilter.setValue(max(progress, 0.1) * stripeScaleBump + 1, forKey: kCIInputScaleKey)

        return linearBumpFilter.outputImage?.clampingToExtent()
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

    lazy var stripeFilter: CIFilter? = {
        let stripeFilter = CIFilter(name: "CIStripesGenerator")
        stripeFilter?.setValue(self.stripeCutWidth, forKey: kCIInputWidthKey)
        stripeFilter?.setValue(CIVector(x: CGFloat(self.stripeXPostion), y: 0), forKey: kCIInputCenterKey)

        return stripeFilter
    }()

    lazy var linearBumpFilter: CIFilter? = {
        let linearBumpFilter = CIFilter(name: "CIBumpDistortionLinear")
        linearBumpFilter?.setValue(.pi / 2.0, forKey: kCIInputAngleKey)

        return linearBumpFilter
    }()

    lazy var whiteImage: CIImage? = {
        return self.coloredFilter(CIColor.white())?.outputImage?.clampingToExtent()
    }()

    private func applyBlendFilter(with inputImage: CIImage, backgroundImage: CIImage?, mask: CIImage?) -> CIImage? {
        let blendWithMaskFilter = CIFilter(name: "CIBlendWithMask")
        blendWithMaskFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        blendWithMaskFilter?.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
        blendWithMaskFilter?.setValue(mask, forKey: kCIInputMaskImageKey)

        return blendWithMaskFilter?.outputImage?.clampingToExtent()
    }

    private func coloredFilter(_ color: CIColor) -> CIFilter? {
        let filter = CIFilter(name: "CIConstantColorGenerator")
        filter?.setValue(color, forKey: kCIInputColorKey)
        return filter
    }

}

