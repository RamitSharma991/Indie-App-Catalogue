//
//  AccountView.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var viewModel: PhraseViewModel
    @State private var showingSignInSheet = false
    @State private var showingSignUpSheet = false
    @State private var email = ""
    @State private var name = ""
    @AppStorage("isSignedIn") private var isSignedIn = false
    
    var body: some View {
        Form {
            if isSignedIn, let account = UserAccount.load() {
                // Profile Section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.tint)
                        
                        VStack(alignment: .leading) {
                            Text(account.name)
                                .font(.headline)
                            Text(account.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Account Actions
                Section {
                    Button(action: syncData) {
                        Label("Sync Data", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    Button(role: .destructive, action: signOut) {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                
            } else {
                Section {
                    Button(action: { showingSignInSheet = true }) {
                        Text("Sign In")
                    }
                    Button(action: { showingSignUpSheet = true }) {
                        Text("Create Account")
                    }
                }
            }
            
            // App Info Section
            Section {
                LabeledContent("Version") {
                    Text("1.0.0")
                }
                
                LabeledContent("Build") {
                    Text("100")
                }
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Account")
        .sheet(isPresented: $showingSignInSheet) {
            SignInView(isPresented: $showingSignInSheet)
        }
        .sheet(isPresented: $showingSignUpSheet) {
            SignUpView(isPresented: $showingSignUpSheet)
        }
    }
    
    private func signOut() {
        isSignedIn = false
        UserDefaults.standard.removeObject(forKey: "userAccount")
        viewModel.bookmarkedPhrases.removeAll()
    }
    
    private func syncData() {
        if var account = UserAccount.load() {
            account.bookmarks = viewModel.bookmarkedPhrases
            UserAccount.save(account)
        }
    }
}

struct SignInView: View {
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var password = ""
    @AppStorage("isSignedIn") private var isSignedIn = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
                
                Button("Sign In") {
                    // Implement actual authentication here
                    if let account = UserAccount.load(), account.email == email {
                        isSignedIn = true
                        isPresented = false
                    }
                }
                .disabled(email.isEmpty || password.isEmpty)
            }
            .navigationTitle("Sign In")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}

struct SignUpView: View {
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var name = ""
    @State private var password = ""
    @AppStorage("isSignedIn") private var isSignedIn = false
    @EnvironmentObject var viewModel: PhraseViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Name", text: $name)
                        .textContentType(.name)
                    SecureField("Password", text: $password)
                }
                
                Button("Create Account") {
                    let account = UserAccount(
                        email: email,
                        name: name,
                        bookmarks: viewModel.bookmarkedPhrases
                    )
                    UserAccount.save(account)
                    isSignedIn = true
                    isPresented = false
                }
                .disabled(email.isEmpty || name.isEmpty || password.isEmpty)
            }
            .navigationTitle("Create Account")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}
