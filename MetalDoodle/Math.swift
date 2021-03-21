//
//  Math.swift
//  MetalDoodle
//
//  Created by Takuma Matsushita on 2021/03/20.
//

import CoreGraphics

enum Math {
  
  enum Linear {
  
    static func equation(
      through p: (x: CGFloat, y: CGFloat),
      and     q: (x: CGFloat, y: CGFloat)
    ) -> (a: CGFloat, b: CGFloat) {
      
      guard (q.x - p.x) != .zero else {
        return (
          a: .zero,
          b: .zero
        )
      }
      
      return (
        a: (q.y - p.y) / (q.x - p.x),
        b: (q.x * p.y - p.x * q.y) / (q.x - p.x)
      )
    }
    
    static func orthogonalEquation(
      to f: (a: CGFloat, b: CGFloat)
    ) -> (a: CGFloat, b: CGFloat){
      
      guard f.a != .zero else {
        return (
          a: .zero,
          b: f.b
        )
      }
      
      return (
        a: CGFloat(-1) / f.a,
        b: f.b
      )
    }
    
    static func slope (
      through p: (x: CGFloat, y: CGFloat),
      and     q: (x: CGFloat, y: CGFloat)
    ) -> CGFloat {
      atan((q.y - p.y) / (q.x - p.x))
    }
    
    static func slope(
      of f: (a: CGFloat, b: CGFloat)
    ) -> CGFloat {
      return f.a
    }
    
    static func trigonometricRatio(
      from slope: CGFloat
    ) -> CGFloat {
      tan(slope)
    }
  }
}
