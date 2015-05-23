import UIKit

let account = Account()

let baseURL = NSURL(string: "http://localhost:5100")
//let baseURL = NSURL(string: "https://acanichats.herokuapp.com")

class Account: NSObject {
    var phone: String!
    dynamic var accessToken: String!
    var user: User!
    var users = [User]()
    var chats = [Chat]()

    func logOut() {
        phone = nil
        accessToken = nil
        user = nil
        users = []
        chats = []
    }

    func deleteAccount() -> NSURLSessionDataTask {
        let activityOverlayView = ActivityOverlayView.sharedView()
        activityOverlayView.showWithTitle("Deleting")

        let request = NSMutableURLRequest(URL: URLWithPath("/me"))
        request.HTTPMethod = "DELETE"
        request.setValue("Bearer "+accessToken, forHTTPHeaderField: "Authorization")
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let statusCode = (response as! NSHTTPURLResponse).statusCode

            dispatch_async(dispatch_get_main_queue(), {
                activityOverlayView.dismissAnimated(true)

                switch statusCode {
                case 200:
                    self.logOut()
                default:
                    let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as! Dictionary<String, String>?
                    UIAlertView(dictionary: dictionary, error: error, delegate: self).show()
                }
            })
        })
        dataTask.resume()
        return dataTask
    }
}
