import Foundation
import UIKit

class RSSTableViewController: UITableViewController {
    
    private var rssEntryies = [RSSEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: RSSEntryTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: RSSEntryTableViewCell.identifier)
        fetchData()
    }
    
    private func fetchData() {
        if let data = UserDefaults.standard.value(forKey:"rssEntryies") as? Data {
            if let entries = try? PropertyListDecoder().decode(Array<RSSEntry>.self, from: data) {
                rssEntryies = entries
            }
        }
        if rssEntryies.count == 0 {
        let feedParser = FeedParser()
            feedParser.parseFeed(urlString: "https://news.yam.md/ro/rss") { (entries) in
                self.rssEntryies = entries
                OperationQueue.main.addOperation { self.tableView.reloadSections(IndexSet(integer: 0), with: .left)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rssEntryies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RSSEntryTableViewCell.identifier, for: indexPath) as! RSSEntryTableViewCell
        cell.setUp(entry: rssEntryies[indexPath.item]) {
            self.rssEntryies.remove(at: indexPath.item)
            self.updateUserDefaults()
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.reloadData()
        }
        return cell
    }
    
    private func updateUserDefaults() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(rssEntryies), forKey:"rssEntryies")
    }
}
