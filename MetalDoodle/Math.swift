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
  
  enum NonLinear {
    
    static func splineInterpolation() {
      
      let points: [CGPoint] = [.init(x: 1, y: 1), .init(x: 3, y: 3)]
      
      prepare: do {
        
        // the number of variables for the equation
        let N = points.count - 1
        
        var matrix: [[CGFloat]] = Array(
          repeating: Array(
            repeating: .zero,
            count: 4 * N
          ),
          count: 4 * N
        )
        
        var Y: [CGFloat] = Array(repeating: .zero, count: 4 * N)
        
        var equation = 0
        
        for i in 0 ..< N {
          for j in 0 ..< 4 {
            matrix[equation][4 * i + j] = pow(points[i].x, CGFloat(j))
          }
          Y[equation] = points[i].y
          equation += 1
        }
        
        for i in 0 ..< N {
          for j in 0 ..< 4 {
            matrix[equation][4 * i + j] = pow(points[i + 1].x, CGFloat(j))
          }
          Y[equation] = points[i + 1].y
          equation += 1
        }
        
        for i in 0 ..< (N - 1) {
          for j in 0 ..< 4 {
            matrix[equation][4 * i + j] = CGFloat(j) * pow(points[i + 1].x, CGFloat(j - 1))
            matrix[equation][4 * (i + 1) + j] = -CGFloat(j) * pow(points[i + 1].x, CGFloat(j - 1))
          }
          equation += 1
        }
        
        for i in 0 ..< (N - 1) {
          matrix[equation][4 * i + 3] = 3 * points[i + 1].x
          matrix[equation][4 * i + 2] = 1
          matrix[equation][4 * (i + 1) + 3] = -3 * points[i + 1].x
          matrix[equation][4 * (i + 1) + 2] = -1
          equation += 1
        }
        
        matrix[equation][3] = 3 * points[0].x
        matrix[equation][2] = 1
        equation += 1
        matrix[4 * N - 1][4 * N - 1] = 3 * points[N].x
        matrix[4 * N - 1][4 * N - 2] = 1
        
        // TODO: get inverted matrix of the matrix
      }
    }
  }
}
