//
//  ResultsTableViewController.swift
//  IOTYelp
//
//  Created by Alla Bondarenko on 2016-11-22.
//  Copyright © 2016 Alla Bondarenko. All rights reserved.
//

import UIKit
import CoreLocation

class ResultsTableViewController: UITableViewController, YelpAPIControllerProtocol, CLLocationManagerDelegate {
    
    var businesses = [Business]()
    var api: YelpAPIController!
    var categories = [Category]()
    var term = String()
    
    private lazy var locationManager : CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        return manager
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestYelp()
    }

    
    //MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (businesses.count == 0) {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            noDataLabel.text = "No data found"
            noDataLabel.textAlignment = .center
            noDataLabel.sizeToFit()
            
            tableView.backgroundView?.addSubview(noDataLabel)
            tableView.separatorStyle = .none
            
            return 0
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "YelpResultsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ResultsTableViewCell
        
        let business = businesses[indexPath.row]
        
        cell.nameLabel.text = business.name
        //add guard let and default image
        if let img_url = business.img_url {
            cell.photoImageView.downloadedFrom(url: img_url)
        } else {
            cell.photoImageView.image = UIImage(named: "defaultPhoto")
        }
        
        cell.categoryLabel.text = business.categories ?? ""
        cell.distanceLabel.text = business.distance?.appending(" away")
        
        return cell
    }
    
    
    func requestYelp() {
        api = YelpAPIController(delegate: self)
        
        var currentLocation: CLLocation
        
        if let location: CLLocation = locationManager.location {
            currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            print(currentLocation)
        } else {
            currentLocation = CLLocation(latitude: 45.72, longitude: -67.69)
        }

        api.getBusinessSearch(location: currentLocation, term: term, attributes: categories)
    }
    
    //MARK: Protocol Implementation
    func didRecieveYelpAPIResults(_ results: [[String: Any]]) {
        DispatchQueue.main.async(execute: {
            for case let result in results{
                if let newBusiness = Business(json: result) {
                    self.businesses.append(newBusiness)
                }
            }
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    func didRecieveYelpApiError(_ error: Error) {
        //handle
    }
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let businessDetailViewController = segue.destination as! BusinessDetailViewController
            
            if let selectedMealCell = sender as? ResultsTableViewCell {
                let indexPath = tableView.indexPath(for: selectedMealCell)!
                let selectedBusiness = businesses[indexPath.row]
                businessDetailViewController.business = selectedBusiness
            }
        }
    }
    
    
    @IBAction func openSettings(_ sender: UIBarButtonItem) {
        if let nextViewController = self.navigationController?.popViewController(animated: true) as? PreferencesViewController {
                nextViewController.categories.removeAll()
        } else {
            if let nextViewController = storyboard?.instantiateViewController(withIdentifier: "PreferencesViewController") as? PreferencesViewController {
                nextViewController.categories = self.categories
                present(nextViewController, animated: true, completion: nil)
            }
        }
    }
 
    
}



extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
