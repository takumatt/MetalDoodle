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


// protocolにするかも
enum BezierPathCreator {
  
  private static func createLine(
    a: WeightedPoint,
    b: WeightedPoint
  ) -> UIBezierPath {
    return .init()
  }
  
  private static func createCurve(
    a: WeightedPoint,
    b: WeightedPoint,
    c: WeightedPoint
  ) -> UIBezierPath {
    return .init()
  }
  
  private static func createQuadCurve(
    a: WeightedPoint,
    b: WeightedPoint,
    c: WeightedPoint,
    d: WeightedPoint
  ) -> UIBezierPath {
    return .init()
  }
  
  private static func interpolation(weightedPoint: [WeightedPoint]) -> [WeightedPoint] {
    return []
  }
  
  static func generate(weightedPoint: [WeightedPoint]) -> UIBezierPath {
    
    let bezierPath: UIBezierPath = .init()
    
    return bezierPath
  }
}
