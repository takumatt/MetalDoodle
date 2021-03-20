//
//  DoodleViewController.swift
//  MetalDoodle
//
//  Created by Takuma Matsushita on 2021/03/05.
//

import UIKit
import SwiftUI
import Metal
import MetalKit
import simd

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
  private var lastPoint: CGPoint = .zero
  
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
    lastPoint = point
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("moved", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
    print("###", point.distance(to: lastPoint), point.euclideanDistance(to: lastPoint))
      
    path.addLine(to: point)
    lastPoint = point
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    print("end", touches.map { $0.location(in: self) })
    
    guard let touch = touches.first else { return }
    
    let point = touch.location(in: self)
    
    path.addLine(to: point)
    
    path.close()
    
    bezierPathLayer.path = path.cgPath
  }
}

struct WeightedPoint {
  
  static let maxWeight: CGFloat = 5.0
  
  let a: CGPoint
  let b: CGPoint
  
  let weight: CGFloat
  
//  init(with point: CGPoint, weight: CGFloat) {
//    // 傾きがいる
//    self.a = .init(x: x, y: <#T##CGFloat#>) weight / 2
//      self.b =
//      self.weig
//  }
}

class MTKViewWrapper: UIView {
  //MARK: METAL VARS
  private var metalView : MTKView!
  private var metalDevice : MTLDevice!
  private var metalCommandQueue : MTLCommandQueue!
  private var metalRenderPipelineState : MTLRenderPipelineState!
  
  //MARK: VERTEX VARS
  private var circleVertices = [simd_float2]()
  private var vertexBuffer : MTLBuffer!
  
  //MARK: INIT
  public required init() {
    super.init(frame: .zero)
    setupView()
    setupMetal()
    createVertexPoints()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  //MARK: SETUP
  fileprivate func setupView(){
    translatesAutoresizingMaskIntoConstraints = false
  }
  
  fileprivate func setupMetal(){
    //view
    metalView = MTKView()
    addSubview(metalView)
    metalView.translatesAutoresizingMaskIntoConstraints = false
    metalView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    metalView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    metalView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    metalView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    
    metalView.delegate = self
    
    //updates
    metalView.isPaused = true
    metalView.enableSetNeedsDisplay = true
    
    //connect to the gpu
    metalDevice = MTLCreateSystemDefaultDevice()!
    metalView.device = metalDevice
    
    //creating the command queue
    metalCommandQueue = metalDevice.makeCommandQueue()!
    
    //creating the render pipeline state
    createPipelineState()
    
    //turn the vertex points into buffer data
    vertexBuffer = metalDevice.makeBuffer(bytes: circleVertices, length: circleVertices.count * MemoryLayout<simd_float2>.stride, options: [])!
    
    //draw
    metalView.setNeedsDisplay()
  }
  
  fileprivate func createPipelineState(){
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    
    //finds the metal file from the main bundle
    let library = metalDevice.makeDefaultLibrary()!
    
    //give the names of the function to the pipelineDescriptor
    pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
    pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
    
    //set the pixel format to match the MetalView's pixel format
    pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
    
    //make the pipelinestate using the gpu interface and the pipelineDescriptor
    metalRenderPipelineState = try! metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
  }
  
  fileprivate func createVertexPoints(){
    func rads(forDegree d: Float)->Float32{
      return (Float.pi*d)/180
    }
    
    let origin = simd_float2(0, 0)
    
    for i in 0...720 {
      let position : simd_float2 = [cos(rads(forDegree: Float(Float(i)/2.0))),sin(rads(forDegree: Float(Float(i)/2.0)))]
      circleVertices.append(position)
      if (i+1)%2 == 0 {
        circleVertices.append(origin)
      }
    }
  }
}
extension MTKViewWrapper: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    //not worried about this
  }
  
  func draw(in view: MTKView) {
    //Creating the commandBuffer for the queue
    guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else {return}
    //Creating the interface for the pipeline
    guard let renderDescriptor = view.currentRenderPassDescriptor else {return}
    //Setting a "background color"
    renderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 1, 1)
    
    //Creating the command encoder, or the "inside" of the pipeline
    guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor) else {return}
    
    // We tell it what render pipeline to use
    renderEncoder.setRenderPipelineState(metalRenderPipelineState)
    
    /*********** Encoding the commands **************/
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 1081)
    
    renderEncoder.endEncoding()
    commandBuffer.present(view.currentDrawable!)
    commandBuffer.commit()
  }
}
