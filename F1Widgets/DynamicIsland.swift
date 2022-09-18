//
//  DynamicIsland.swift
//  F1Widgets
//
//  Created by Mantas Simanauskas on 2022-09-17.
//

import SwiftUI

struct DynamicIsland: View {
    @State var height: CGFloat = 200
    @State var heightExtended: Bool = false
    @State var widthExtended: Bool = false
    @State var showContent: Bool = false
    @State var canPerformToggle: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ZStack {
                    VStack {
                        Rectangle()
                            .foregroundColor(.black)
                        Rectangle()
                            .frame(height: 50)
                            .cornerRadius(100, corners: [.bottomLeft, .bottomRight])
                            .foregroundColor(.black)
                            .offset(y: -10)
                    }
                    Image(systemName: "viewfinder")
                        .foregroundColor(.white)
                        .font(.system(size: 50))
                        .scaleEffect(showContent ? 1 : 0)
                        .opacity(showContent ? 1 : 0)
                }
            }
            .frame(height: heightExtended ? (150) : 17)
            .frame(width: widthExtended ? (180) : 162)
            Spacer()
            Button(action: { self.toggleIsland() }) {
                Text("Toggle")
                    .padding(.bottom, 50)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.toggleIsland()
            }
        }
    }

    func toggleIsland() {
        if self.canPerformToggle {
            self.canPerformToggle = false
            if showContent {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.showContent = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring()) {
                        self.heightExtended = false
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.canPerformToggle = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.heightExtended = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring()) {
                        self.showContent = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.canPerformToggle = true
                }
            }
        }
    }
}

struct DynamicIsland_Previews: PreviewProvider {
    static var previews: some View {
        DynamicIsland()
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

