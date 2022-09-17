//
//  GithubActivityMapView.swift.swift
//  F1Widgets
//
//  Created by Mantas Simanauskas on 2022-09-16.
//

import SwiftUI

struct GithubActivityMapView: View {
    var body: some View {
        ZStack {
            VStack(spacing:0) {
                HStack(spacing: 0) {
                    ForEach(0...8, id: \.self) { index in
                        Rectangle()
                            .frame(width: 10, height: 10)
                            .opacity(index % 2 == 0 ? 1 : 0.2)
                        if index != 8 {
                            Spacer(minLength: 5)
                        }
                    }
                }
                Spacer(minLength: 0)
                HStack(spacing: 0) {
                    ForEach(0...8, id: \.self) { index in
                        Rectangle()
                            .frame(width: 10, height: 10)
                            .opacity(index % 2 != 0 ? 1 : 0.2)
                        if index != 8 {
                            Spacer(minLength: 5)
                        }
                    }
                }
                Spacer(minLength: 0)
                HStack(spacing: 0) {
                    ForEach(0...8, id: \.self) { index in
                        Rectangle()
                            .frame(width: 10, height: 10)
                            .opacity(index % 2 == 0 ? 1 : 0.2)
                        if index != 8 {
                            Spacer(minLength: 5)
                        }
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .cornerRadius(5)
        }
        .background(Color.black.opacity(0.05))
        .frame(width: 100, height: 100)
    }
}

struct GithubActivityMapView_Previews: PreviewProvider {
    static var previews: some View {
        GithubActivityMapView()
            .previewLayout(.sizeThatFits)
    }
}
