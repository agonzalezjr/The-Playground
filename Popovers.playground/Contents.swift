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

class MyTVC : UITableViewController, UIPopoverPresentationControllerDelegate {

  var actionButton: UIBarButtonItem?
  var toolButton: UIBarButtonItem?

  var actionSheetButton: UIBarButtonItem?

  override func viewDidLoad() {
    super.viewDidLoad()

    actionButton = UIBarButtonItem(title: "Pop!", style: .plain, target: self, action: #selector(MyTVC.pop))
    self.navigationItem.rightBarButtonItem = actionButton

    actionSheetButton = UIBarButtonItem(title: "Sheet!", style: .plain, target: self, action: #selector(MyTVC.menu))
    self.navigationItem.leftBarButtonItem = actionSheetButton

    toolButton = UIBarButtonItem(title: "Pop!", style: .plain, target: self, action: #selector(MyTVC.pop))
    self.toolbarItems = [toolButton!]
    self.navigationController?.isToolbarHidden = false
  }


  @objc
  func menu(sender: UIView) {
    print("sheet sent by \(sender)")

    let alertController = UIAlertController(title: "Alert", message: "Message", preferredStyle: .actionSheet)

    let action = UIAlertAction(title: "Action",
                               style: .`default`,
                               handler: { _ in
      print("Action in sheet tapped")
    })
    alertController.addAction(action)

    self.present(alertController, animated: true, completion: {
      print("In present's completion block")
    })

    if let popController = alertController.popoverPresentationController {
      popController.permittedArrowDirections = .any;
      popController.barButtonItem = actionSheetButton
//      popController.delegate = self;
    }
  }

  func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    print("Popover was dismissed")
  }

  @objc
  func pop(sender: UIView) {

    print("popper sent by \(sender)")

    let rvc = MyTVC(style: .grouped)
    rvc.title = "In Popover"

    let controller = UINavigationController(rootViewController: rvc)

    controller.navigationBar.barTintColor = .red

    // present the controller
    // on iPad, this will be a Popover
    // on iPhone, this will be an action sheet
    controller.modalPresentationStyle = .popover;
    self.present(controller, animated: true)

    // configure the Popover presentation controller
    if let popController = controller.popoverPresentationController {
      popController.permittedArrowDirections = .any;
      popController.barButtonItem = actionButton
      popController.backgroundColor = controller.navigationBar.barTintColor
//    popController.delegate = self;
    }
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
    return cell
  }
}

let rvc = MyTVC(style: .grouped)
rvc.title = "Table with Sections"

let navController = UINavigationController(rootViewController: rvc)
navController.navigationBar.barTintColor = .yellow
PlaygroundPage.current.liveView = navController.view

