//
//  Animation.swift
//  hackertracker
//
//  Created by Benjamin Humphries on 7/13/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class Animation {

    let pixelScaleFactor = 80.0
    let startingPixelScale = 1.0
    let pixelBarHeight: CGFloat = 300.0
    let pixelBarAngle: CGFloat = 3.0 * CGFloat.pi / 2.0
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
        guard let extent = originalImageExtent,
            let blackImage = blackImage else {
            image = originalSplashImage
            displayLink.invalidate()
            return
        }

        let progress = min((CACurrentMediaTime() - transitionStartTime) / duration, 1.0)

        // 1. Calculate pixel effect.
        if let pixelImage = applyPixelFilter(progress: progress),
            // 2. Create a black and white copy machine filter that will be used
            // as a mask for the pixel effect.
            let copyMachineImage = applyCopyMachineFilter(progress: min(progress, 0.5),
                                                          startingImage: blackImage,
                                                          endingImage: whiteImage!,
                                                          extent: extent),
            // 3. Mask the pixel effect so that only a bar of pixels is shown
            let blendFilter = createBlendFilter(with: pixelImage,
                                                backgroundImage: originalInputCIImage,
                                                mask: copyMachineImage),
            // 4. Get the output of the blended images.
            let outputImage = blendFilter.outputImage?.clampingToExtent(),
            // 5. Convert the final ciImage to cgImage to fix size issues...
            let cgImage = context.createCGImage(outputImage, from: extent) {

            // Done! Update the new UIImage! whew!
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

    private func applyCopyMachineFilter(progress: Double, startingImage: CIImage, endingImage: CIImage, extent: CGRect, inverted: Bool = false) -> CIImage? {
        guard let copyMachineFilter = copyMachineFilter else {
            print ("copyMachineFilter is nil")
            return nil
        }

        let extentVector = CIVector(x: extent.origin.x,
                                    y: extent.origin.y,
                                    z: extent.size.width,
                                    w: extent.size.height)

        copyMachineFilter.setValue(extentVector, forKey: kCIInputExtentKey)
        copyMachineFilter.setValue(startingImage, forKey: kCIInputImageKey)
        copyMachineFilter.setValue(endingImage, forKey: kCIInputTargetImageKey)
        copyMachineFilter.setValue(progress, forKey: kCIInputTimeKey)

        if inverted {
            copyMachineFilter.setValue(pixelBarAngle + CGFloat.pi, forKey: kCIInputAngleKey)
            copyMachineFilter.setValue(0.0, forKey: kCIInputWidthKey)
        } else {
            copyMachineFilter.setValue(pixelBarAngle, forKey: kCIInputAngleKey)
            copyMachineFilter.setValue(pixelBarHeight, forKey: kCIInputWidthKey)
        }

        return copyMachineFilter.outputImage?.clampingToExtent()
    }

    lazy var pixelFilter: CIFilter? = {
        let pixelTransitionFilter = CIFilter(name: "CIPixellate")
        pixelTransitionFilter?.setValue(self.coreImage, forKey: kCIInputImageKey)

        return pixelTransitionFilter
    }()

    lazy var copyMachineFilter: CIFilter? = {
        let copyMachineFilter = CIFilter(name: "CICopyMachineTransition")
        copyMachineFilter?.setDefaults()
        return copyMachineFilter
    }()

    lazy var blackImage: CIImage? = {
        return self.coloredFilter(CIColor.black())?.outputImage?.clampingToExtent()
    }()

    lazy var whiteImage: CIImage? = {
        return self.coloredFilter(CIColor.white())?.outputImage?.clampingToExtent()
    }()

    lazy var originalImageExtent: CGRect? = {
        return CIImage(image: self.image)?.extent
    }()

    private func createBlendFilter(with inputImage: CIImage, backgroundImage: CIImage, mask: CIImage) -> CIFilter? {
        let blendWithMaskFilter = CIFilter(name: "CIBlendWithMask")
        blendWithMaskFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        blendWithMaskFilter?.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
        blendWithMaskFilter?.setValue(mask, forKey: kCIInputMaskImageKey)

        return blendWithMaskFilter
    }

    private func coloredFilter(_ color: CIColor) -> CIFilter? {
        let filter = CIFilter(name: "CIConstantColorGenerator")
        filter?.setValue(color, forKey: kCIInputColorKey)
        return filter
    }


}

