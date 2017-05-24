//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

var str = "Hello, playground"

struct Album {
  let title: String?
  let year: Int?
  let tracks: [String]
}

let dstm = Album(title: "Dark Side of the Moon",
                 year: 1974,
                 tracks: ["Time", "Money", "Brain Damage"])

let wywh = Album(title: "Wish You Were Here",
                 year: 1975,
                 tracks: ["Crazy Diamond", "Wish you were here"])

let tw = Album(title: nil, //"The Wall",
                 year: 1978,
                 tracks: ["Comfortably Numb"])

let disco = [dstm, wywh, tw]

class MyTVC : UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    print(">>> style: " + String(self.tableView.style.rawValue))

//    self.tableView.sectionHeaderHeight = 50
//    self.tableView.sectionFooterHeight = 50

//    self.tableView.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
    self.tableView.sectionFooterHeight = CGFloat.leastNonzeroMagnitude

//    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension 
//    self.tableView.sectionFooterHeight = UITableViewAutomaticDimension
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return disco.count
  }

//  override func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int) -> String? {
//    return disco[section].title
//  }

//  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    print(">>> getting header for section \(section)")
//    if let title = disco[section].title {
//      let view = UILabel()
//      view.backgroundColor = .blue
//      view.text = title
//      return view
//    }
//    return nil
//  }

//  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//    if let year = disco[section].year {
//      return year.description
//    }
//    return nil
//  }

//  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//    print(">>> getting footer for section \(section)")
//    if let year = disco[section].year {
//      let view = UILabel()
//      view.backgroundColor = .red
//      view.text = year.description
//      return view
//    }
//    return nil
//  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return disco[section].tracks.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "MyTVCCell")
    cell.textLabel?.text = disco[indexPath.section].tracks[indexPath.row]
    return cell
  }
}

let rvc = MyTVC(style: .grouped)
rvc.title = "Table with Sections"

let navController = UINavigationController(rootViewController: rvc)

let t1 = UIBarButtonItem(title: "foo", style: .plain, target: nil, action: nil)

let t2 = UIBarButtonItem(title: "bar", style: .plain, target: nil, action: nil)

rvc.toolbarItems = [t1, t2]
navController.isToolbarHidden = false

let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
window.rootViewController = navController
window.makeKeyAndVisible()

PlaygroundPage.current.liveView = window
PlaygroundPage.current.needsIndefiniteExecution = true

