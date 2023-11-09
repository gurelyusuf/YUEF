//
//  LoginView.swift
//  FirebaseChatApp
//
//  Created by GUREL on 1.11.2023.
//

import SwiftUI

struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var sifre = ""
    
    @State private var shouldShowImagePicker = false
    
    @State private var showAlert = false
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Secici Burada")) {
                        Text("Giriş Yap")
                            .tag(true)
                        Text("Hesap Oluştur")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding()
                    
                    if !isLoginMode {
                        Button {
                            shouldShowImagePicker
                                .toggle()
                        } label: {
                            //Person.fill yerine seçilen fotoyu gösterme:
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                    
                                        .cornerRadius(64)
                                    
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .foregroundColor(.gray)
                                        .padding()
                                    
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)  .stroke(Color.black, lineWidth: 3)
                            )
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Şifre", text: $sifre)
                    }
                    .padding(12)
                    .background(Color.white)
                    
                    Button(action: {
                        buttonAction()
                        //Mesajı Göster
                        self.showAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Giriş Yap" : "Hesap Oluştur")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Mesaj"), message: Text(self.girisYapmaDurumuMesaji), dismissButton: .default(Text("Tamam")))
                    }
            }
                .padding()
                .navigationTitle(isLoginMode ? "Giriş Yap" : "Hesap Oluştur")
                
            }
            .background(Color(.systemGray6)
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }

    
    @State var image: UIImage?
    //MARK: Butona basıldığında yapılacaklar
    private func buttonAction() {
        if isLoginMode {
            print("Firebase'e giris yapmalisiniz")
            girisYap()
        } else {
            yeniHesapOlustur()
            print("Firebase Auth'un içine yeni bir hesap kaydedin")
        }
    }
    
    private func girisYap() {
        FirebaseManager.shared.auth.signIn(withEmail: email,password: sifre) {
            result, err in
            if let err = err {
                print("Giris yaparken hata: ", err)
                self.girisYapmaDurumuMesaji = "Giris yaparken hata: \(err)"
                return
            }
            print("Kullanici basariyla giris yapti: \(result?.user.uid ?? "")")
            
            self.girisYapmaDurumuMesaji = "Kullanici basariyla giris yapti: \(result?.user.uid ?? "")"
            
            self.didCompleteLoginProcess()
            
        }
    }
    
    @State var girisYapmaDurumuMesaji = ""
    
    private func yeniHesapOlustur() {
        if self.image == nil {
            self.girisYapmaDurumuMesaji = "Profil fotoğrafı seçmelisin."
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: sifre) {
            result, err in
            if let err = err {
                print("Yeni hesap olustururken hata: ", err)
                self.girisYapmaDurumuMesaji = "Yeni hesap olustururken hata: \(err)"
                return
            }
            print("Kullanici basariyla olusturuldu: \(result?.user.uid ?? "")")
            
            self.girisYapmaDurumuMesaji = "Kullanici basariyla olusturuldu: \(result?.user.uid ?? "")"
            
            self.goruntuyuDepola()
        }
    }
    
    private func goruntuyuDepola(){
        
        //let dosyaadi = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5)
        else { return }
        
        ref.putData(imageData, metadata: nil) {
            metadata, err in
            if let err = err {
                self.girisYapmaDurumuMesaji = "Fotoyu yüklerken hata oluştu \(err)"
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    self.girisYapmaDurumuMesaji = "Fotoyu indirirken hata oluştu \(err)"
                    return
                    
                }
                self.girisYapmaDurumuMesaji = "Foto basariyla kaydedildi \(url?.absoluteString ?? "")"
                
                guard let url = url else { return }
                self.kullaniciBilgisiniDepola(imageProfileUrl: url)
            }
        }
    }
    private func kullaniciBilgisiniDepola(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) {
                err in
                if let err = err {
                    print(err)
                    self.girisYapmaDurumuMesaji = "\(err)"
                    return
                }
                
                print("Success")
                
                self.didCompleteLoginProcess()
            }
    }
}
    #Preview {
        LoginView(didCompleteLoginProcess: {
        })
    }
