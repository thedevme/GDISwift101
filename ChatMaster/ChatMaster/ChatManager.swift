//
//  ChatManager.swift
//  ChatMaster
//
//  Created by Craig Clayton on 11/4/16.
//  Copyright © 2016 Cocoa Academy. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase

class ChatManager: NSObject {

    func login(view:UIViewController) {
        FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser?, error:Error?) in
            if error != nil {
                print(error as Any)
                return
            }
            
            self.create(user, isAnonymous: true)
            print("user id \(user?.uid)")
            view.performSegue(withIdentifier: "showChat", sender: self)
        })
    }
    
    func googleLogin(with authentication:GIDAuthentication, view:UIViewController) {
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user: FIRUser?, error:Error?) in
            if error != nil {
                print(error as Any)
                return
            }
            
            self.create(user, isAnonymous: false)
            view.performSegue(withIdentifier: "showChat", sender: self)
        })
    }
    
    func create(_ user:FIRUser?, isAnonymous:Bool) {
        if let user = user {
            let newUser = FIRDatabase.database().reference().child("users").child(user.uid)
                if isAnonymous {
                    newUser.setValue(["displayname": "Anonymous", "id": user.uid, "profileURL": ""])
                }
                else {
                    if let name = user.displayName {
                        
                        
                        if let url = user.photoURL {
                            newUser.setValue(["displayname": "\(name)", "id": user.uid, "profileURL": url.absoluteString])
                        }
                        else {
                            newUser.setValue(["displayname": "\(name)", "id": user.uid, "profileURL": ""])
                        }
                    }
                
            }
        }
    }
}
