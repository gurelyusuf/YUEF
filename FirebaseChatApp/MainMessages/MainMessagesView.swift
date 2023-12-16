//
//  MainMessagesView.swift
//  FirebaseChatApp
//
//  Created by GUREL on 1.11.2023.
//

import SwiftUI
import SDWebImageSwiftUI


struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var shouldShowNewMessageView = false
    @State var shouldShowMessageLogView = false
    
    @ObservedObject var vm = MainMessagesViewDocument()
    
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            
            
            WebImage(url: URL(string: vm.chatUser?.imageProfile ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipped()
                .cornerRadius(64)
                .overlay(RoundedRectangle(cornerRadius: 64)
                            .stroke(Color.black, lineWidth: 1)
                )
                .shadow(radius: 5)
            
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? "")")
                    .font(.system(size: 24, weight: .bold))
                
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Ayarlar"), message: Text("Ne yapmak istiyorsun?"), buttons: [
                .destructive(Text("Çıkış Yap"), action: {

                    vm.handleSignOut()

                    print("handle çıkış yap")
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView{
                //ilk kez giriş yapınca:
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser{
                    self.vm.fetchRecentMessages()
                }
                
            }
        }
    }
    
    @State var chatUser: ChatUser?
    
    var body: some View {
        
       
        NavigationView{
            VStack {
                
                customNavBar
                messagesView
                NavigationLink("", isActive:$shouldShowMessageLogView ) {
                    ChatLogView(vm:chatLogViewModel)
                }
            }
            .fullScreenCover(isPresented: $vm.userSignedInOnAnotherDevice) {
                VStack{
                    Text("Başka bir cihazda oturum açıldı. Lütfen çıkış yapın").padding()
                }
            }
            
            .overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    
    private var messagesView: some View {
        ScrollView {
            ForEach(vm.recentMessages) { message in
                
                Button {
                    
                    let uid = FirebaseManager.shared.auth.currentUser?.uid == message.fromId ? message.toId : message.fromId
                    
                    self.chatUser = .init(uid: uid, imageProfile: message.profileImageUrl, email: message.email)
                    
                    self.chatLogViewModel.chatUser = self.chatUser
                    self.chatLogViewModel.getMessages()
                    self.shouldShowMessageLogView.toggle()
                    
                    
                } label: {
                    VStack {
                        HStack(spacing: 16) {
                            
                            WebImage(url: URL(string: message.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color.black, lineWidth: 1))
                                .shadow(radius: 5)
                            
                            
                            
                            VStack(alignment: .leading) {
                                Text(message.username)
                                    .font(.system(size: 16, weight: .bold))
                                Text(message.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text(message.timeAgo)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Divider()
                            .padding(.vertical, 8)
                    }.padding(.horizontal)
                        .foregroundColor(Color(.label))
                }
                
            }.padding(.bottom, 50)
        }
    }
    
    
    private var newMessageButton: some View {
        Button {
            self.shouldShowNewMessageView.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ Yeni Mesaj")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        
        .fullScreenCover(isPresented: $shouldShowNewMessageView) {
            CreateNewMessageView { user in
                self.chatUser = user
                shouldShowMessageLogView.toggle()
                self.chatLogViewModel.chatUser = chatUser
                self.chatLogViewModel.getMessages()
            }
        }
    }
    
    
    
}

#Preview {
    MainMessagesView()
}
