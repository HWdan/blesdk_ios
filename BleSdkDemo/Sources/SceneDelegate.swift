import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let home = HomeViewController()
        let nav = UINavigationController(rootViewController: home)
        nav.navigationBar.prefersLargeTitles = false
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window
    }
}
