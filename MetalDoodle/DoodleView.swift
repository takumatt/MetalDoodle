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
  private var previousBufferPoint: WeightedPoint? = nil
  
  private var drawingPath: UIBezierPath? = nil
  
  init() {
    
    super.init(frame: .zero)
    
    self.pointBuffer = .init(
      points: [],
      bufferSize: 4,
      flushWhenFull: true,
      flush: { [weak self] points in
        print(points.map { String($0.id) }.reduce("points", { $0 + "," + $1 }))
        
        print("---")
        points.forEach { p in
          print("a and b:", p.a, p.b)
        }
        print("---")
        
        let modPoints: [WeightedPoint]
//        if let previousBufferPoint = self?.previousBufferPoint {
//          modPoints = [points.first!.average(with: previousBufferPoint), points[1], points[2], points[3]]
//        } else {
        modPoints = points
//        }
        
        let generatedPath = BezierPathGenerator.generate(weightedPoint: modPoints)
        self?.path.append(generatedPath)
      },
      completion: { [weak self] points in
        guard let self = self else { return }
        guard let last = points.last else { return }
        self.pointBuffer.addPoint(last)
        self.previousBufferPoint = points[2]
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
    previousBufferPoint = nil
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
    
    let modB: WeightedPoint = b.average(with: a, and: c)
    
    path.move(to: a.a)
    path.addLine(to: a.b)
    path.addQuadCurve(to: c.b, controlPoint: modB.b)
    path.addLine(to: c.a)
    path.addQuadCurve(to: a.a, controlPoint: modB.a)
    
    return path
  }
  
  private static func generateCurve(
    a: WeightedPoint,
    b: WeightedPoint,
    c: WeightedPoint,
    d: WeightedPoint
  ) -> UIBezierPath {
    
    let path: UIBezierPath = .init()
    
    let modB = b.average(with: a, and: c)
    let modC = c.average(with: b, and: d)
    
    path.move(to: a.a)
    path.addLine(to: a.b)
    path.addCurve(to: d.b, controlPoint1: modB.b, controlPoint2: modC.b)
    path.addLine(to: d.a)
    path.addCurve(to: a.a, controlPoint1: modC.a, controlPoint2: modB.a)
    
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
