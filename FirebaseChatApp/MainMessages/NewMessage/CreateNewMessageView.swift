//
//  CreateNewMessageView.swift
//  FirebaseChatApp
//
//  Created by GUREL on 1.11.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct CreateNewMessageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var vm = CreateNewMessageViewModel()
    var didTapOnChatUser: (ChatUser) -> ()
    
    var body: some View {
        
        NavigationView{
            ScrollView {
                Text("\(vm.errorMessage)")
                ForEach(vm.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didTapOnChatUser(user)
                    } label: {
                        userDataView(imageProfile: user.imageProfile, email: user.email)
                    }
                    
                    Divider()
                }
            }
            
            .navigationTitle("Yeni Mesaj")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Geri")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        
    }
    
    struct userDataView: View {
        var imageProfile: String?
        var email: String?
        
        var body: some View {
            
            HStack{
                WebImage(url: URL(string: imageProfile ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1)
                    )
                    .shadow(radius: 5)
                
                
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(email?.replacingOccurrences(of: "@gmail.com", with: "") ?? "")")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(.label))
                }
                
                Spacer()
            }.padding()
            
        }
    }
}

#Preview {
    //CreateNewMessageView()
    MainMessagesView()
}
