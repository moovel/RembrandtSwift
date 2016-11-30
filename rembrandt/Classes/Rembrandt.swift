/**
 * This file is part of Rembrandt
 * Copyright (c) 2016 PhotoEditorSDK.com
 * Licensed under MIT license (https://opensource.org/licenses/MIT)
 */

import Foundation

/// A `RembrandtResult` represents the result of an image comparison.
@objc open class RembrandtResult: NSObject {
    public internal(set) var pixelDifference: Int
    public internal(set) var percentageDifference: Double
    public internal(set) var passed: Bool
    public internal(set) var composition: UIImage?

    /// Initializes a new `RembrandtResult`.
    ///
    /// - Parameters:
    ///   - pixelDifference: The number of pixels that did not pass the test.
    ///   - percentageDifference: The percentage of pixels that did not pass the test.
    ///   - passed: True when all pixels passed the test, false otherwise.
    ///   - composition: An image the shows what pixels have passed the test.
    ///     If a pixel passes the test it will be colored green, red otherwise.
    init(pixelDifference: Int, percentageDifference: Double, passed: Bool, composition: UIImage?) {
        self.pixelDifference = pixelDifference
        self.percentageDifference = percentageDifference
        self.passed = passed
        self.composition = composition
    }
}

/// This class holds the options for the compare method.
@objc open class RembrandtCompareOptions: NSObject {
    public internal(set) var maxDelta: Double
    public internal(set) var maxDifference: Double
    public internal(set) var maxOffset: Int
    public internal(set) var renderComposition = false

    /// Initializes a new options object.
    ///
    /// - Parameters:
    ///   - maxDelta: The maximal delta a pixel may have, this is valid only if the surrounding of the pixel
    ///                is included. The delta then describes the distance in colorspace.
    ///   - maxDifference: The maximal difference a pixels surrounding may have.
    ///   - maxOffset:  The maximal offset in pixels that should be used. The delta determins if the pixels
    ///               sourrounding should be included in the comparison.
    init(maxDelta: Double, maxDifference: Double, maxOffset: Int) {
        self.maxDelta = maxDelta
        self.maxDifference = maxDifference
        self.maxOffset = maxOffset
    }
}

/// The main class that provides the compare function.
@objc(IMGLYRembrandt) open class Rembrandt : NSObject {
    private var options = RembrandtCompareOptions(maxDelta: 1, maxDifference: 0.01, maxOffset: 0)
    private var width = 0
    private var height = 0
    private var imageDataA: CFData?
    private var imageDataB: CFData?


    /// Compare two images A and B using the given options.
    ///
    /// - Parameters:
    ///   - imageA: An image.
    ///   - imageB: An image.
    ///   - options: Options that determin how the algorithm works.
    /// - Returns: A `RembrandtResult` instance.
    open func compare(imageA: UIImage, imageB: UIImage, options: RembrandtCompareOptions) -> RembrandtResult {
        self.options = options
        return compare(imageA: imageA, imageB: imageB)
    }

    /// Compare two images A and B using the default options.
    ///
    /// - Parameters:
    ///   - imageA: An image.
    ///   - imageB: An image.
    /// - Returns: A `RembrandtResult` instance.
    open func compare(imageA: UIImage, imageB: UIImage) -> RembrandtResult {
        width = Int(imageA.size.width)
        height = Int(imageA.size.height)
        self.imageDataA = getColorPointer(image: imageA)
        self.imageDataB = getColorPointer(image: imageB)
        var differences = 0

        // prepare composition
        let composition = UIImage(color: UIColor.red, size: imageA.size)
        let cgComposition = composition?.cgImage
        let imageRect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContext(imageA.size)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.draw(cgComposition!, in: imageRect)

        for x in 0...width {
            for y in 0...height {
                let passes = comparePixel(x: x, y: y)
                if !passes {
                    context?.setFillColor(red: 1, green: 0, blue: 0, alpha: 1)
                    differences += 1
                } else {
                    context?.setFillColor(red: 0, green: 1, blue: 0, alpha: 1)
                }
                context?.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        context?.restoreGState()
        let finalComposition = UIGraphicsGetImageFromCurrentImageContext()

        let pixelDifference = differences
        let totalPixels = width * height
        let percentageDifference = Double(pixelDifference) / Double(totalPixels)

        let passed = Double(pixelDifference) <= options.maxDifference
        return RembrandtResult(pixelDifference: pixelDifference, percentageDifference: percentageDifference, passed: passed, composition: finalComposition)
    }

    private func comparePixel(x: Int, y: Int) -> Bool {
        guard let imagePointerA = CFDataGetBytePtr(imageDataA), let imagePointerB = CFDataGetBytePtr(imageDataB) else {
            return false
        }
        let colorA = getColorFrom(pointer: imagePointerA, x: x, y: y)
        let colorB = getColorFrom(pointer: imagePointerB, x: x, y: y)

        let delta = calculateColorDelta(colorA: colorA, colorB: colorB)
        if delta < options.maxDelta {
            return true
        }
        // if we dont check the surrounding, we are done.
        if options.maxOffset == 0 {
            return false
        }
        let lowestX = max(0, x - options.maxOffset)
        let highestX = min(width - 1, x + options.maxOffset)
        let lowestY = max(0, y - options.maxOffset)
        let highestY = min(height - 1, y + options.maxOffset)

        var result = false
        for currentX in lowestX...highestX {
            for currentY in lowestY...highestY {
                if currentX == x || currentY == y {
                    continue
                }
                autoreleasepool {

                    let newColorA = getColorFrom(pointer: imagePointerA, x: currentX, y: currentY)
                    let newDeltaA = calculateColorDelta(colorA: colorA, colorB: newColorA)

                    let newColorB = getColorFrom(pointer: imagePointerB, x: currentX, y: currentY)
                    let newDeltaB = calculateColorDelta(colorA: colorA, colorB: newColorB)

                    if ((abs(newDeltaB - newDeltaA) < options.maxDelta) && (newDeltaA > options.maxDelta)) {
                        result = true
                    }
                }
            }
        }
        return result
    }

    private func calculateColorDelta (colorA: UIColor, colorB: UIColor) -> Double {
        var total = CGFloat(0)
        let componentsA = colorA.components
        let componentsB = colorB.components
        total += pow(componentsA.red - componentsB.red, 2)
        total += pow(componentsA.green - componentsB.green, 2)
        total += pow(componentsA.blue - componentsB.blue, 2)
        total += pow(componentsA.alpha - componentsB.alpha, 2)
        return sqrt(Double(total) * 255.0)
    }

    func getColorPointer(image: UIImage) -> CFData? {
        return image.cgImage!.dataProvider!.data
    }

    func getColorFrom(pointer: UnsafePointer<UInt8>, x: Int, y: Int) -> UIColor {
        let pos = CGPoint(x: x, y: y)

        let pixelInfo: Int = ((Int(width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(pointer[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(pointer[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(pointer[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(pointer[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIColor {
    var coreImageColor: CoreImage.CIColor {
        return CoreImage.CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let color = coreImageColor
        return (color.red, color.green, color.blue, color.alpha)
    }
}
