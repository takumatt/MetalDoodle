//
//  CGPoint+.swift
//  MetalDoodle
//
//  Created by Takuma Matsushita on 2021/03/20.
//

import UIKit

extension CGPoint {
  
  func euclideanDistance(to point: CGPoint) -> CGFloat {
    return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
  }
  
  func distance(to point: CGPoint) -> CGPoint {
    return .init(
      x: x - point.x,
      y: y - point.y
    )
  }
  
  func average(with point: CGPoint) -> CGPoint {
    return .init(
      x: (x + point.x) / 2,
      y: (y + point.y) / 2
    )
  }
}
