//
//  NewDiaryViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/14.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage

class NewDiaryViewModel: ObservableObject {

    @Published var title: String = ""
    @Published var content: String = ""
    @Published var photoCollection: [Photo] = []
    @Published var photoData: Data?

    private var cancellables = Set<AnyCancellable>()

    var isEditing: Bool = false

    // 修改日記
    var diaryToEdit: Diary? {
        didSet {
            title = diaryToEdit?.title ?? ""
            content = diaryToEdit?.content ?? ""
            isEditing = true
        }
    }

    func saveDiary() {
        if isEditing {
                updateDiary()
            } else {
                if photoData != nil {
                    uploadPhotos(imageData: photoData!) { url, photoID in
                        if let url = url, let photoID = photoID {
                            self.saveDiaryWithPhoto(url: url, photoID: photoID)
                            print("有照片")
                        } else {
                            print("照片上傳失敗，日記未保存。")
                        }
                    }
                } else {
                    saveDiaryWithPhoto(url: nil, photoID: nil)
                    print("沒照片")
                }
            }
    }

    func updateDiary() {
        guard let diaryID = diaryToEdit?.diaryID,
              let date = diaryToEdit?.timestamp else { return }

        let updatedDiary = Diary(diaryID: diaryID,
                                 date: date,
                                 title: self.title,
                                 content: self.content,
                                 photoCollection: self.photoCollection)

        FirebaseManager.shared.updateDiary(user: "no1", diary: updatedDiary)
    }

    func saveDiaryWithPhoto(url: String?, photoID: String?) {
        let newPhotoCollection = url != nil ? [Photo(url: url!, description: "", photoID: photoID ?? "")] : []
        let newDiary = Diary(diaryID: UUID().uuidString,
                             date: Date(),
                             title: self.title,
                             content: self.content,
                             photoCollection: newPhotoCollection)

        FirebaseManager.shared.addNewDiary(user: "no1", diary: newDiary)
    }

    // 當函數執行完畢後才執行 Closure
    func uploadPhotos(imageData: Data, completion: @escaping (_ url: String?, _ photoID: String?) -> Void) {

        let newPhotoID = UUID().uuidString

        let storage = Storage.storage()
        let imageRef = storage.reference().child("images/\(newPhotoID).jpg")

        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("上傳失敗: \(error)")
                completion(nil, nil)
                return
            }

            // 上傳成功後下載 URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("獲取URL失敗: \(error)")
                    completion(nil, nil)
                } else {
                    completion(url?.absoluteString, newPhotoID)
                }
            }
        }
    }
}
