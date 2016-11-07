//
//  ChatViewController.swift
//  ChatMaster
//
//  Created by Craig Clayton on 11/4/16.
//  Copyright © 2016 Cocoa Academy. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import AVFoundation
import MobileCoreServices
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

enum MessageType:String {
    case photo = "PHOTO"
    case text = "TEXT"
}

class ChatViewController: JSQMessagesViewController {
    
    var messages:[JSQMessage] = []
    var image: UIImage?
    var dictAvatar = [String: JSQMessagesAvatarImage]()
    var messageRef = FIRDatabase.database().reference().child("messages")
    let photoCache = NSCache<AnyObject, AnyObject>()
    let manager = ChatManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func initialize() {
        getCurrentUser()
        observeMessages()
    }
    
    func getCurrentUser() {
        let currentUser = FIRAuth.auth()?.currentUser
        guard let user = currentUser else { return }
        senderId = user.uid
        
        if user.isAnonymous {
            senderDisplayName = "anonymous"
        }
        else {
            if let name = user.displayName {
               senderDisplayName = "\(name)"
            }
            else {
                senderDisplayName = ""
            }
        }
    }
    
    func observeMessages() {
        messageRef.observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: AnyObject] {
            
                let type = MessageType(rawValue: dict["mediaType"] as! String)
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                let text = dict["text"] as? String
                
                self.observeUsers(by: senderId)
                
                if type == .text {
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    self.collectionView.reloadData()
                }
                else {
                    if let fileURL = dict["fileURL"] as? String {
                        if let url = URL(string: fileURL) {
                            var photo = JSQPhotoMediaItem(image: nil)
                            
                            if let cachedPhoto = self.photoCache.object(forKey: fileURL as AnyObject) as? JSQPhotoMediaItem {
                                photo = cachedPhoto
                                self.collectionView.reloadData()
                            }else {
                                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
                                    do {
                                        let data = try Data(contentsOf: url)
                                        DispatchQueue.main.async {
                                            let pic = UIImage(data: data)
                                            photo!.image = pic
                                            self.collectionView.reloadData()
                                            self.photoCache.setObject(photo!, forKey: fileURL as AnyObject)
                                        }
                                        
                                    } catch let error {
                                        print(error)
                                    }
                                }
                            }
                            
                            
                            
                            self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                            
                            if self.senderId == senderId {
                                photo?.appliesMediaViewMaskAsOutgoing = true
                            }
                            else {
                                photo?.appliesMediaViewMaskAsOutgoing = false
                            }
                            
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        })
    }

    func observeUsers(by id:String) {
        FIRDatabase.database().reference().child("users").child(id).observe(.value, with: { snapshot in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                let avatarURL = dict["profileURL"] as! String
                self.setup(avatarURL, messageID: id)
            }
        })
    }
    
    func setup(_ avatarURL:String, messageID:String) {
        if avatarURL != "" {
            if let fileURL = NSURL(string: avatarURL) {
                do {
                    let data = try Data(contentsOf: fileURL as URL)
                    let image = UIImage(data: data)
                    let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
                    dictAvatar[messageID] = userImg
                    
                } catch let error {
                    print(error)
                }
            }
        }
        else {
            dictAvatar[messageID] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
        }
        
        collectionView.reloadData()
    }
    
    func checkSource() {
        let cameraMediaType = AVMediaTypeVideo
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)
        
        switch cameraAuthorizationStatus {
            
        case .authorized:
            showCameraUserInterface()
            
        case .restricted:
            break
            
        case .denied:
            break
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: cameraMediaType) { granted in
                if granted {
                    self.showCameraUserInterface()
                } else {
                }
            }
        }
    }
    
    func upload(_ image:UIImage?) {
        let filePath = "\(FIRAuth.auth()!.currentUser!)/\(Date.timeIntervalSinceReferenceDate)"
        
        guard let img = image else { return }
        guard let data = UIImageJPEGRepresentation(img, 0.1) else { return }
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        
        FIRStorage.storage().reference().child(filePath).put(data, metadata: metadata, completion: { (metadata, error) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            guard let fileURL = metadata?.downloadURLs?.first else { return }
            self.send(message: "", url: fileURL.absoluteString, byType: .photo)
        })
    }
    
    
    
    
    func send(message text:String, url:String, byType:MessageType) {
        let newMessage = messageRef.childByAutoId()
        var messageData:[String: String] = [:]
        
        if byType == .photo {
            messageData = ["fileURL": url,"senderId": senderId, "senderName": senderDisplayName, "mediaType": byType.rawValue]
        }
        else {
            messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "mediaType": byType.rawValue]
        }
        
        newMessage.setValue(messageData)
    }
}

extension ChatViewController {
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        send(message: text, url: "", byType: .text)
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("accessory button tapped")
        checkSource()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        if message.senderId == senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .black)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .blue)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        // JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
        return dictAvatar[message.senderId]
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showCameraUserInterface() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        #else
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.showsCameraControls = true
        #endif
        
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImg = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.image = editedImg
        } else if let origImg = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = origImg
        }
        
        upload(image)
        picker.dismiss(animated: true, completion:nil)
        collectionView.reloadData()
    }
}
