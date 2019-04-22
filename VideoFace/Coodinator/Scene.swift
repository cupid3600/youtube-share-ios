
import UIKit

import StoreKit
import Hero
import MaterialComponents.MDCAppBarNavigationController

/**
     Refers to a screen managed by a view controller.
     It can be a regular screen, or a modal dialog.
     It comprises a view controller and a view model.
 */

protocol TargetScene {
    var transition: SceneTransitionType { get }
}

enum Scene {
    case videos(VideosViewModel)
    case videoStats(VideoStatsViewModel)
    case alert(AlertViewModel)
    case youtubeStore(storeId: String)
}

extension Scene: TargetScene {
    var transition: SceneTransitionType {
        switch self {
        case let .videos(viewModel):
            var vc = VideosViewController.instantiateFromNib()
            let navVc = MDCAppBarNavigationController(rootViewController: vc)
            let appBarVc = navVc.appBarViewController(for: vc)
            appBarVc?.inferPreferredStatusBarStyle = false
            appBarVc?.preferredStatusBarStyle = .lightContent
            vc.bind(to: viewModel)
            return .root(navVc)
        case let .videoStats(viewModel):
            let storyboard = UIStoryboard(name: "Stats", bundle: nil)
            var vc = storyboard.instantiateViewController(withIdentifier :"VideoStatsViewController") as! VideoStatsViewController
//            var vc = VideoStatsViewController.instantiate()
            vc.bind(to: viewModel)
//            vc.hero.isEnabled = true
//            vc.hero.modalAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .uncover(direction: .down))
            return .push(vc)
        case let .alert(viewModel):
            var vc = AlertViewController(title: nil, message: nil, preferredStyle: .alert)
            vc.bind(to: viewModel)
            return .alert(vc)
        case .youtubeStore(let storeId):
            let storeViewController = AppStoreViewController(with: storeId)
            return .present(storeViewController)
        }
    }
}

