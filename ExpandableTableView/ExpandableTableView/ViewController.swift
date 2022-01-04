import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

import UIKit

class DiscoverResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    private var items = [Any]()
    private var typeA = [TableViewItem]()
    private var typeB = [TableViewItem]()
    var infos = [Info]()

    override func viewDidLoad() {
        infos.append(Info.init(fakeIndex: 0))
        infos.append(Info.init(fakeIndex: 1))
        infos.append(Info.init(fakeIndex: 2))
        infos.append(Info.init(fakeIndex: 3))
        infos.append(Info.init(fakeIndex: 4))
        for info in infos {
            switch info.itemType {
            case 0:
                typeA.append(TableViewItem(info: info))
            case 1:
                typeB.append(TableViewItem(info: info))
            default:
                break
            }
        }
        
        if !typeA.isEmpty {
            items.append(ExpandableTableViewItem(category: 0, isExpanded: true))
            typeA[0].isExpanded = true
            items.append(contentsOf: typeA)
        }
        if !typeB.isEmpty {
            items.append(ExpandableTableViewItem(category: 1, isExpanded: items.isEmpty))
            if items.count == 1 {
                typeB[0].isExpanded = true
                items.append(contentsOf: typeB)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = items[indexPath.row] as? ExpandableTableViewItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandableTableViewCell", for: indexPath) as! ExpandableTableViewCell
            switch item.category {
            case 0:
                cell.title.text = "\("type A") (\(typeA.count))"
            case 1:
                cell.title.text = "\("type B") (\(typeB.count))"
            default:
                break
            }
            cell.toggle.image = item.isExpanded ? UIImage(systemName: "arrow.up") : UIImage(systemName: "arrow.down")
            if cell.responds(to: #selector(setter:UIView.preservesSuperviewLayoutMargins)) {
                cell.layoutMargins = .zero
                cell.preservesSuperviewLayoutMargins = false
            }
            return cell
        } else {
            let item = items[indexPath.row] as! TableViewItem
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
            cell.name.text = item.info.systemName
            cell.datail.text = item.info.ip
            cell.toggle.image = item.isExpanded ? UIImage(systemName: "arrow.up") : UIImage(systemName: "arrow.down")
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if var item = items[indexPath.row] as? ExpandableTableViewItem {
            item.isExpanded = !item.isExpanded
            items[indexPath.row] = item
            (tableView.cellForRow(at: indexPath) as? ExpandableTableViewCell)?.toggle.image = item.isExpanded ? UIImage(systemName: "arrow.up") : UIImage(systemName: "arrow.down")
            var devices: [TableViewItem]?
            switch item.category {
            case 0:
                devices = typeA
            case 1:
                devices = typeB
            default:
                break
            }
            if let devices = devices {
                if item.isExpanded {
                    items.insert(contentsOf: devices, at: indexPath.row + 1)
                    var indexPaths = [IndexPath]()
                    for row in indexPath.row + 1..<indexPath.row + 1 + devices.count {
                        indexPaths.append(IndexPath(row: row, section: 0))
                    }
                    tableView.insertRows(at: indexPaths, with: .top)
                } else {
                    items.removeSubrange(indexPath.row + 1..<indexPath.row + 1 + devices.count)
                    var indexPaths = [IndexPath]()
                    for row in indexPath.row + 1..<indexPath.row + 1 + devices.count {
                        indexPaths.append(IndexPath(row: row, section: 0))
                    }
                    tableView.deleteRows(at: indexPaths, with: .fade)
                }
            }
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            var item = items[indexPath.row] as! TableViewItem
            item.isExpanded = !item.isExpanded
            switch item.info.itemType {
            case 0:
                if let index = typeA.firstIndex(where: { $0.info == item.info }) {
                    typeA[index] = item
                }
            case 1:
                if let index = typeB.firstIndex(where: { $0.info == item.info }) {
                    typeB[index] = item
                }
            default:
                break
            }
            items[indexPath.row] = item
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let item = items[indexPath.row] as? TableViewItem, item.isExpanded {
            return 96
        }
        return 44
    }

    
    
    struct TableViewItem {
        var info: Info
        var isExpanded = false

        init(info: Info) {
            self.info = info
        }

        static func ==(lhs: TableViewItem, rhs: TableViewItem) -> Bool {
            return lhs.info == rhs.info
        }
    }

    struct ExpandableTableViewItem {
        let category: Int32
        var isExpanded: Bool

        init(category: Int32, isExpanded: Bool) {
            self.category = category
            self.isExpanded = isExpanded
        }
    }
}


import UIKit

struct Info: Equatable, Comparable, Hashable {
    
    var systemName: String?
    var ip: String?
    var itemType: Int
    
    init (fakeIndex : Int) {
        self.systemName = "Item\(fakeIndex)"
        self.ip = "detail\(fakeIndex)"
        self.itemType = (fakeIndex % 2)
    }

    static func <(lhs: Info, rhs: Info) -> Bool {
        return lhs.systemName ?? "" < rhs.systemName ?? ""
    }

    static func ==(lhs: Info, rhs: Info) -> Bool {
        return lhs.ip == rhs.ip
    }
}

class ExpandableTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel?
    @IBOutlet weak var toggle: UIImageView!
}

class ItemTableViewCell: TableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var datail: UILabel!
    @IBOutlet weak var toggle: UIImageView!
}


class TableViewCell: UITableViewCell {
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            alpha = 0.6
        } else {
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        }
    }
}
