import UIKit

class RSSEntryTableViewCell: UITableViewCell {
    static public var identifier = "RSSEntryTableViewCell"
    
    private var rssEntry: RSSEntry?
    private var deletionHandler: (()->Void)?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var authorNameLbl: UILabel!
    @IBOutlet weak var updateLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var summaryLbl: UILabel!
    
    public func setUp(entry: RSSEntry, _deleteHandler: @escaping ()->Void) {
        rssEntry = entry
        deletionHandler = _deleteHandler
        bindModelToView()
    }
    
    @IBAction private func deleteAction(_ sender: Any) {
        deletionHandler?()
    }
    
    @IBAction private func openLinkAction(_ sender: Any) {
        guard let url = URL(string: rssEntry?.link ?? "") else { return }
        UIApplication.shared.open(url)
    }
    
    private func bindModelToView() {
        guard let entry = rssEntry else { return }
        titleLbl.text = entry.title
        authorNameLbl.text = entry.authorName
        idLbl.text = entry.id
        updateLbl.text = entry.updated
        summaryLbl.text = entry.summary
    }
}
