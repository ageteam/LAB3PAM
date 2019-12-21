import Foundation

struct RSSEntry: Codable {
    var title: String
    var link: String
    var updated: String
    var authorName: String
    var id: String
    var summary: String
}

class FeedParser: NSObject {
    private var rssEntryies = [RSSEntry]()
    private var currentElement = ""
    
    private var currentTitle = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    private var currentLink = "" {
        didSet {
            currentLink = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    private var currentUpdate = "" {
        didSet {
            currentUpdate = currentUpdate.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    private var currentAuthorName = "" {
        didSet {
            currentAuthorName = currentAuthorName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    private var currentId = "" {
        didSet {
            currentId = currentId.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    private var currentSummary = "" {
        didSet {
            currentSummary = currentSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private var complitionHandler: (([RSSEntry])->Void)?
    
    func parseFeed(urlString: String, _complitionHandler: @escaping (([RSSEntry])->Void)) {
        self.complitionHandler = _complitionHandler
        
        let request = URLRequest(url: URL(string: urlString)!)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }
}

extension FeedParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "entry" {
            currentId = ""
            currentLink = ""
            currentTitle = ""
            currentUpdate = ""
            currentAuthorName = ""
            currentSummary = ""
        }
        if currentElement == "link" {
            currentLink = attributeDict["href"]!
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
            case "title": currentTitle += string
            //case "link":
            case "updated": currentUpdate += string
            case "name": currentAuthorName += string
            case "id":  currentId += string
            case "summary": currentSummary += string
            default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "entry" {
            let rssEntry = RSSEntry(title: currentTitle, link: currentLink, updated: currentUpdate, authorName: currentAuthorName, id: currentId, summary: currentSummary)
            self.rssEntryies.append(rssEntry)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        self.complitionHandler?(rssEntryies)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
