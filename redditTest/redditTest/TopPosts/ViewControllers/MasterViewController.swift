//
//  MasterViewController.swift
//  redditTest
//
//  Created by Laureano De Andrea on 11/24/19.
//  Copyright © 2019 Laureano De Andrea. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, RedditProviderProtocol {

    
    @IBOutlet weak var loadingMoreIndicator: UIActivityIndicatorView!
    
    var detailViewController: DetailViewController? = nil
    var redditPosts = [TopResponseChildren]()
    var currentAfterHash = ""
    let repo = RedditProvider()
    var loadingAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureTopButtons()
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        repo.delegate = self
        configureLoadingAlert()
        configureRefreshControl()
        refreshPosts() 
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    func configureTopButtons() {

        let dismissAllButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(dismissAllPosts(_:)))
        navigationItem.rightBarButtonItem = dismissAllButton
    }
    
    @objc
    func dismissAllPosts(_ sender: Any) {
        redditPosts.removeAll()
        tableView.reloadData()
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
                redditPosts[indexPath.row].data.viewed = true
                self.tableView.reloadData()
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.post = redditPosts[indexPath.row].data
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    @IBAction func dismissPost(_ sender: Any) {
        if let btn = sender as? UIButton {
            redditPosts.remove(at: btn.tag)
            tableView.deleteRows(at: [IndexPath(row: btn.tag, section: 0)], with: .fade)
            refreshTags()
        }
    }
    
    func refreshTags() {
        var i = 0
        for cell in tableView.visibleCells  {
            var redditCell = cell as! RedditTableViewCell
            redditCell.dismissButton.tag = tableView.indexPath(for: cell)?.row ?? 0
        }
    }
    
    // MARK: - Table View
    
    func configureRefreshControl() {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        rc.tintColor = .orange
        self.tableView.refreshControl = rc
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return redditPosts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= redditPosts.count - 2 {
            loadingMoreIndicator.startAnimating()
            repo.getTopPosts(afterHash: currentAfterHash)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! RedditTableViewCell
        let post = redditPosts[indexPath.row]
        
        cell.viewedIcon!.isHidden = post.data.viewed ?? false
        cell.authorLabel!.text = post.data.author
        cell.titleLabel!.text = post.data.title
        cell.timAgoLabel!.text = Date(milliseconds: Int64(post.data.created_utc)).timeAgoDisplay()
        cell.dismissButton!.tag = indexPath.row
        cell.commentsCountLabel!.text = "\(post.data.num_comments) Comments"
        cell.post = post
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            redditPosts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    // MARK: Reddit Provider Protocol
    
    func didGetTopPostsSuccess(object: TopResponse) {
        if currentAfterHash.isEmpty {
            self.redditPosts = object.data.children
        } else {
            self.redditPosts.append(contentsOf: object.data.children)
        }
        
        currentAfterHash = object.data.after ?? ""
        
        DispatchQueue.main.async {
            self.loadingMoreIndicator.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.loadingAlert?.dismiss(animated: true, completion: nil)
        }
    }
    
    func didGetTopPostFailure(erorr: String) {
        print(erorr)
    }

}

