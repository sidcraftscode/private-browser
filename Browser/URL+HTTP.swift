import Foundation

extension URL {
    static func httpURL(withString string: String) -> URL? {
        let commonTLDs = ["com", "org", "net", "edu", "gov", "mil", "int", "eu", "co", "info", "biz"]
        
        // Check if the URL already contains a TLD
        func containsTLD(urlString: String) -> Bool {
            return commonTLDs.contains { tld in
                urlString.lowercased().hasSuffix(".\(tld)")
            }
        }
        
        let urlString: String
        
        if (string.starts(with: "http://") || string.starts(with: "https://")) {
            urlString = string
        } else if containsTLD(urlString: string) {
            urlString = "http://" + string
        } else {
            // If no TLD is found, search Google
            let searchQuery = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
            urlString = "https://www.google.com/search?q=" + searchQuery
        }
        
        return URL(string: urlString)
    }
}
