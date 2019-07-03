//
//  Animation.swift
//  hackertracker
//
//  Created by Benjamin Humphries on 7/13/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class Animation {

    let context: CIContext = {
        let eaglContext = EAGLContext(api: .openGLES2)
        return CIContext(eaglContext: eaglContext!, options: convertToOptionalCIContextOptionDictionary([convertFromCIContextOption(CIContextOption.workingColorSpace) : NSNull()]))
    }()

    let pixelScaleFactor = 50.0
    var startingPixelScale = 1.0

    let exposureIntensityScale = 2.0
    let maskedSplashImage = CIImage(image: #imageLiteral(resourceName: "splashMask"))?.clampedToExtent()

    let stripeCutWidth = 25.0
    let stripeMoveSpeed = 15.0
    let stripeScaleBump = 50.0
    var stripeXPostion = 0.0

    var originalSplashImage: UIImage!
    var transitionStartTime = CACurrentMediaTime()
    var originalInputCIImage = CIImage()

    var isPlaying = false

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
        // Initialize onImageUpdate before image because setting image will trigger onImageUpdate.
        self.onImageUpdate = onImageUpdate
        self.image = image
        coreImage = CIImage(image: self.image)?.clampedToExtent()
        if let coreImage = coreImage {
            originalInputCIImage = coreImage
        }
    }

    func stopPlaying() {
        isPlaying = false
        image = originalSplashImage
    }

    func startPixelAnimation() {
        startingPixelScale = 50.0
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(pixelAnimationTimerFired(displayLink:))
        )

        originalSplashImage = image
        transitionStartTime = CACurrentMediaTime()

        displayLink.add(to: .main, forMode: RunLoop.Mode.common)
        isPlaying = true
    }

    @objc func pixelAnimationTimerFired(displayLink: CADisplayLink) {
        guard let extent = originalImageExtent else {
            print("originalImageExtent is nil")
            stopPlaying()
            displayLink.invalidate()
            return
        }

        let progress = min((CACurrentMediaTime() - transitionStartTime) / duration, 1.0)

        var pixellation = progress

        if progress > 0.7 {
            pixellation = 1.0 - progress
        }

        if let pixelImage = applyPixelFilter(on: originalInputCIImage, progress: pixellation),
            let cgImage = context.createCGImage(pixelImage, from: extent) {
            image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        }

        if progress >= 1.0 {
            stopPlaying()
            displayLink.invalidate()
        }
    }

    func startHackerAnimation() {
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(Animation.hackerAnimationTimerFired(displayLink:))
        )

        originalSplashImage = image
        transitionStartTime = CACurrentMediaTime()

        displayLink.add(to: .main, forMode: RunLoop.Mode.default)

        isPlaying = true
    }

    @objc func hackerAnimationTimerFired(displayLink: CADisplayLink) {
        guard let extent = originalImageExtent else {
            print("originalImageExtent is nil")
            stopPlaying()
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
            stopPlaying()
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

        return pixelFilter.outputImage?.clampedToExtent()
    }

    private func applyExposureFilter(on image: CIImage, progress: Double) -> CIImage? {
        guard let exposureFilter = exposureFilter else {
            print ("exposureFilter is nil")
            return nil
        }

        exposureFilter.setValue((exposureIntensityScale * progress), forKey: kCIInputEVKey)
        exposureFilter.setValue(image, forKey: kCIInputImageKey)

        return exposureFilter.outputImage?.clampedToExtent()
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


        let output = stripeFilter.outputImage?.clampedToExtent()
        return output?.transformed(by: CGAffineTransform(rotationAngle: .pi / 2))
            .transformed(by: CGAffineTransform(translationX: CGFloat(stripeXPostion * 500), y: 0))
    }

    func applyLinearBumpFilter(on image: CIImage, progress: Double) -> CIImage? {
        guard let linearBumpFilter = linearBumpFilter else {
            print ("linearBumpFilter is nil")
            return nil
        }

        linearBumpFilter.setValue(image, forKey: kCIInputImageKey)
        linearBumpFilter.setValue(max(progress, 0.1) * stripeScaleBump + 1, forKey: kCIInputScaleKey)

        return linearBumpFilter.outputImage?.clampedToExtent()
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
        return self.coloredFilter(CIColor.white)?.outputImage?.clampedToExtent()
    }()

    private func applyBlendFilter(with inputImage: CIImage, backgroundImage: CIImage?, mask: CIImage?) -> CIImage? {
        let blendWithMaskFilter = CIFilter(name: "CIBlendWithMask")
        blendWithMaskFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        blendWithMaskFilter?.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
        blendWithMaskFilter?.setValue(mask, forKey: kCIInputMaskImageKey)

        return blendWithMaskFilter?.outputImage?.clampedToExtent()
    }

    private func coloredFilter(_ color: CIColor) -> CIFilter? {
        let filter = CIFilter(name: "CIConstantColorGenerator")
        filter?.setValue(color, forKey: kCIInputColorKey)
        return filter
    }

}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalCIContextOptionDictionary(_ input: [String: Any]?) -> [CIContextOption: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (CIContextOption(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCIContextOption(_ input: CIContextOption) -> String {
	return input.rawValue
}
