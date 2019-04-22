
import UIKit
import RxSwift

protocol SceneCoordinatorType {
    init(window: UIWindow)
    
    @discardableResult func transition(to scene: TargetScene) -> Observable<Void>
    @discardableResult func pop(animated: Bool) -> Observable<Void>
}

