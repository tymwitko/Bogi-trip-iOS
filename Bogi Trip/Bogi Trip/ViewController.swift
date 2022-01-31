//
//  ViewController.swift
//  Bogi Trip
//
//  Created by Tymon Kobylecki on 28/12/2021.
//  Copyright © 2021 Tymon Kobylecki. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController{
    
    var theModel = RandomSelectionModel()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rangeMinField: UITextField!
    @IBOutlet weak var rangeMaxField: UITextField!
    @IBOutlet weak var instructionsLabel: UILabel!
    private let locationManager = CLLocationManager()
    private var currentCoords: CLLocationCoordinate2D?
    private var destinations: [MKPointAnnotation] = []
    private var currentRoute: MKRoute?
    private var rangeMini: Double?
    private var rangeMaxi: Double?
    private var minCircle: MKCircle?
    private var maxCircle: MKCircle?
    private var dirCircle: MKCircle?
    private var drawCircleMini = false
    private var drawCircleMaxi = false
    private var drawRoute = false
    private var minEdited = false
    private var maxEdited = false
    private var minCircles: [MKCircle] = []
    private var maxCircles: [MKCircle] = []
    private var steps: [MKRoute.Step] = []
    private var randCoords = CLLocationCoordinate2D()
    private var stepCounter = 1
    @IBAction func changedMin(){
        rangeMini = NSString(string: rangeMinField.text!).doubleValue
        if rangeMini != nil{
            self.mapView.removeOverlays(minCircles)
            drawCircleMini = true
            drawCircleMaxi = false
            drawRoute = false
            minOverlay()
            minEdited = true
        }
    }
    @IBAction func changedMax(){
        rangeMaxi = NSString(string: rangeMaxField.text!).doubleValue
        if rangeMaxi != nil{
            self.mapView.removeOverlays(maxCircles)
            drawCircleMaxi = true
            drawCircleMini = false
            drawRoute = false
            maxOverlay()
            maxEdited = true
        }
    }
    @IBAction func pressRefresh(){
        drawRoute = true
        drawCircleMini = false
        drawCircleMaxi = false
        if currentCoords == nil{
            popup(title: "Location missing", text: "Location not found. Please give the app access to your location and try again.")
        }else if instructionsLabel.isHidden{
            popup(title: "Destination missing", text: "You need to have a destination before recalculating the route.")
        }else{
            self.randCoords.longitude = theModel.coordLong
            self.randCoords.latitude = theModel.coordLat
            addAnnotations(coordinate: self.randCoords)
        }
    }
    @IBAction func pressRandom(){
        drawRoute = true
        drawCircleMini = false
        drawCircleMaxi = false
        if currentCoords == nil{
            popup(title: "Location missing", text: "Location not found. Please give the app access to your location and try again")
        }else if rangeMini == nil || rangeMaxi == nil{
            popup(title: "Parameter missing", text: "Please enter the minimum and maximum range and try again.")
        }else if (rangeMaxi?.isLess(than: rangeMini!))!{
            popup(title: "Incorrect parameters", text: "The minimum range cannot be greater than the maximum range!")
        }else{
            theModel.getRandomLocation(location: currentCoords!, rangeMini: rangeMini!, rangeMaxi: rangeMaxi!)
            self.randCoords.longitude = theModel.coordLong
            self.randCoords.latitude = theModel.coordLat
            addAnnotations(coordinate: self.randCoords)
            instructionsLabel.isHidden = false
        }
    }
    @IBAction func pressLocation(){
        if currentCoords == nil{
            popup(title: "Location missing", text: "Location not found. Please give the app access to your location and try again")
        }else{
            zoomToLastLocation(with: currentCoords!)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        instructionsLabel.numberOfLines = 0
        instructionsLabel.lineBreakMode = .byWordWrapping
        instructionsLabel.isHidden=true
        beginLocationUpdates(locationManager: locationManager)
    }
    private func popup(title: String, text: String){
        beginLocationUpdates(locationManager: locationManager)
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(ACTION :UIAlertAction!) in []}))
        self.present(alert, animated: true, completion: nil)
    }
    private func beginLocationUpdates(locationManager: CLLocationManager){
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    private func zoomToLastLocation(with coordinate: CLLocationCoordinate2D){
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    private func addAnnotations(coordinate: CLLocationCoordinate2D){
        let randomAnnotation = MKPointAnnotation()
        randomAnnotation.title = "Random point"
        randomAnnotation.coordinate = coordinate
        if destinations.count > 0{
            mapView.removeAnnotation(destinations[0]) //clearing earlier destination
        }
        destinations.removeAll() //stops?
        destinations.append(randomAnnotation)
        mapView.addAnnotation(randomAnnotation)
        constructRoute(userLocation: mapView.userLocation.coordinate)
    }
    private func constructRoute(userLocation: CLLocationCoordinate2D){
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinations[0].coordinate))
        directionsRequest.requestsAlternateRoutes = true
        directionsRequest.transportType = .automobile
        let directions = MKDirections(request: directionsRequest)
        directions.calculate{[weak self](directionsResponse, error) in
            guard let self = self else {return}
            if let error = error{
                print(error.localizedDescription)
            }else if let response = directionsResponse, response.routes.count > 0 {
                self.mapView.removeOverlays(self.mapView.overlays)
                self.currentRoute = response.routes[0]
                self.mapView.addOverlay(response.routes[0].polyline)
                self.locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
                self.steps = self.currentRoute!.steps
                self.drawRoute = false
                for i in 0..<self.steps.count{
                    let step = self.steps[i]
                    let region = CLCircularRegion(center: step.polyline.coordinate, radius: 10, identifier: "\(i)")
                    self.locationManager.startMonitoring(for: region)
                    self.dirCircle = MKCircle(center: step.polyline.coordinate, radius: 20)
                    self.mapView.addOverlay(self.dirCircle!)
                }
                self.instructionsLabel.text = "In \(self.steps[1].distance) meters \(self.steps[1].instructions)"
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let location = locations.first
            else {return}
        if currentCoords == nil{
            zoomToLastLocation(with: location.coordinate)
        }
        currentCoords = location.coordinate
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus, didUpdateLocations locations: [CLLocation]){
        if status == .authorizedWhenInUse || status == .authorizedAlways{
            beginLocationUpdates(locationManager: manager)
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        stepCounter += 1
        if stepCounter < steps.count{
            let currStep = steps[stepCounter]
            instructionsLabel.text = "In \(currStep.distance) meters \(currStep.instructions)"
            self.drawRoute = true
            constructRoute(userLocation: mapView.userLocation.coordinate)
        }
    }
}

extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) ->MKOverlayRenderer {
        if drawRoute{
            guard let currentRoute = currentRoute else {
                return MKOverlayRenderer()
            }
            let polyLineRenderer = MKPolylineRenderer(polyline: currentRoute.polyline)
            polyLineRenderer.strokeColor = UIColor.green
            return polyLineRenderer
        }else if drawCircleMini{
            minCircle = MKCircle(center: mapView.userLocation.coordinate, radius: rangeMini!*1000)
            minCircles.append(minCircle!)
            let circleRenderer = MKCircleRenderer(circle: minCircle!)
            circleRenderer.strokeColor = UIColor.red
            return circleRenderer
        }else if drawCircleMaxi{
            maxCircle = MKCircle(center: mapView.userLocation.coordinate, radius: rangeMaxi!*1000)
            maxCircles.append(maxCircle!)
            let circleRenderer = MKCircleRenderer(circle: maxCircle!)
            circleRenderer.strokeColor = UIColor.purple
            return circleRenderer
        }else{
            let circleRenderer = MKCircleRenderer(circle: dirCircle!)
            circleRenderer.strokeColor = UIColor.black
            circleRenderer.lineWidth = 1
            circleRenderer.fillColor = UIColor.white
            return circleRenderer
        }
    }
    func minOverlay(){
        if minCircle == nil{
            minCircle = MKCircle(center: mapView.userLocation.coordinate, radius: rangeMini!*1000)
        }
        minCircles.append(minCircle!)
        self.mapView.addOverlay(minCircle!)
    }
    func maxOverlay(){
        if maxCircle == nil{
            maxCircle = MKCircle(center: mapView.userLocation.coordinate, radius: rangeMaxi!*1000)
        }
        maxCircles.append(maxCircle!)
        self.mapView.addOverlay(maxCircle!)
    }
}
