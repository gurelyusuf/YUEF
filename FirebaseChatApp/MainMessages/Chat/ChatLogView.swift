//
//  ChatLogView.swift
//  FirebaseChatApp
//
//  Created by GUREL on 1.11.2023.
//

import SwiftUI

struct ChatLogView: View {
    
    //let chatUser: ChatUser?
    
    @State var chatText = ""
    @ObservedObject var vm: ChatLogViewModel = ChatLogViewModel(chatUser: nil)
    
    
    //    init(chatUser: ChatUser?) {
    //        self.chatUser = chatUser
    //        vm = .init(chatUser: chatUser)
    //    }
    
    var body: some View {
        ZStack {
            messagesView
            VStack(spacing: 0) {
                Spacer()
                chatBottomBar
                    .background(Color.white.ignoresSafeArea())
            }
        }
        .navigationTitle(vm.chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.firestoreListener?.remove()
        }
    }
    
    private var messagesView: some View {
        VStack {
            if #available(iOS 15.0, *) {
                ScrollView {
                    ScrollViewReader{ scrollViewProxyx in
                        ForEach(vm.chatMessages) { message in
                            
                            MessageView(message: message)
                        }
                        
                        HStack{ Spacer() }
                        .id("empty")
                        .onReceive(vm.$count) { _ in
                            
                            withAnimation(.easeInOut(duration: 0.3)){
                                scrollViewProxyx.scrollTo("empty", anchor: .bottom)
                            }
                        }
                    }
                    
                    
                }
                .background(Color(.init(white: 0.95, alpha: 1)))
                .safeAreaInset(edge: .bottom) {
                    chatBottomBar
                        .background(Color(.systemBackground).ignoresSafeArea())
                }
            } else {
                
            }
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                vm.count += 1
                vm.handleSend()
            } label: {
                Text("Gönder")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Mesaj")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
        
        
    }
}

struct MessageView : View{
    var message: ChatMessage
    
    var body: some View{
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}


#Preview {
    MainMessagesView()
}
