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
    return layer
  }()
  
  private let weightProvider: SimpleWeightProvider = .init()
  
  private var pointBuffer: PointBuffer!
  
  private var path: UIBezierPath = .init()
  
  private var previousPoint: WeightedPoint = .zero
  private var previousBuffer: [WeightedPoint]? = nil
  
  private var drawingPath: UIBezierPath? = nil
  
  init() {
    
    super.init(frame: .zero)
    
    self.pointBuffer = .init(
      points: [],
      bufferSize: 4,
      flushWhenFull: true,
      flush: { [weak self] buffer in
        
        guard let self = self else { return }
        
        finalize: do {
          let generatedPath = BezierPathGenerator.generate(weightedPoint: buffer)
          self.path.append(generatedPath)
        }
      },
      completion: { [weak self] buffer in
        guard let self = self else { return }
        self.pointBuffer.addPoint(buffer[3])
      }
    )
    
    layer.addSublayer(bezierPathLayer)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func clear() {
    path.removeAllPoints()
    bezierPathLayer.path = path.cgPath
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    bezierPathLayer.frame = frame
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("began", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
    let weightedPoint: WeightedPoint = .init(current: point, previous: previousPoint.origin, weightProvider: weightProvider)
    
    pointBuffer.addPoint(weightedPoint)
    
    previousPoint = weightedPoint
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("moved", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
    let weightedPoint = WeightedPoint(current: point, previous: previousPoint.origin, weightProvider: weightProvider)
    
    // addDebugRect(weightedPoint: weightedPoint)
    
    pointBuffer.addPoint(weightedPoint)
    
    previousPoint = weightedPoint
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("end", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
    bezierPathLayer.path = path.cgPath
    
    pointBuffer.clear()
    
    previousPoint = .zero
    previousBuffer = nil
  }
  
  private func addDebugRect(weightedPoint: WeightedPoint) {
    
    let rect = UIBezierPath(rect: .init(x: weightedPoint.origin.x - 1, y: weightedPoint.origin.y - 1, width: 2, height: 2))
    UIColor.red.setStroke()
    rect.stroke()
    path.append(rect)
    
    let rectA = UIBezierPath(roundedRect: .init(x: weightedPoint.a.x - 1, y: weightedPoint.a.y - 1, width: 2, height: 2), byRoundingCorners: .allCorners, cornerRadii: .init(width: 2, height: 2))
    UIColor.green.setStroke()
    rect.stroke()
    path.append(rectA)
    
    let rectB = UIBezierPath(rect: .init(x: weightedPoint.b.x - 1, y: weightedPoint.b.y - 1, width: 2, height: 2))
    UIColor.blue.setStroke()
    rect.stroke()
    path.append(rectB)
  }
}

class PointBuffer {
  
  private var points: [WeightedPoint]
  private let bufferSize: Int
  
  private let flushWhenFull: Bool
  
  private let _flush: ([WeightedPoint]) -> Void
  private let _completion: ([WeightedPoint]) -> Void
  
  var isFull: Bool {
    return points.count >= bufferSize
  }
  
  init(
    points: [WeightedPoint] = [],
    bufferSize: Int = 4,
    flushWhenFull: Bool = true,
    flush: @escaping ([WeightedPoint]) -> Void,
    completion: @escaping ([WeightedPoint]) -> Void
  ) {
    self.points = points
    self.bufferSize = bufferSize
    self.flushWhenFull = flushWhenFull
    self._flush = flush
    self._completion = completion
  }
  
  func addPoint(_ point: WeightedPoint) {
    
    points.append(point)
    
    if flushWhenFull, isFull {
      flush()
    }
  }
  
  func peek() -> [WeightedPoint] {
    return points
  }
  
  func clear() {
    points = []
  }
  
  func flush() {
    _flush(points)
    let copy = points
    points = []
    _completion(copy)
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
    
    let midAB = a.average(with: b)
    let midBC = b.average(with: c)
    
    path.move(to: a.a)
    path.addLine(to: a.b)
    path.addQuadCurve(to: b.b, controlPoint: midAB.b)
    path.addQuadCurve(to: c.b, controlPoint: midBC.b)
    path.addLine(to: c.a)
    path.addQuadCurve(to: b.a, controlPoint: midBC.a)
    path.addQuadCurve(to: a.a, controlPoint: midAB.a)
    
    return path
  }
  
  private static func generateCurve(
    a: WeightedPoint,
    b: WeightedPoint,
    c: WeightedPoint,
    d: WeightedPoint
  ) -> UIBezierPath {
    
    let path: UIBezierPath = .init()
    
    let midAB = a.average(with: b)
    let midBC = b.average(with: c)
    let midCD = c.average(with: d)
    
    path.move(to: a.a)
    path.addLine(to: a.b)
    path.addCurve(to: midBC.b, controlPoint1: midAB.b, controlPoint2: b.b)
    path.addCurve(to: d.b, controlPoint1: c.b, controlPoint2: midCD.b)
    path.addLine(to: d.a)
    path.addCurve(to: midBC.a, controlPoint1: midCD.a, controlPoint2: c.a)
    path.addCurve(to: a.a, controlPoint1: b.a, controlPoint2: midAB.a)
    
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
