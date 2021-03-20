//
//  DoodleViewController.swift
//  MetalDoodle
//
//  Created by Takuma Matsushita on 2021/03/05.
//

import UIKit
import SwiftUI

struct DoodleView: UIViewRepresentable {
  
  init() {
    
  }
  
  func makeUIView(context: Context) -> some UIView {
    DoodleBodyView()
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    
  }
}

class DoodleBodyView: UIView {
  
  private let bezierPathLayer: CAShapeLayer = {
    
    let layer = CAShapeLayer()
    layer.backgroundColor = UIColor.blue.cgColor
    
    return layer
  }()
  
  private var path: UIBezierPath = .init()
  private var previousPoint: WeightedPoint = .init(current: .init(x: 1, y: 1), previous: .init(x: 2, y: 2))
  
  init() {
    super.init(frame: .zero)
    
    layer.addSublayer(bezierPathLayer)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    bezierPathLayer.frame = frame
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("began", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
    path.move(to: point)
    
    previousPoint = .init(current: point, previous: previousPoint.origin)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("moved", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
//    print("###", point.distance(to: lastPoint), point.euclideanDistance(to: lastPoint))
//
//    print("@@@", Math.Linear.equation(through: (x: 1, y: 1), and: (x: 2, y: 2)))
    
    let weightedPoint = WeightedPoint(current: point, previous: previousPoint.origin)
    
    path.move(to: previousPoint.a)
    path.addLine(to: previousPoint.b)
    path.addQuadCurve(to: weightedPoint.b, controlPoint: previousPoint.b.average(with: weightedPoint.b))
    path.addLine(to: weightedPoint.a)
    path.addQuadCurve(to: weightedPoint.a, controlPoint: previousPoint.a.average(with: weightedPoint.a))
    path.move(to: weightedPoint.a)
    
    print("### \(weightedPoint)")
    
    previousPoint = weightedPoint
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("end", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
    path.addLine(to: point)
    
    path.close()
    
    bezierPathLayer.path = path.cgPath
    
    previousPoint = .init(current: point, previous: previousPoint.origin)
  }
}
