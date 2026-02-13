//
//  AppDelegate.swift
//  WithUs-iOS
//
//  Created by 지상률 on 12/31/25.
//

import UIKit
import KakaoSDKCommon
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let notificationCenter = UNUserNotificationCenter.current()
    let notificationOption: UNAuthorizationOptions = [.alert, .badge, .sound]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //kakao
        let kakaoAppKey = Bundle.main.object(
            forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY"
        ) as? String ?? ""
        KakaoSDK.initSDK(appKey: kakaoAppKey)
        
        //firebase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        notificationCenter.delegate = self
        registerForPushNotivications()
        application.registerForRemoteNotifications()
        return true
    }
    
    func registerForPushNotivications() {
        notificationCenter.requestAuthorization(
            options: notificationOption, completionHandler: { granted, error in
                
                if let error = error {
                    print("DEBUG: \(error)")
                }
                
                if granted {
                    print("권한 허용 여부 \(granted)")
                }
            }
        )
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        FCMTokenManager.shared.fcmToken = fcmToken
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 기존 코드 유지
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .banner])
    }
    
    // 알림 클릭 시 추가
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // 서버에서 보내는 payload 예시
        // { "deeplink": "/today_question" }
        // { "deeplink": "/today_keyword/123" }
        if let deepLinkPath = userInfo["deeplink"] as? String,
           let url = URL(string: "https://withus.p-e.kr\(deepLinkPath)"),
           let deepLink = DeepLink.from(url: url) {
            
            DeepLinkHandler.shared.handle(deepLink: deepLink)
            
            // SceneDelegate의 AppCoordinator에 전달
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = scene.delegate as? SceneDelegate {
                sceneDelegate.appCoordinator?.handlePendingDeepLinkIfNeeded()
            }
        }
        
        completionHandler()
    }
}
