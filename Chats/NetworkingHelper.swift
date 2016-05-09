import UIKit
import Alerts
import LoadingViews
import Networking

enum LoadingViewType : Int {
    case None
    case View
    case Controller
}

extension Net {
    static func dataTaskWithRequest(request: NSURLRequest, _ viewController: UIViewController, loadingViewType: LoadingViewType = .Controller, loadingTitle: String = "Connecting", successCode: Int = 200, errorHandler: ((UIAlertAction) -> Void)? = nil, backgroundSuccessHandler: ((AnyObject?) -> Void)? = nil, mainSuccessHandler: (AnyObject?) -> Void) -> NSURLSessionDataTask {

        var loadingView: LoadingView? = nil
        switch loadingViewType {
        case .View:
            loadingView = LoadingView()
            loadingView!.showInViewController(viewController)
        case .Controller:
            let loadingViewController = LoadingViewController(title: loadingTitle)
            viewController.presentViewController(loadingViewController, animated: true, completion: nil)
        default: break
        }

        let dataTask = API.dataTaskWithRequest(request) { JSONObject, statusCode, error in
            if let error = error {
                return dispatch_async(dispatch_get_main_queue()) {
                    let alertError = { viewController.alertError(error, handler: errorHandler) }
                    switch loadingViewType {
                    case .None:
                        alertError()
                    case .View:
                        loadingView!.dismiss()
                        alertError()
                    case .Controller:
                        viewController.dismissViewControllerAnimated(true, completion: alertError)
                    }
                }
            }

            if let backgroundSuccessHandler = backgroundSuccessHandler where statusCode == successCode {
                backgroundSuccessHandler(JSONObject)
            }

            dispatch_async(dispatch_get_main_queue()) {
                func handleResponse() {
                    switch statusCode! {
                    case successCode:
                        mainSuccessHandler(JSONObject)
                    case 401:
                        viewController.alert(title: "Session Expired", message: "Please log in again.") { _ in
                            account.reset()
                        }
                    default:
                        let dictionary = JSONObject as! Dictionary<String, String>
                        viewController.alert(title: dictionary["title"], message: dictionary["message"], handler: errorHandler)
                    }
                }

                switch loadingViewType {
                case .None:
                    handleResponse()
                case .View:
                    loadingView!.dismiss()
                    handleResponse()
                case .Controller:
                    viewController.dismissViewControllerAnimated(true, completion: {
                        handleResponse()
                    })
                }
            }
        }
        return dataTask
    }
}
