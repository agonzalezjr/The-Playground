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
                 tracks: ["Time", "Money", "Brain Damage"])

let wywh = Album(title: "Wish You Were Here",
                 year: 1975,
                 tracks: ["Crazy Diamond", "Wish you were here"])

let disco = [dstm, wywh]

class MyTVC : UITableViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return disco.count
  }

  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return disco[section].year.description
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return disco[section].title
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return disco[section].tracks.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "MyTVCCell")
    cell.textLabel?.text = disco[indexPath.section].tracks[indexPath.row]
    return cell
  }
}

let rvc = MyTVC()
rvc.title = "Table with Sections"

let navController = UINavigationController(rootViewController: rvc)
PlaygroundPage.current.liveView = navController.view

