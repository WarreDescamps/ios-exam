//
//  CustomTabView.swift
//  IOS-Project
//
//  Created by Warre Descamps on 16/12/2022.
//

import SwiftUI

struct CustomTabView<Content, SelectionValue>: View where Content: View, SelectionValue: Hashable {
    private var selection: Binding<SelectionValue>?
    private var rotation: Double
    private var content: () -> Content
    
    init(selection: Binding<SelectionValue>?, rotation: Double = 90, @ViewBuilder content: @escaping () -> Content) {
        self.selection = selection
        self.rotation = rotation
        self.content = content
    }
    
    var body: some View {
        GeometryReader { proxy in
            TabView(selection: selection) {
                Group {
                    content()
                }
                .rotationEffect(.degrees(-rotation))
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .rotationEffect(.degrees(rotation), anchor: .topLeading)
            .frame(width: proxy.size.height, height: proxy.size.width)
        }
    }
}

extension CustomTabView where SelectionValue == Int {
    
    init(rotation: Double = 90, @ViewBuilder content: @escaping () -> Content) {
        self.selection = nil
        self.rotation = rotation
        self.content = content
    }
}

struct CustomTabView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabView() {
            Color.clear
        }
    }
}
