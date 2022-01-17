//
//  ViewController.swift
//  Firebase_Auth_test
//
//  Created by 최광호 on 2022/01/17.
//

// Info에서 스키마 필수임 (그러니 Google.Service.plist 다운 받아서

import UIKit
import Firebase
import SnapKit
import Then

class ViewController: UIViewController {

    let phoneTextField = UITextField().then {
        $0.textColor = .black
        $0.backgroundColor = .systemGray5
        $0.placeholder = "전화번호를 입력하세요"
        // 유효성 체크 안함
    }
    let authTextField = UITextField().then {
        $0.textColor = .black
        $0.backgroundColor = .systemGray5
        $0.placeholder = "인증번호를 입력하세요"
    }
    let button = UIButton().then {
        $0.backgroundColor = .systemGreen
        $0.setTitle("인증확인", for: .normal)
    }
    let visibleView = UIView().then {
        $0.backgroundColor = .black
        $0.isHidden = true
    }
    let callButton = UIButton().then {
        $0.backgroundColor = .systemGreen
        $0.setTitle("인증번호 요청", for: .normal)
    }
    
    let signOutButton = UIButton().then {
        $0.backgroundColor = .systemGreen
        $0.setTitle("로그아웃하기", for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConstrains()
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(callButtonClicked), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(signOutButtonClicked), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setConstrains() {
        view.backgroundColor = .white
        view.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(100)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(-200)
            $0.height.equalTo(50)
        }
        
        view.addSubview(authTextField)
        authTextField.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(phoneTextField)
            $0.top.equalTo(phoneTextField.snp.bottom).offset(30)
        }
        
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(phoneTextField)
            $0.top.equalTo(authTextField.snp.bottom).offset(30)
        }
        view.addSubview(visibleView)
        visibleView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(callButton)
        callButton.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(phoneTextField)
            $0.top.equalTo(button.snp.bottom).offset(30)
        }
        
        view.addSubview(signOutButton)
        signOutButton.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(phoneTextField)
            $0.top.equalTo(callButton.snp.bottom).offset(30)
        }
    }
    
    @objc func signOutButtonClicked() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("싸인 아웃함")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @objc func callButtonClicked() {
        guard let userAuthNumber = authTextField.text, let authVerificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }
        
        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: authVerificationID,
          verificationCode: userAuthNumber
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
              let authError = error as NSError
              if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                // The user is a multi-factor user. Second factor challenge is required.
                let resolver = authError
                  .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                var displayNameString = ""
                for tmpFactorInfo in resolver.hints {
                  displayNameString += tmpFactorInfo.displayName ?? ""
                  displayNameString += " "
                }
              }
              return
            }
            
            // User is signed in
            print("성공했을 때 나옴", authResult)
            print("성공했을 때 나옴", authResult?.autoContentAccessingProxy)
            print("성공했을 때 나옴", authResult?.user)
            print(authResult?.user.uid)
            print(authResult?.user.phoneNumber)
        }
    }
    
    @objc func buttonClicked() {
        // 폰 번호 넣을 때 + 필수
        guard let phoneNumber = phoneTextField.text else { return }
        
        Auth.auth().languageCode = "ko-KR"
//        Auth.auth().languageCode = "en"
        
        PhoneAuthProvider
            .provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                print("확인된 ID", verificationID)
                guard let verificationID = verificationID else { return }
                UserDefaults.standard.set(verificationID,forKey: "authVerificationID")
            }
    }


}

