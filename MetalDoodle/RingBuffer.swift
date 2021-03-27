//
//  RingBuffer.swift
//  MetalDoodle
//
//  Created by Takuma Matsushita on 2021/03/27.
//

import Foundation

class RingBuffer<T> {
  
  private var array: [T?]
  private var index: Int = 0
  
  private let count: Int
  
  init(count: Int) {
    self.count = count
    self.array = .init(repeating: nil, count: count)
  }
  
  func enqueue(_ value: T) {
    let targetIndex = (index + 1) % count
    array[targetIndex] = value
    index += 1
  }
  
  @discardableResult
  func dequeue() -> T? {
    let targetIndex = (index + count - 1) % count
    let value = array[targetIndex]
    array[targetIndex] = nil
    index -= 1
    return value
  }
  
  func clear() {
    self.index = 0
    self.array = .init(repeating: nil, count: count)
    self.count
  }
}
