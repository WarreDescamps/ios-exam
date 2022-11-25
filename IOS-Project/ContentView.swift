//
//  ContentView.swift
//  IOS-Project
//
//  Created by Docent on 17/11/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LibraryView()
                .tabItem(){
                    Text("Library")
                }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
