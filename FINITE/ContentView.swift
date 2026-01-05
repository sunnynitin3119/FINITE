//
//  ContentView.swift
//  FINITE
//
//  Created by Nitin Yeligeti on 03/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var usedDots: Int = UserDefaults.standard.integer(forKey: "usedDots")
    let totalDots = 365
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 12)

    var body: some View {
        VStack(spacing: 20) {

            Text("Finite")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.white)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<totalDots, id: \.self) { index in
                    Circle()
                        .fill(index < usedDots ? Color.gray.opacity(0.4) : Color.blue)
                        .frame(width: 14, height: 14)
                        .onTapGesture {
                            if index == usedDots {
                                usedDots += 1
                                UserDefaults.standard.set(usedDots, forKey: "usedDots")
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                }
            }
            .padding()

            let remaining = totalDots - usedDots
            let percent = Int((Double(remaining) / Double(totalDots)) * 100)

            Text("\(remaining)d left · \(percent)%")
                .foregroundColor(.gray)
                .font(.footnote)
        }
        .padding()
        .background(Color.black)
        .ignoresSafeArea()
    }
}
