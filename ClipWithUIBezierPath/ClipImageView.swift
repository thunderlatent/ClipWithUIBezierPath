//
//  ClipImageView.swift
//  ClipWithUIBezierPath
//
//  Created by Jimmy on 2021/10/25.
//

import UIKit
import SwiftImage
class ClipImageView: UIImageView {
    
    ///路徑顏色
    var lineColor: UIColor = .link
    
    ///路徑寬度
    var lineWidth: CGFloat = 2
    
    ///路徑
    var path: UIBezierPath? = UIBezierPath()
    
    ///被切割的形狀
    var clipShape: CAShapeLayer? = CAShapeLayer()
    
    ///切割形狀的圖片
    var outputImage: UIImage?
    
    ///路徑所有座標
    var touchPoint: CGPoint?
    
    ///路徑開始的座標
    var startPoint: CGPoint?
    
    ///路徑最一開始的座標
    var beginPoint: CGPoint?
    
    ///所有畫過的路徑
    var allTouchPoints: [CGPoint] = []
    
    
    //MARK: - 開始繪製路徑
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //MARK: - 每畫一次新的路徑就清空原本的
        allTouchPoints.removeAll()
        
        beginPoint = touches.first?.location(in: self)
        guard let startPoint = touches.first?.location(in: self) else{ return}
        self.startPoint = startPoint
        allTouchPoints.append(startPoint)
        path?.move(to: startPoint)
    }
    
    //MARK: - 繪製路徑中
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touchPoint = touches.first?.location(in: self) else{return}
        self.touchPoint = touchPoint
        allTouchPoints.append(touchPoint)
        path?.addLine(to: touchPoint)
        draw()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let endPoint = touches.first?.location(in: self) else {return}
        guard let beginPoint = self.beginPoint else{return}
        let xDistance = endPoint.x - beginPoint.x
        
        //MARK: - 判斷每個X的位移是正的還負的
        let xUnit = xDistance / abs(xDistance)
        
        let yDistance = endPoint.y - beginPoint.y
        
        //MARK: - 每個X的Y移動
        let yUnit = yDistance / abs(yDistance)
        
        //MARK: - 每一pixel的x,y位移
        let oneUnit = (x: xUnit, y: yUnit)
        if Int(abs(xDistance)) > 0
        {
            //MARK: - 產生最後那條關閉路徑上的點
            for x in 1..<Int(abs(xDistance))
            {
                let newPoint = CGPoint(x: beginPoint.x + CGFloat(x) * oneUnit.x, y: beginPoint.y + CGFloat(x) * oneUnit.y)
                self.allTouchPoints.append(newPoint)
                
            }
        }
        
        path?.close()
        
        
        draw()
    }
    
    /// 繪畫Bezier曲線
    func draw() {
        clipShape?.path = path?.cgPath
        clipShape?.strokeColor = lineColor.cgColor
        clipShape?.lineWidth = lineWidth
        clipShape?.fillColor = UIColor.link.withAlphaComponent(0.3).cgColor
        if self.layer.sublayers?.count ?? 0 > 1
        {
            self.layer.sublayers?.removeLast(2)
        }
        self.layer.addSublayer(clipShape!)
        
        self.setNeedsDisplay()
    }
    
    
    /// 重置目前畫面
    func clearView() {
        self.path = UIBezierPath()
        self.layer.sublayers = nil
        self.clipShape = CAShapeLayer()
        self.setNeedsDisplay()
        self.layer.cornerRadius = 10
    }
    
    /// 刷新Layer，並加一個call back
    func setNeedsDisplay(completion:( () -> Void )? = nil) {
        DispatchQueue.main.async {
            
            self.setNeedsDisplay()
            if let completion = completion
            {
                completion()
            }
        }
    }
    
    
    
}
