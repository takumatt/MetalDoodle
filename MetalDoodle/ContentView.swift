//
//  ContentView.swift
//  MetalDoodle
//
//  Created by Takuma Matsushita on 2021/03/05.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      VStack {
        Text("Hello, world!")
            .padding()
        DoodleView()
      }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
