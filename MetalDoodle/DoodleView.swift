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
  
  private var path: UIBezierPath = .init()
  private var previousPoint: WeightedPoint = .init(current: .init(x: 1, y: 1), previous: .init(x: 2, y: 2), height: .zero)
  
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
    
    previousPoint = .init(current: point, previous: previousPoint.origin, height: self.frame.height)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("moved", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
    let weightedPoint = WeightedPoint(current: point, previous: previousPoint.origin, height: self.frame.height)
    
//    let rect = UIBezierPath(rect: .init(x: weightedPoint.origin.x - 1, y: weightedPoint.origin.y - 1, width: 2, height: 2))
//    UIColor.red.setFill()
//    rect.fill()
//    path.append(rect)
//
//    let rectA = UIBezierPath(rect: .init(x: weightedPoint.a.x - 1, y: weightedPoint.a.y - 1, width: 2, height: 2))
//    UIColor.green.setFill()
//    rect.fill()
//    path.append(rectA)
//
//    let rectB = UIBezierPath(rect: .init(x: weightedPoint.b.x - 1, y: weightedPoint.b.y - 1, width: 2, height: 2))
//    UIColor.blue.setFill()
//    rect.fill()
//    path.append(rectB)
    
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
}
