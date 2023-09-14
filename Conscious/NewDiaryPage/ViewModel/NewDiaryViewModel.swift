//
//  NewDiaryViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/14.
//

import Foundation
import Combine
import FirebaseFirestore

class NewDiaryViewModel: ObservableObject {
    
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var photoCollection: [Photo] = []
    @Published var photoData: Data
    
    private var cancellables = Set<AnyCancellable>()
    
    func saveDiary() {
        uploadPhotos(imageData: photoData) { url in
                if let url = url {
                    let newPhotoCollection = [Photo(url: url,
                                                   description: "",
                                                   photoID: UUID().uuidString)]

                    let newDiary = Diary(diaryID: UUID().uuidString,
                                         date: Date(),
                                         title: self.title,
                                         content: self.content,
                                         photoCollection: newPhotoCollection)

                    FirebaseManager.shared.addNewDiary(user: "no1", diary: newDiary)
                } else {
                    print("照片上傳失敗，日記未保存。")
                }
            }
    }
    
    // 當函數執行完畢後才執行 Closure
    func uploadPhotos(imageData: Data, completion: @escaping (_ url: String?) -> Void) {
        let storage = Storage.storage()
        let imageRef = storage.reference().child("images/\(UUID().uuidString).jpg")
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("上傳失敗: \(error)")
                completion(nil)
                return
            }
            
            // 上傳成功後下載 URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("獲取URL失敗: \(error)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }

}
