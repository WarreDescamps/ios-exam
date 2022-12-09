//
//  MangaDetailView.swift
//  IOS-Project
//
//  Created by Warre Descamps on 09/12/2022.
//

import SwiftUI

struct MangaDetailView: View {
    @State var manga: Manga
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MangaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MangaDetailView(manga: DebugConstants.worldTrigger)
    }
}
