//
//  UIImagee+AverageColor.swift
//  ClipWithUIBezierPath
//
//  Created by Jimmy on 2021/10/26.
//

import UIKit
extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
        
    }
}


extension UIImage {
    
    func imageByApplyingClippingBezierPath(_ path: UIBezierPath) -> UIImage {
        // Mask image using path
        let maskedImage = imageByApplyingMaskingBezierPath(path)
        
        // Crop image to frame of path
        let croppedImage = UIImage(cgImage: maskedImage.cgImage!.cropping(to: path.bounds)!)
        return croppedImage
    }
    
    func imageByApplyingMaskingBezierPath(_ path: UIBezierPath) -> UIImage {
        // Define graphic context (canvas) to paint on
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.addPath(path.cgPath)
        context.saveGState()
        
        // Set the clipping mask
        path.addClip()
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // Restore previous drawing context
        context.restoreGState()
        UIGraphicsEndImageContext()
        
        return maskedImage
    }
    
}


extension  UIImage  {
    ///UIImage轉換成CGImage
    func convertUIImageToCGImage(uiImage: UIImage) -> CGImage?
    {
        let cgImage = uiImage.cgImage
        if let cgImage = cgImage
        {
            return cgImage
        }else
        {
            guard let ciImage = uiImage.ciImage else{return nil}
            if let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)
            {
                return cgImage
            }else
            {
                return nil
            }
            
            
        }
    }
    
    //返回一个将白色背景变透明的UIImage
    func imageByRemoveWhiteBg() ->  UIImage? {
        let  colorMasking: [ CGFloat ] = [222, 255, 222, 255, 222, 255]
        return  transparentColor(colorMasking: colorMasking)
    }
    
    //返回一个将黑色背景变透明的UIImage
    func imageByRemoveBlackBg() ->  UIImage? {
        let  colorMasking: [ CGFloat ] = [0, 32, 0, 32, 0, 32]
        return  transparentColor(colorMasking: colorMasking)
    }
    
    func transparentColor(colorMasking:[ CGFloat ]) ->  UIImage? {
        if let rawImageRef =  self.convertUIImageToCGImage(uiImage: self) {
            UIGraphicsBeginImageContext ( self.size)
            if let maskedImageRef = rawImageRef.copy(maskingColorComponents: colorMasking) {
                let  context:  CGContext  =  UIGraphicsGetCurrentContext()!
                context.translateBy(x: 0.0, y: self.size.height)
                context.scaleBy(x: 1.0, y: -1.0)
                context.draw(maskedImageRef, in :  CGRect (x:0, y:0, width: self.size.width,                                             height: self .size.height))
                let  result =  UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return result
            }
        }
        return  nil
    }
    
    
    func changeColorByTransparent(cMask: [CGFloat] = [222, 255, 222, 255, 222, 255]) -> UIImage? {
        
        var returnImage: UIImage?
        
        let capImage = self
        
        
        let sz = capImage.size
        
        UIGraphicsBeginImageContextWithOptions(sz, true, 0.0)
        capImage.draw(in: CGRect(origin: CGPoint.zero, size: sz))
        let noAlphaImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let noAlphaCGRef = noAlphaImage?.cgImage
        
        if let imgRefCopy = noAlphaCGRef?.copy(maskingColorComponents: cMask) {
            
            returnImage = UIImage(cgImage: imgRefCopy)
            
        }
        
        
        
        return returnImage
        
    }
    
    func saveImageWithAlpha() -> UIImage{

        // odd but works... solution to image not saving with proper alpha channel
        let theImage = self
        UIGraphicsBeginImageContext(theImage.size)
        theImage.draw(at: CGPoint.zero)
        let saveImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let img = saveImage
//           , let data = UIImagePNGRepresentation(img)
        {

//            try? data.write(to: destFile)
          
            
            return img
        }
return UIImage()
    }

    
    
}

extension UIView
{
    func convertViewToImage(_ useViewDrawing: Bool = false) -> UIImage? {
            var rect = self.frame
            if self.isKind(of: UIScrollView.self) {
                rect.size = (self as! UIScrollView).contentSize
            }
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
            guard let context = UIGraphicsGetCurrentContext() else {return nil}
            context.saveGState()
            context.translateBy(x: self.center.x, y: self.center.y)
            context.concatenate(self.transform)
            context.translateBy(x: -self.bounds.size.width * self.layer.anchorPoint.x, y: -self.bounds.size.height * self.layer.anchorPoint.y)
            if useViewDrawing && self.responds(to: #selector(UIView.drawHierarchy(in:afterScreenUpdates:))) {
        
                // afterScreenUpdates true:包含最近的屏幕更新内容 false:不包含刚加入视图层次但未显示的内容
                self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            } else {
                self.layer.render(in: context)
            }
            context.restoreGState()
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
}
