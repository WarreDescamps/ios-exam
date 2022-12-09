//
//  ContentView.swift
//  IOS-Project
//
//  Created by Docent on 17/11/2022.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State var mangaManager = MangaManager()
    
    @State private var userId = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            TabView {
                DiscoveryView(userId: userId)
                    .tabItem() {
                        Label("Discovery", systemImage: "globe")
                    }
                LibraryView(userId: userId, mangaManager: mangaManager)
                    .tabItem() {
                        Label("Library", systemImage: "books.vertical")
                    }
            }
            .ignoresSafeArea()
        } else {
            authContent
        }
    }
    
    var authContent: some View {
        ZStack {
            Color.black
            RoundedRectangle(cornerRadius: 30, style: .circular)
                .foregroundStyle(.linearGradient(colors: [.purple, .orange, .cyan], startPoint: .topTrailing, endPoint: .bottomTrailing))
                .frame(width: 1000, height: 400)
                .rotationEffect(.degrees(135))
                .offset(y: -350)
            
            VStackLayout(spacing: 20) {
                Text("Welcome")
                    .foregroundColor(.white)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .offset(x: -90, y: -90)
                
                TextField("Email", text: $email)
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .placeholder(when: email.isEmpty) {
                        Text("Email")
                            .foregroundColor(.white)
                            .bold()
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(.white)
                    .offset(y: /*@START_MENU_TOKEN@*/-10.0/*@END_MENU_TOKEN@*/)
                
                SecureField("Password", text: $password)
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .placeholder(when: password.isEmpty) {
                        Text("Password")
                            .foregroundColor(.white)
                            .bold()
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(.white)
                    .offset(y: /*@START_MENU_TOKEN@*/-10.0/*@END_MENU_TOKEN@*/)
                
                Button {
                    register()
                } label: {
                    Text("Sign up")
                        .bold()
                        .frame(width: 200, height: 40)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.linearGradient(colors: [.purple, .cyan], startPoint: .top, endPoint: .bottomTrailing))
                        )
                        .foregroundColor(.white)
                }
                .padding(.top)
                .offset(y: 100)
                
                Button {
                    login()
                } label: {
                    Text("Already have an account? Login")
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.top)
                .offset(y: 110)
            }
            .frame(width: 350)
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if user != nil {
                        userId = user?.uid as? String ?? ""
                        isLoggedIn.toggle()
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool,
                                    alignment: Alignment = .leading,
                                    @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
