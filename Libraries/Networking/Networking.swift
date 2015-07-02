import UIKit

class API {
    let baseURL: NSURL?

    init(baseURL: NSURL?) {
        self.baseURL = baseURL
    }

    func URLWithPath(path: String) -> NSURL {
        return NSURL(string: path, relativeToURL: baseURL)!
    }

    func formRequest(HTTPMethod: String, _ path: String, _ fields: Dictionary<String, String>) -> NSMutableURLRequest {
        return Web.formRequest(HTTPMethod, URLWithPath(path), fields)
    }

    func multipartRequest(HTTPMethod: String, _ path: String, _ boundary: String) -> NSMutableURLRequest {
        return Web.multipartRequest(HTTPMethod, URLWithPath(path), boundary)
    }
}

class Web {
    class func formRequest(HTTPMethod: String, _ URL: NSURL, _ fields: Dictionary<String, String>) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = HTTPMethod
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = formHTTPBodyFromFields(fields)
        return request
    }

    class func multipartBoundary() -> String {
        return "-----AcaniFormBoundary" + randomStringWithLength(16)
    }

    class func multipartRequest(HTTPMethod: String, _ URL: NSURL, _ boundary: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = HTTPMethod
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        return request
    }

    class func multipartData(boundary: String, _ fields: Dictionary<String, String>, _ data: NSData) -> NSData {
        let hh = "--", rn = "\r\n"
        func contentDisposition(name: String) -> String {
            return "Content-Disposition: form-data; name=\"\(name)\""
        }

        // Add fields
        var bodyString = ""
        for (name, value) in fields {
            bodyString += hh + boundary + rn
            bodyString += contentDisposition(name) + rn + rn
            bodyString += value + rn
        }

        // Add data
        bodyString += hh + boundary + rn
        bodyString += contentDisposition("file") + "; filename=\"p.jpg\"" + rn
        bodyString += "Content-Type: image/jpeg" + rn + rn
        var body = NSMutableData(data: bodyString.dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(data)

        // Complete
        bodyString = rn + hh + boundary + hh + rn
        body.appendData(bodyString.dataUsingEncoding(NSUTF8StringEncoding)!)

        return body
    }

    // Convert ["name1": "value1", "name2": "value2"] to "name1=value1&name2=value2".
    // NOTE: Like curl, let front-end developers URL encode names & values.
    private class func formHTTPBodyFromFields(fields: Dictionary<String, String>) -> NSData? {
        var bodyString = [String]()
        for (name, value) in fields {
            bodyString.append("\(name)=\(value)")
        }
        return join("&", bodyString).dataUsingEncoding(NSUTF8StringEncoding)
    }

    private class func randomStringWithLength(length: Int) -> String {
        let alphabet = "-_1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map { _ -> Character in
            return alphabet[advance(alphabet.startIndex, Int(arc4random_uniform(64)))]
        })
    }
}

extension String {
    // Percent encode all characters except alphanumerics, "*", "-", ".", and "_". Replace " " with "+".
    // http://www.w3.org/TR/html5/forms.html#application/x-www-form-urlencoded-encoding-algorithm
    func stringByAddingFormURLEncoding() -> String {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("*-._ ")
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!.stringByReplacingOccurrencesOfString(" ", withString: "+")
    }
}

extension UIAlertView {
    convenience init(dictionary: Dictionary<String, String>?, error: NSError!, delegate: AnyObject?) {
        let title = dictionary?["title"] ?? ""
        let message = dictionary?["message"] ?? (error != nil ? error.localizedDescription : "Could not connect to server.")
        self.init(title: title, message: message, delegate: delegate, cancelButtonTitle: "OK")
    }
}
