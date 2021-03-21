//
//  ContentView.swift
//  MetalDoodle
//
//  Created by Takuma Matsushita on 2021/03/05.
//

import SwiftUI

struct ContentView: View {
  let doodleView = DoodleView()
  var body: some View {
    VStack {
      Button("clear") {
        doodleView.clear()
      }
      .padding()
      doodleView
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
