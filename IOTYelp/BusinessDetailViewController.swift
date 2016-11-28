//
//  BusinessDetailViewController.swift
//  IOTYelp
//
//  Created by Alla Bondarenko on 2016-11-23.
//  Copyright © 2016 Alla Bondarenko. All rights reserved.
//

import UIKit
import MapKit

class BusinessDetailViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var businessTitle: UILabel!
    @IBOutlet weak var businessCategories: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    
    var business: Business?
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        if let business = business {
            if let img_url = business.img_url {
                imageView.downloadedFrom(url: img_url)
            } else {
                imageView.image = UIImage(named: "defaultPhoto")
            }

//            navigationItem.title = business.name
            businessTitle.text = business.name
            businessCategories.text = business.categories
            
            if let phone = business.phone {
                phoneNumber.text = String("Phone: \(phone)")
            }
            if let distance = business.distance {
                distanceLabel.text = String("Distance: \(distance)") //edit to pretty
            }
            
            
            //set up mapView
            if let location = business.coordinates {
                let annotation = MKPointAnnotation()
                annotation.coordinate = business.coordinates.coordinate
                mapView.addAnnotation(annotation)
                centerMapOnLocation(location: location)
                mapView.showsUserLocation = true
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Delegate methods
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "reusablePin")
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
        view.pinTintColor = MKPinAnnotationView.redPinColor()
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        location?.mapItem(coordinate: (location?.coordinate)!).openInMaps(launchOptions: launchOptions)
    }

}

extension MKAnnotation {
    //  annotation callout opens this mapItem in Maps app
    func mapItem(coordinate: CLLocationCoordinate2D) -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        return mapItem
    }
}
