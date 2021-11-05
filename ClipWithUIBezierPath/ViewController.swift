//
//  ViewController.swift
//  ClipWithUIBezierPath
//
//  Created by Jimmy on 2021/10/25.
//

import UIKit
import SwiftImage
class ViewController: UIViewController {
    
    @IBOutlet weak var rawImageView: ClipImageView!
    
    @IBOutlet weak var clipImageView: ClipImageView!
    
    @IBOutlet weak var resetButton: UIButton!
    
    ///手機的解析度，例如1x,2x,3x
    let nativeScale = Int(UIScreen.main.nativeScale)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func resetButtonAction(_ sender: UIButton) {
        resetPath()
    }
    
    @IBAction func showClipButtonAction(_ sender: UIButton) {
        showClipImage()
    }
    
    
    
    /// 重置目前狀態
    func resetPath()
    {
        self.rawImageView.clearView()
        self.clipImageView.layer.sublayers?.removeAll()
        self.clipImageView.layer.mask = nil
        self.clipImageView.image = nil
        self.clipImageView.setNeedsDisplay()
    }
    
    
    /// 顯示目前裁切的區域
    func showClipImage()
    {
        
        //MARK: - 取得原始圖片內的路徑
        guard let path = self.rawImageView.path else{return}
        
        //MARK: - 複製圈選的圖型
        guard let clipShape = try? self.rawImageView.clipShape?.copyObject() as? CAShapeLayer else {return}
        clipShape.fillColor = UIColor.link.withAlphaComponent(1).cgColor
        let renderer = UIGraphicsImageRenderer(bounds: self.rawImageView.bounds)
        let rawImageViewToImage = renderer.image { ctx in
            let newImageView = UIImageView(frame: self.rawImageView.frame)
            newImageView.backgroundColor = .lightGray
            newImageView.contentMode = .scaleAspectFit
            newImageView.image = self.rawImageView.image
            
            newImageView.drawHierarchy(in: newImageView.bounds, afterScreenUpdates: true)
        }
        
//        self.clipImageView.image = UIImage(named: "testImage")
//        self.clipImageView.contentScaleFactor = 3.0
//        self.clipImageView.layer.mask = clipShape
//        self.clipImageView.layer.masksToBounds = true
//        self.clipImageView.clipsToBounds = true
        self.clipImageView.setNeedsDisplay {
            
             let pathBoundBox = path.cgPath.boundingBox
         
            
            //MARK: - 切割整塊UIImageView並轉成新圖片
            
            let renderer = UIGraphicsImageRenderer(bounds: pathBoundBox)
            let cropImage = renderer.image { ctx in
                self.rawImageView.drawHierarchy(in: self.rawImageView.bounds, afterScreenUpdates: true)
            }
            self.clipImageView.image = cropImage
            self.clipImageView.layer.mask?.removeFromSuperlayer()
            UIImageWriteToSavedPhotosAlbum(cropImage, nil, nil, nil)
            self.sfImageHandle(image: rawImageViewToImage, path: path)
            
        }
        
        
        
    }
    
    
    /// 處理照片的每個像素
    /// - Parameters:
    ///   - image: 要處理的照片
    ///   - path: 處理這個路徑內的像素
    func sfImageHandle(image: UIImage, path: UIBezierPath)
    {
        let sfImage = Image<RGBA<UInt8>>(uiImage: image)
        
        let allTouchPoints = self.rawImageView.allTouchPoints
        
        //MARK: - 要處理的每個像素
        var pixelPoints:[CGPoint] = []
        
        //MARK: - 把所有觸摸過的點分離出x
        var xPoints: [CGFloat] = []
        for point in allTouchPoints
        {
            if xPoints.contains(point.x)
            {
                continue
            }else
            {
                xPoints.append(point.x)
            }
        }
        
        for x in xPoints
        {
            let xMatchPoints = allTouchPoints.filter{$0.x == x}
            if xMatchPoints.count == 1 {
                pixelPoints.append(xMatchPoints[0])
            }else if xMatchPoints.count == 2{
                let yPoints = xMatchPoints.map({Int($0.y)})
                guard let minY = yPoints.min(), let maxY = yPoints.max() else {continue}
                for y in minY...maxY
                {
                    
                    pixelPoints.append(CGPoint(x: Int(x), y: y))
                }
                
            }
        }
        var hueSum: CGFloat = 0
        var saturationSum: CGFloat = 0
        var valueSum: CGFloat = 0
        var accessPixelPoints = 0
        for pixelPoint in pixelPoints
        {
            /*MARK: - 設定指定的像素為特定顏色
//            sfImage[ Int(pixelPoint.x)  * nativeScale ,Int(pixelPoint.y) * nativeScale] = RGBA(0x000000FF)
 */
            if let pixel = sfImage.pixelAt(x: nativeScale * Int(pixelPoint.x), y: nativeScale * Int(pixelPoint.y)) {
              
                let hsv = rgbToHsv(red: CGFloat(pixel.red), green: CGFloat(pixel.green), blue: CGFloat(pixel.blue))
                
                hueSum += hsv.h
                saturationSum += hsv.s
                valueSum += hsv.v
                accessPixelPoints += 1
//                print("R = ",pixel.red)
//                print("G = ",pixel.green)
//                print("B = ",pixel.blue)
//                print("A = ",pixel.alpha)
//                print("色相(hue) ＝",hsv.h)
//                print("飽和度(saturation) = ",hsv.s)
//                print("明度(value) ＝",hsv.v)
            } else {
                print("Out of bounds")
            }
        }

//        print("PixelPoints = ", pixelPoints.count)
        let hueAverage = hueSum / CGFloat(accessPixelPoints)
        let saturationAverage = saturationSum / CGFloat(accessPixelPoints)
        let valueAverage = valueSum / CGFloat(pixelPoints.count)
        print("平均色相 ＝",hueAverage)
        print("平均飽和度 ＝",saturationAverage)
        print("平均明度 ＝",valueAverage)
        
    }
    
    
    
}


extension NSObject {
    //MARK: - 複製一份物件，可以在需要使用到相同UI時呼叫
    func copyObject<T:NSObject>() throws -> T? {
        let data = try NSKeyedArchiver.archivedData(withRootObject:self, requiringSecureCoding:false)
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
    }
}

