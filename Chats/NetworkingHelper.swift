import UIKit

extension Net {
    static func dataTaskWithRequest(request: NSURLRequest, _ viewController: UIViewController, useLoadingView: Bool = false, loadingTitle: String = "Connecting", successCode: Int = 200, errorHandler: ((UIAlertAction) -> Void)? = nil, backgroundSuccessHandler: ((AnyObject?) -> Void)? = nil, mainSuccessHandler: (AnyObject?) -> Void) -> NSURLSessionDataTask {

        var loadingView: LoadingView? = nil
        if useLoadingView {
            loadingView = LoadingView()
            loadingView!.showInViewController(viewController)
        } else {
            let loadingViewController = LoadingViewController(title: loadingTitle)
            viewController.presentViewController(loadingViewController, animated: true, completion: nil)
        }

        let dataTask = API.dataTaskWithRequest(request) { JSONObject, statusCode, error in
            guard let error = error else {
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
                            viewController.alertError(JSONObject as! Dictionary<String, String>?, error: nil, handler: errorHandler)
                        }
                    }

                    if useLoadingView {
                        loadingView!.dismiss()
                        handleResponse()
                    } else {
                        viewController.dismissViewControllerAnimated(true, completion: {
                            handleResponse()
                        })
                    }
                }
                return
            }

            dispatch_async(dispatch_get_main_queue()) {
                if useLoadingView {
                    loadingView!.dismiss()
                    viewController.alertError(nil, error: error, handler: errorHandler)
                } else {
                    viewController.dismissViewControllerAnimated(true, completion: {
                        viewController.alertError(nil, error: error, handler: errorHandler)
                    })
                }
            }
        }
        return dataTask
    }
}
