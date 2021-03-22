//
//  WeightedPoint.swift
//  MetalDoodle
//
//  Created by Takuma Matsushita on 2021/03/21.
//

import CoreGraphics

/// This wraps UIKit's y-down coordinate system CGPoint
/// and provides standard y-up value in Cartesian coordinate-system.
struct YUpCGPoint {
  
  // NOTE: これ使えばもっとわかりやすい計算にできるかも
  
  let cgPoint: CGPoint
  let point: CGPoint
  
  init(cgPoint: CGPoint, viewHeight: CGFloat) {
    self.cgPoint = cgPoint
    self.point = .init(x: cgPoint.x, y: cgPoint.y)
  }
}

struct WeightedPoint {
  
  static let baseWeight: CGFloat = 5.0
//  static let minWeight: CGFloat = 1.0
//  static let maxWeight: CGFloat = 5.0

  static let maxLength: CGFloat = 50.0
  
  let origin: CGPoint
  let a: CGPoint
  let b: CGPoint
  let weight: CGFloat
  
  init(
    current  p: CGPoint,
    previous q: CGPoint
  ) {
    
    let relative = p.distance(to: q)
    let length = p.euclideanDistance(to: q)
    
    weight: do {
      let lengthForWeight = length > Self.maxLength ? Self.maxLength : length
      self.weight = Self.baseWeight - lengthForWeight * 0.1
    }
    
    weightedPoint: do {
      var relative_b: CGPoint = .init(x:  relative.y,  y: -relative.x)
      var relative_a: CGPoint = .init(x: -relative.y,  y:  relative.x)
      
      relative_a = relative_a.mul(weight / 2).div(length)
      relative_b = relative_b.mul(weight / 2).div(length)
      
      self.origin = p
      self.a = origin.add(relative_a)
      self.b = origin.add(relative_b)
    }
  }
}
