//
//  LoginViewController.swift
//  ChatMaster
//
//  Created by Craig Clayton on 11/4/16.
//  Copyright © 2016 Cocoa Academy. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    let manager = ChatManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().clientID = "446639020039-acg18ou6i3d42d5vd4ige8qjsgapicrc.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "showChat", sender: self)
            }
            else {
                print("not authorized")
            }
            
        })
        
    }
    
    @IBAction func unwindLogout(segue:UIStoryboardSegue) {
        do {
            try FIRAuth.auth()?.signOut()
            
        } catch let error {
            print(error)
        }
    }
    @IBAction func onAnonymousLoginTapped(_ sender: Any) {
        manager.login(view: self)
    }
    
    @IBAction func onGoogleLoginTapped(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
        
//
    }
}

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error as Any)
            return
        }
        
        manager.googleLogin(with: user.authentication, view: self)
    }
}
