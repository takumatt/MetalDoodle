//
//  DoodleViewController.swift
//  MetalDoodle
//
//  Created by Takuma Matsushita on 2021/03/05.
//

import UIKit
import SwiftUI

struct DoodleView: UIViewRepresentable {
  
  private let bodyView = DoodleBodyView()
  
  init() {
  
  }
  
  func makeUIView(context: Context) -> some UIView {
    return bodyView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    
  }
  
  func clear() {
    bodyView.clear()
  }
}

class DoodleBodyView: UIView {
  
  private let bezierPathLayer: CAShapeLayer = {
    
    let layer = CAShapeLayer()
    layer.backgroundColor = UIColor.blue.cgColor
    
    return layer
  }()
  
  private let weightProvider: SimpleWeightProvider = .init()
  
  private var path: UIBezierPath = .init()
  private var previousPoint: WeightedPoint = .zero
  
  private var drawingPath: UIBezierPath? = nil
  
  init() {
    super.init(frame: .zero)
    
    layer.addSublayer(bezierPathLayer)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func clear() {
    path.removeAllPoints()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    bezierPathLayer.frame = frame
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("began", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
//    path.move(to: point)
    
    previousPoint = .init(current: point, previous: previousPoint.origin, weightProvider: weightProvider)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("moved", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
    let weightedPoint = WeightedPoint(current: point, previous: previousPoint.origin, weightProvider: weightProvider)
    
    // addDebugRect(weightedPoint: weightedPoint)
        
    path.move(to: previousPoint.a)
    path.addLine(to: previousPoint.b)
    path.addLine(to: weightedPoint.b)
    path.addLine(to: weightedPoint.a)
    path.addLine(to: previousPoint.a)
    
    previousPoint = weightedPoint
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("end", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
    bezierPathLayer.path = path.cgPath
  }
  
  private func addDebugRect(weightedPoint: WeightedPoint) {
    
    let rect = UIBezierPath(rect: .init(x: weightedPoint.origin.x - 1, y: weightedPoint.origin.y - 1, width: 2, height: 2))
    UIColor.red.setFill()
    rect.fill()
    path.append(rect)
    
    let rectA = UIBezierPath(rect: .init(x: weightedPoint.a.x - 1, y: weightedPoint.a.y - 1, width: 2, height: 2))
    UIColor.green.setFill()
    rect.fill()
    path.append(rectA)
    
    let rectB = UIBezierPath(rect: .init(x: weightedPoint.b.x - 1, y: weightedPoint.b.y - 1, width: 2, height: 2))
    UIColor.blue.setFill()
    rect.fill()
    path.append(rectB)
  }
}

class PointBuffer {
  
  private var points: [WeightedPoint]
  private let bufferSize: Int
  
  private let flushWhenFull: Bool
  
  private let _flush: ([WeightedPoint]) -> Void
  
  var isFull: Bool {
    return points.count >= bufferSize
  }
  
  init(
    points: [WeightedPoint] = [],
    bufferSize: Int = 4,
    flushWhenFull: Bool = true,
    flush: @escaping ([WeightedPoint]) -> Void
  ) {
    self.points = points
    self.bufferSize = bufferSize
    self.flushWhenFull = flushWhenFull
    self._flush = flush
  }
  
  func addPoint(_ point: WeightedPoint) {
    
    points.append(point)
    
    if flushWhenFull,
      points.count >= bufferSize {
      flush()
    }
  }
  
  func peek() -> [WeightedPoint] {
    return points
  }
  
  func flush() {
    self._flush(points)
    points = []
  }
}


// protocolにするかも、bufferも参照するかも
enum BezierPathGenerator {
  
  private static func generateLine(
    a: WeightedPoint,
    b: WeightedPoint
  ) -> UIBezierPath {
    
    let path: UIBezierPath = .init()
    
    path.move(to: a.a)
    path.addLine(to: a.b)
    path.addLine(to: b.b)
    path.addLine(to: b.a)
    path.addLine(to: a.a)
    
    return path
  }
  
  private static func generateQuadCurve(
    a: WeightedPoint,
    b: WeightedPoint,
    c: WeightedPoint
  ) -> UIBezierPath {
    
    let path: UIBezierPath = .init()
    
    path.move(to: a.a)
    path.addLine(to: a.b)
    path.addQuadCurve(to: c.b, controlPoint: b.b)
    path.addLine(to: c.a)
    path.addQuadCurve(to: a.a, controlPoint: b.a)
    
    return path
  }
  
  private static func generateCurve(
    a: WeightedPoint,
    b: WeightedPoint,
    c: WeightedPoint,
    d: WeightedPoint
  ) -> UIBezierPath {
    
    let path: UIBezierPath = .init()
    
    path.move(to: a.a)
    path.addLine(to: a.b)
    path.addCurve(to: d.b, controlPoint1: b.b, controlPoint2: c.b)
    path.addLine(to: d.a)
    path.addCurve(to: a.a, controlPoint1: c.a, controlPoint2: b.a)
    
    return path
  }
  
  private static func interpolation(weightedPoint: [WeightedPoint]) -> [WeightedPoint] {
    assertionFailure()
    return []
  }
  
  static func generate(weightedPoint: [WeightedPoint]) -> UIBezierPath {
    
    precondition(weightedPoint.count > 1)
    
    switch weightedPoint.count {
    case 2:
      return Self.generateLine(
        a: weightedPoint[0],
        b: weightedPoint[1]
      )
    case 3:
      return Self.generateQuadCurve(
        a: weightedPoint[0],
        b: weightedPoint[1],
        c: weightedPoint[2]
      )
    case 4:
      return Self.generateCurve(
        a: weightedPoint[0],
        b: weightedPoint[1],
        c: weightedPoint[2],
        d: weightedPoint[3]
      )
    case 5...Int.max:
      let interpolatedPoints = Self.interpolation(weightedPoint: weightedPoint)
      return Self.generateCurve(
        a: interpolatedPoints[0],
        b: interpolatedPoints[1],
        c: interpolatedPoints[2],
        d: interpolatedPoints[3]
      )
    default:
      assertionFailure()
      return .init()
    }
  }
}
