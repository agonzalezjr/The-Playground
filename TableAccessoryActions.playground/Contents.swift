//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

var str = "Hello, playground"

struct Album {
  let title: String
  let year: Int
  let tracks: [String]
}

let dstm = Album(title: "Dark Side of the Moon",
                 year: 1973,
                 tracks: ["Time", "Money", "Brain Damage", "Eclipse"])

let wywh = Album(title: "Wish You Were Here",
                 year: 1975,
                 tracks: ["Crazy Diamond", "Wish you were here"])

let disco = [dstm, wywh]

class MyTVC : UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return disco.count
  }

  override func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int) -> String? {
    return disco[section].title
  }

  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return disco[section].year.description
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return disco[section].tracks.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "MyTVCCell")
    cell.textLabel?.text = disco[indexPath.section].tracks[indexPath.row]
    cell.accessoryType = .detailButton
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("2 didSelectRowAt(path = \(indexPath)")
  }

//  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//    print("accessoryButtonTappedForRowWith(path = \(indexPath)")
//  }
}

let tvc = MyTVC(style: .grouped)
tvc.title = "Table with Sections"

// Showing it in the playground

let navController = UINavigationController(rootViewController: tvc)

// iPad Portrait
//let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))

// iPad Landscape
//let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1024, height: 1024))
let window = UIWindow()
window.rootViewController = navController
window.makeKeyAndVisible()

PlaygroundPage.current.liveView = window
PlaygroundPage.current.needsIndefiniteExecution = true
