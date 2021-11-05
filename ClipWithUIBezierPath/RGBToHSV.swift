//
//  RGBToHSV.swift
//  ClipWithUIBezierPath
//
//  Created by Jimmy on 2021/11/3.
//

import UIKit
extension UIViewController
{
    
    func rgbToHsv(red:CGFloat, green:CGFloat, blue:CGFloat) -> (h:CGFloat, s:CGFloat, v:CGFloat){
            let r:CGFloat = red/255
            let g:CGFloat = green/255
            let b:CGFloat = blue/255
//            print("r = \(r), g = \(g), b = \(b)")
            
            let Max:CGFloat = max(r, g, b)
            let Min:CGFloat = min(r, g, b)
     
            //h 0-360
            var h:CGFloat = 0
            if Max == Min {
                h = 0.0
            }else if Max == r && g >= b {
                h = 60 * (g-b)/(Max-Min)
            } else if Max == r && g < b {
                h = 60 * (g-b)/(Max-Min) + 360
            } else if Max == g {
                h = 60 * (b-r)/(Max-Min) + 120
            } else if Max == b {
                h = 60 * (r-g)/(Max-Min) + 240
            }
//            print("h = \(h)")
            
            //s 0-1
            var s:CGFloat = 0
            if Max == 0 {
                s = 0
            } else {
                s = (Max - Min)/Max
            }
//            print("s = \(s)")
            
            //v
            let v:CGFloat = Max
//            print("v = \(v)")
            
            return (h, s, v)
        }
    
    func rgbToHsl(red:CGFloat, green:CGFloat, blue:CGFloat) -> (h:CGFloat, s:CGFloat, l:CGFloat){
        let r:CGFloat = red/255
        let g:CGFloat = green/255
        let b:CGFloat = blue/255
//        print("r = \(r), g = \(g), b = \(b)")
        
        let Max:CGFloat = max(r, g, b)
        let Min:CGFloat = min(r, g, b)
 
        //h 0-360
        var h:CGFloat = 0
        if Max == Min {
            h = 0.0
        }else if Max == r && g >= b {
            h = 60 * (g-b)/(Max-Min)
        } else if Max == r && g < b {
            h = 60 * (g-b)/(Max-Min) + 360
        } else if Max == g {
            h = 60 * (b-r)/(Max-Min) + 120
        } else if Max == b {
            h = 60 * (r-g)/(Max-Min) + 240
        }
        print("h = \(h)")
        
        //l 0-1
        let l:CGFloat = (r + g + b) / 3
        print("l = \(l)")
        
        //s 0-1
        var s:CGFloat = 0
        if l == 0 || Max == Min {
            s = 0
        } else if l > 0 && l <= 0.5 {
            s = (Max - Min)/(2*l)
        } else if l > 0.5 {
            s = (Max - Min)/(2 - 2*l)
        }
        print("s = \(s)")
            
        return (h, s, l)
    }
}
