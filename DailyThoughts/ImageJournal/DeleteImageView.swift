/// Copyright (c) 2023 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import UIKit
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

struct DeleteImageView: View {
    @State var imageURLs: [URL] = []
  let columns: [GridItem] = [
   GridItem(.flexible())
  ]
  
  @State private var showAlert = false

  var body: some View {
    VStack{
      
      Text("Select an image to delete")
        .font(.custom("Helvetica Neue", size: 20))
         .foregroundColor(.mint)
        ScrollView {
          LazyVGrid(columns: columns, spacing: 10) {
            ForEach(imageURLs, id: \.self) { url in
              RemoteImage(url: url)
                .aspectRatio(contentMode: .fill)
                .frame(width:150,height: 150)
                .clipped()
                .onTapGesture {
                  deleteImage(url: url)
                }
                .alert(isPresented: $showAlert) {
                               Alert(title: Text("Image deleted"), message: nil, dismissButton: .default(Text("OK")))
                           }
            }
          }
          .padding()
        }
        .onAppear {
          imageURLs=[]
          getImageURLs()
        }
        .padding(.bottom,40)
    }.frame(height: 700)
  }
    
    func getImageURLs() {
        let db = Firestore.firestore()
        db.collection("images").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let urlString = data["url"] as? String, let url = URL(string: urlString) {
                        imageURLs.append(url)
                    }
                }
            }
        }
    }
    
    func deleteImage(url: URL) {

        let db = Firestore.firestore()
        let query = db.collection("images").whereField("url", isEqualTo: url.absoluteString)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                for document in querySnapshot!.documents {
                    let documentID = document.documentID
                    let data = document.data()
                    print("data is ", data)
                  let imageRef = Storage.storage().reference(forURL: url.absoluteString)
                  imageRef.delete { error in
                    if let error = error {
                     print("Error in delete",error)
                    } else {
                      print("Success")
                      showAlert=true;
                      
                    }
                  }
                
                    db.collection("images").document(documentID).delete()
                    if let index = imageURLs.firstIndex(of: url) {
                        imageURLs.remove(at: index)
                    }
                }
            }
        }

    }
}

struct JournalMainView_Previews4: PreviewProvider {
    static var previews: some View {
      DeleteImageView()
    }
}
