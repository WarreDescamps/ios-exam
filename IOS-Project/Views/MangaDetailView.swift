//
//  MangaDetailView.swift
//  IOS-Project
//
//  Created by Warre Descamps on 09/12/2022.
//

import SwiftUI

struct MangaDetailView: View {
    @State var manga: Manga
    var onDismiss: () -> Void
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                onDismiss()
                self.mode.wrappedValue.dismiss()
            }){
                Label("Back", systemImage: "arrow.left")
            })
    }
}

struct MangaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MangaDetailView_PreviewContainer()
    }
}

struct MangaDetailView_PreviewContainer: View {
    @State var isShown: Bool = true
    
    var body: some View {
        MangaDetailView(manga: DebugConstants.worldTrigger, onDismiss: {isShown = false})
    }
}
