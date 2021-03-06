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
    self.point = .init(x: cgPoint.x, y: -cgPoint.y)
  }
}

protocol WeightProvider {
  
  var baseWeight: CGFloat { get }
  var minLength: CGFloat { get }
  var maxLength: CGFloat { get }
  
  func weight(distance: CGFloat) -> CGFloat
}

extension WeightProvider {
  
  func weight(distance: CGFloat) -> CGFloat {
    
    let x = (distance - (maxLength - minLength) / 2) / (maxLength - minLength)
    
    let gain: CGFloat = 0.5
    let amp = 2 / (atan(gain * x / 2) + 1)
    let weight = baseWeight * amp
    
    return weight
  }
}

class SimpleWeightProvider: WeightProvider {
  
  var baseWeight: CGFloat
  var minLength: CGFloat
  var maxLength: CGFloat
  
  init(
    baseWeight: CGFloat = 3,
    minLength: CGFloat = 5,
    maxLength: CGFloat = 70
  ) {
    self.baseWeight = baseWeight
    self.minLength = minLength
    self.maxLength = maxLength
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
  
//  init(
//    current  p: CGPoint,
//    previous q: CGPoint,
//    weightProvider: WeightProvider
//  ) {
//
//    _id += 1
//    self.id = _id
//
//    guard q != .zero else {
//      // FIXME: temporary
//      self.weight = .zero
//      self.origin = p
//      self.a = p
//      self.b = p
//      return
//    }
//
//    let relative = p.distance(to: q)
//    let length = p.euclideanDistance(to: q)
//
//    self.weight = weightProvider.weight(distance: length)
//
//    var relative_b: CGPoint = .init(x:  relative.y,  y: -relative.x)
//    var relative_a: CGPoint = .init(x: -relative.y,  y:  relative.x)
//
//    // XXX: weight is refered, but not respected
//    relative_a = relative_a.mul(weight / 3).div(length)
//    relative_b = relative_b.mul(weight / 3).div(length)
//
//    self.origin = p
//    self.a = origin.add(relative_a)
//    self.b = origin.add(relative_b)
//  }
  
  // 没
      init(
        current  p: CGPoint,
        previous q: CGPoint,
        weightProvider: WeightProvider
      ) {
  
        _id += 1
        self.id = _id
  
        guard q != .zero else {
          // FIXME: temporary
          self.weight = .zero
          self.origin = p
          self.a = p
          self.b = p
          return
        }
        
        let length = q.euclideanDistance(to: p)
        let radian = Math.Linear.slope(through: p, and: q)
        let radian_orthogonal = CGFloat.pi / 2 - radian
        self.weight = weightProvider.weight(distance: length)
  
        let hypotenuse = weight / 2
        let relativeX = hypotenuse * cos(radian_orthogonal)
        let relativeY = hypotenuse * sin(radian_orthogonal)
        
        var relative_a: CGPoint = .init(x: -relativeX, y:  relativeY)
        var relative_b: CGPoint = .init(x:  relativeX, y: -relativeY)
        
        TODO: do {
          
          let shouldSwap: Bool
          if p.distance(to: q).x < 0 {
            shouldSwap = true
          } else {
            shouldSwap = false
          }
          
          if shouldSwap {
            let tmp = relative_a
            relative_a = relative_b
            relative_b = tmp
          }
        }
        
        self.origin = p
        self.a = origin.add(relative_a)
        self.b = origin.add(relative_b)
      }
  
  init(
    origin: CGPoint,
    a: CGPoint,
    b: CGPoint,
    weight: CGFloat
  ) {
    self.origin = origin
    self.a = a
    self.b = b
    self.weight = weight
    
    _id += 1
    id = _id
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

extension WeightedPoint {
  
  func average(with p: WeightedPoint, and q: WeightedPoint) -> Self {
    
    let _origin = self.origin.average(with: p.origin).average(with: q.origin)
    let _a = self.a.average(with: p.a).average(with: q.a)
    let _b = self.b.average(with: p.b).average(with: q.b)
    let _weight = (weight + p.weight + q.weight) / 3
    
    return .init(
      origin: _origin,
      a: _a,
      b: _b,
      weight: _weight
    )

  }
  
  func average(with p: WeightedPoint) -> Self {
    
    let _origin = self.origin.average(with: p.origin)
    let _a = self.a.average(with: p.a)
    let _b = self.b.average(with: p.b)
    let _weight = (weight + p.weight) / 2
    return .init(
      origin: _origin,
      a: _a,
      b: _b,
      weight: _weight
    )

  }
}
