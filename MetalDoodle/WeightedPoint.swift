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

protocol WeightProvider {
  
  var base: CGFloat { get }
  var min: CGFloat { get }
  var max: CGFloat { get }
  
  func weight(distance: CGFloat) -> CGFloat
}

extension WeightProvider {
  
  func weight(distance: CGFloat) -> CGFloat {
    
    let gain: CGFloat = 3
    
    func sigmoid(x: CGFloat) -> CGFloat {
      (tanh(gain * x / 2) + 1) / 2
    }
    
    let mapped = (distance - max) / max
    let weight = base * sigmoid(x: -mapped)
    
    return weight
  }
}

class SimpleWeightProvider: WeightProvider {
  
  var base: CGFloat
  var min: CGFloat
  var max: CGFloat
  
  init(
    base: CGFloat = 10,
    min: CGFloat = 0,
    max: CGFloat = 50
  ) {
    self.base = base
    self.min = min
    self.max = max
  }
}

var _id = 0

struct WeightedPoint {
  
  static let zero: Self = .init()
  
  let origin: CGPoint
  let a: CGPoint
  let b: CGPoint
  let weight: CGFloat
  let id: Int
  
  init(
    current  p: CGPoint,
    previous q: CGPoint,
    weightProvider: WeightProvider
  ) {
    
    _id += 1
    self.id = _id
    
    let relative = p.distance(to: q)
    let length = p.euclideanDistance(to: q)
    
    self.weight = weightProvider.weight(distance: length)
    
    var relative_b: CGPoint = .init(x:  relative.y,  y: -relative.x)
    var relative_a: CGPoint = .init(x: -relative.y,  y:  relative.x)
    
    relative_a = relative_a.mul(weight / 2).div(length)
    relative_b = relative_b.mul(weight / 2).div(length)
    
    self.origin = p
    self.a = origin.add(relative_a)
    self.b = origin.add(relative_b)
  }
  
  private init() {
    self.origin = .zero
    self.a = .zero
    self.b = .zero
    self.weight = .zero
    
    _id += 1
    self.id = _id
  }
}
