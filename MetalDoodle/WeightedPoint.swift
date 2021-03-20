//
//  WeightedPoint.swift
//  MetalDoodle
//
//  Created by Takuma Matsushita on 2021/03/21.
//

import CoreGraphics

struct WeightedPoint {
  
  //static let zero: Self = .zero
  
  static let maxWeight: CGFloat = 5.0
  
  let origin: CGPoint
  let a: CGPoint
  let b: CGPoint
  
  let weight: CGFloat
  
  init(
    current  p: CGPoint,
    previous q: CGPoint,
    weight: CGFloat = 3 // tmp
  ) {
    
    let slope = Math.Linear.slope(through: p, and: q)
    let inverted = -slope
    let x = weight * sin(inverted)
    let y = weight * cos(inverted)
    
    let qa_x = p.x - x
    let qa_y = p.y - y
    let qb_x = p.x + x
    let qb_y = p.y - y
    
    self.origin = p
    self.a = .init(x: qa_x, y: qa_y)
    self.b = .init(x: qb_x, y: qb_y)
    self.weight = weight
  }
}
