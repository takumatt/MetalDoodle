//
//  CGPoint+.swift
//  MetalDoodle
//
//  Created by Takuma Matsushita on 2021/03/20.
//

import UIKit

extension CGPoint {
  
  func add(_ point: CGPoint) -> CGPoint {
    .init(
      x: x + point.x,
      y: y + point.y
    )
  }
  
  func sub(_ point: CGPoint) -> CGPoint {
    .init(
      x: x - point.x,
      y: y - point.y
    )
  }
  
  func mul(_ value: CGFloat) -> CGPoint {
    .init(
      x: x * value,
      y: y * value
    )
  }
  
  func div(_ value: CGFloat) -> CGPoint {
    .init(
      x: x / value,
      y: y / value
    )
  }
  
  func euclideanDistance(to point: CGPoint) -> CGFloat {
    return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
  }
  
  func distance(to point: CGPoint) -> CGPoint {
    return .init(
      x: point.x - x,
      y: point.y - y
    )
  }
  
  func average(with point: CGPoint) -> CGPoint {
    return .init(
      x: (x + point.x) / 2,
      y: (y + point.y) / 2
    )
  }
}

extension Math.Linear {
  static func equation(
    through p: CGPoint,
    and     q: CGPoint
  ) ->  (a: CGFloat, b: CGFloat) {
    Self.equation(through: (x: p.x, y: p.y), and: (x: q.x, y: q.y))
  }
  
  static func slope(
    through p: CGPoint,
    and     q: CGPoint
  ) -> CGFloat {
    Self.slope(through: (x: p.x, y: p.y), and: (x: q.x, y: q.y))
  }
}
