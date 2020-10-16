//
//  AppDelegate.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    @Published var selectedTrailerModel: MovieInfo? {
        didSet {
            if let model = selectedTrailerModel {
                self.posterImage = idsAndImages[model.id] ?? nil
            }
            if isPlaying {
                isPlaying = false
                if selectedTrailerModel != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.isPlaying = true
                    }
                }
            }
        }
    }
    @Published var isExternalScreenConnected = false
    @Published var isPlaying = false
    @Published var posterImage: UIImage?
    
    @Published var idsAndImages = [Int: UIImage?]()
    
    var externalWindow: UIWindow?
    var externalVC: UIViewController?
    
    func fetchImagesFor(model movies: [MovieInfo]) {
        DispatchQueue.global(qos: .userInitiated).async {
            movies.forEach { movieInfo in
                if let url = URL(string: movieInfo.posterURL), let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.idsAndImages.updateValue(image, forKey: movieInfo.id)
                    }
                }
            }
        }
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NotificationCenter.default.addObserver(forName: UIScreen.didDisconnectNotification, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.isExternalScreenConnected = false
                self.externalVC = nil
                self.externalWindow = nil
            }
        }
        return true
    }
    
    private func setupExternalScreen(session: UISceneSession, options: UIScene.ConnectionOptions) {
        let newWindow = UIWindow()
        let windowScene = UIWindowScene(session: session, connectionOptions: options)
        newWindow.windowScene = windowScene
        externalWindow = newWindow

        //newWindow.layer.frame = newWindow.layer.frame.applying(CGAffineTransform.identity.rotated(by: rotation))

        let externalView = ExternalView()
        let hostingController = UIHostingController(rootView: externalView)
        hostingController.overrideUserInterfaceStyle = .dark
        newWindow.rootViewController = hostingController
        newWindow.isHidden = false
        externalVC = hostingController
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // is external display?
        if connectingSceneSession.configuration.role == UISceneSession.Role.windowExternalDisplay {
            setupExternalScreen(session: connectingSceneSession, options: options)
            isExternalScreenConnected = true
            return UISceneConfiguration(name: "External screen", sessionRole: .windowExternalDisplay)
        } else {
            // Called when a new scene session is being created.
            // Use this method to select a configuration to create the new scene with.
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        if sceneSessions.first?.role == UISceneSession.Role.windowApplication {
            idsAndImages.removeAll()
        }
    }


}

