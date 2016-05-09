import UIKit
import Networking

let account = Account()
//var api = API(baseURL: NSURL(string: "https://localhost:5100")!)            // development
//var api = API(baseURL: NSURL(string: "https://localhost:5200")!)            // test
var api = API(baseURL: NSURL(string: "https://acani-chats.herokuapp.com")!) // production

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        if let accessToken = account.accessToken {
            if accessToken == "guest_access_token" {
                account.accessToken = nil
            } else {
                account.setUserWithAccessToken(accessToken, firstName: "", lastName: "")
            }
        }
        account.addObserver(self, forKeyPath: "accessToken", options: NSKeyValueObservingOptions(rawValue: 0), context: nil) // always
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.backgroundColor = .whiteColor()
        updateRootViewController()
//        account.continueAsGuest() // test
//        window!.rootViewController = UINavigationController(rootViewController: SearchViewController()) // test
//        window!.rootViewController = UINavigationController(rootViewController: EnterCodeViewController(method: .Signup, email: "test@example.com")) // test
        window!.makeKeyAndVisible()

        return true
    }

    // MARK: - NSKeyValueObserving

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        updateRootViewController()
    }

    func updateRootViewController() {
        if let enterCodeViewController = window!.rootViewController?.presentedViewController {
            enterCodeViewController.view.viewWithTag(17)?.resignFirstResponder()
        }

        if account.accessToken == nil {
            window!.rootViewController = WelcomeViewController(nibName: nil, bundle: nil)
        } else {
            let tabBarController = createTabBarController()
            window!.rootViewController = tabBarController
            if account.accessToken == "guest_access_token" { return }
            account.getMe(tabBarController.selectedViewController!)
        }
    }

    // MARK: - Helpers

    func createTabBarController() -> UITabBarController {
        let usersCollectionViewController = UsersCollectionViewController()
        usersCollectionViewController.tabBarItem.image = UIImage(named: "Users")
        let usersNavigationController = UINavigationController(rootViewController: usersCollectionViewController)

        let searchViewController = SearchViewController()
        searchViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .Search, tag: 1)
        let searchNavigationController = UINavigationController(rootViewController: searchViewController)

        let chatsTableViewController = ChatsTableViewController()
        chatsTableViewController.tabBarItem.image = UIImage(named: "Chats")
        let chatsNavigationController = UINavigationController(rootViewController: chatsTableViewController)

        let profileTableViewController = ProfileTableViewController(user: account.user)
        profileTableViewController.tabBarItem.image = UIImage(named: "Profile")
        let profileNavigationController = UINavigationController(rootViewController: profileTableViewController)

        let settingsTableViewController = SettingsTableViewController()
        settingsTableViewController.tabBarItem.image = UIImage(named: "Settings")
        let settingsNavigationController = UINavigationController(rootViewController: settingsTableViewController)

        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        tabBarController.viewControllers = [usersNavigationController, searchNavigationController, chatsNavigationController, profileNavigationController, settingsNavigationController]
        return tabBarController
    }
}
