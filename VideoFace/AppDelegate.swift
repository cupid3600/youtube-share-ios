//
//  AppDelegate.swift
//  videoface
//
//  Created by Marco Rossi on 18/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import UIKit

import Firebase

import RxSwift
import RxOptional
import Action

import Moya

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let videosUseCase = RealmUseCaseProvider().makeVideosUseCase() as! RealmVideosUseCase
    var videoUrl: String? = nil
    
    lazy var addVideoAction: Action<String, Void> = {
        Action<String, Void> { [unowned self] url in
            let video = Video(youtubeUrl: url)
            return Observable.just(video)
                .filterNil()
                .flatMap { video in self.videosUseCase.save(video: video).map { return video }}
                .flatMap { video in self.videosUseCase.sync(video: video) }
        }
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let sceneCoordinator = SceneCoordinator(window: window!)
        SceneCoordinator.shared = sceneCoordinator
        
        let viewModel = VideosViewModel(useCase: videosUseCase)
        sceneCoordinator.transition(to: Scene.videos(viewModel))
        
        
        FirebaseApp.configure()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let videoUrl = components.queryItems?.first(where: { $0.name == "videoURL" })?.value {
            self.videoUrl = videoUrl
            return true
        }
        
        return false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let videoUrl = self.videoUrl {
            //Dismiss popup (YouTube App Store page)
//            if SceneCoordinator.shared.currentViewController.presentingViewController != nil {
//                SceneCoordinator.shared.pop(animated: false)
//            }
            
            self.addVideoAction.execute(videoUrl)
            self.videoUrl = nil
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}
