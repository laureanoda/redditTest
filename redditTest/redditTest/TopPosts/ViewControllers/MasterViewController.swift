//
//  MasterViewController.swift
//  redditTest
//
//  Created by Laureano De Andrea on 11/24/19.
//  Copyright © 2019 Laureano De Andrea. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, RedditProviderProtocol {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    let repo = RedditProvider()
    var loadingAlert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        repo.delegate = self
        
        configureLoadingAlert()
        
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        self.tableView.refreshControl = rc
        
        refreshPosts() 
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    @objc
    func refreshPosts() {
        repo.getTopPosts()
        showLoading()
    }
    // MARK: - Loading
    
    func configureLoadingAlert() {
        loadingAlert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        loadingAlert!.view.addSubview(loadingIndicator)
    }
    
    func showLoading() {
        
        present(loadingAlert!, animated: true, completion: nil)
        
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let object = objects[indexPath.row] as? TopResponseChildren {
            cell.textLabel!.text = object.data.title
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    // MARK: Reddit Provider Protocol
    
    func didGetTopPostsSuccess(object: TopResponse) {
//        print(object)
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.objects = object.data.children
            self.tableView.reloadData()
            self.loadingAlert?.dismiss(animated: true, completion: nil)
        }
    }
    
    func didGetTopPostFailure(erorr: String) {
        print(erorr)
    }

}

