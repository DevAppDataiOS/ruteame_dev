//
//  MainViewController.swift
//  Ruteame
//
//  Created by Héctor Cuevas Morfín on 5/13/16.
//  Copyright © 2016 Roberto Avalos. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMobileAds


class MainViewController: UIViewController,CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var rouderView: UIView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var listBuses: UIView!
    @IBOutlet weak var listBusesConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var busName: UILabel!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let busData = BusData()
    let locationManager = CLLocationManager()
    var polylinesDictionary = NSMutableDictionary()
    var marker = GMSMarker()
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    var fetchedAddressLongitude: Double!
    var fetchedAddressLatitude: Double!
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    var fetchedFormattedAddress: String!
    override func viewDidLoad() {
        super.viewDidLoad()
          self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "[z] Arista", size: 22)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        topImageView.layer.cornerRadius = topImageView.frame.size.width/2;
        let gesture = UITapGestureRecognizer(target:  self, action: #selector(MainViewController.moveView))
        gesture.numberOfTapsRequired = 1
        self.titleView.addGestureRecognizer(gesture)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.handlePanGesture(_:)))
        self.titleView.addGestureRecognizer(panGestureRecognizer)
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(19.244572, longitude: -103.725520, zoom: 13)
        mapView.camera = camera
        mapView.camera = camera
        mapView.myLocationEnabled = true
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsetsMake(0, 0, 100, 0)
        bannerView.adUnitID = "ca-app-pub-2527087462892904/6379466872"
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        bannerView.backgroundColor = titleView.backgroundColor
        //viewMap.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        self .showAllRoutesAndFillDictionaries()
        for cells in 1...busData.data.count{
            let indexPath: NSIndexPath = NSIndexPath(forRow: cells-1, inSection: 0)
            
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        moveView()
        tableView.setContentOffset(CGPointZero, animated: true)
        if (!Reachability.isConnectedToNetwork()){
            bannerView .translatesAutoresizingMaskIntoConstraints = true;
            bannerView.frame = CGRectMake(0, self.view.frame.height, bannerView.frame.width, bannerView.frame.height);
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busData.data.count
        
    }
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCell {
        let item = busData.data[indexPath.row]["busName"] as! String
        let image = busData.data[indexPath.row]["geoJsonName"] as! String
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
        let imageView = cell.viewWithTag(20) as! UIImageView
        let titleName = cell.viewWithTag(30) as! UILabel
        imageView.image = UIImage(named: "identifier-" + image)
        titleName.text = item;
        cell.accessoryType = .None;
        cell.selectionStyle = .None
        if(cell.selected)
        {
            cell.accessoryType = .Checkmark;
        }
       //cell.configurateForBuses(item, imageName: image)
        return cell
    }
    
    func moveView(){
        listBuses .updateConstraintsIfNeeded()
        listBuses .layoutIfNeeded()
        let constante = listBusesConstraint.constant
        let actual = -(listBuses.frame.height-51.0)
        
        if(constante == actual){
            UIView .animateWithDuration(0.5) {
                self.listBusesConstraint.constant = -4
                 self.listBuses .layoutIfNeeded()
            }
        }
        else
        {
            UIView .animateWithDuration(0.5) {
                self.listBusesConstraint.constant = -(self.listBuses.frame.height-51);
                self.listBuses .layoutIfNeeded()
            }
        }
    }
    func showAllRoutesAndFillDictionaries(){
        
        for index in 1...(busData.data.count - 1){
            
            guard let busName = busData.data[index]["busName"] as? String else {
                return
            }
            
            if let filePath = NSBundle.mainBundle().pathForResource(busData.data[index]["geoJsonName"] as? String, ofType:"geojson") {
                
                if let jsonData = NSData(contentsOfFile:filePath){
                    
                    do{
                        let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as! NSDictionary
                        let features: NSArray = json.valueForKey("features") as! NSArray
                        let geometry: NSDictionary = features[0].valueForKey("geometry") as! NSDictionary
                        let coordinates: NSArray = geometry.valueForKey("coordinates") as! NSArray
                        busData.data[index]["coords"] = coordinates
                        let path = GMSMutablePath()
                        for coords in coordinates{
                            let lon = coords[1].doubleValue
                            let lat = coords[0].doubleValue
                            path.addCoordinate(CLLocationCoordinate2DMake(lon,lat))
                            
                        }
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeColor = busData.data[index]["color"] as! UIColor
                        polyline.strokeWidth = 2.0
                        polyline.title = busName
                        polyline.tappable = true
                        polyline.geodesic = true
                        
                        polylinesDictionary.setObject(polyline, forKey: busName)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            polyline.map = self.mapView
                        }
                    }catch{
                        
                    }
                }
            }
        }
    }
    
    @IBAction func startSearching(sender: UIBarButtonItem) {
        
        
        if viewSearch.hidden {
            if (Reachability.isConnectedToNetwork()){
                //textAddress.userInteractionEnabled = true
            }else{
                let alert = UIAlertView()
                alert.title = "No hay conexión a internet"
                alert.message = "Para poder buscar una dirección se necesita estar conectado a internet"
                alert.addButtonWithTitle("Aceptar")
                alert.show()
               // textAddress.userInteractionEnabled = false
            }
            
            viewSearch.hidden = false
            searchTextField.becomeFirstResponder()
            
        }else{
            searchTextField.text = ""
            searchTextField .resignFirstResponder()
            viewSearch.hidden = true
        }
    }
    func printRoutes(){
        for (_, polylines) in polylinesDictionary {
            
            let poly = polylines as! GMSPolyline
            dispatch_async(dispatch_get_main_queue()) {
                poly.strokeWidth = 2.0
                poly.map = self.mapView
            }
        }
        
    }
    //TableView Delegates
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        for (_, polylines) in polylinesDictionary {
            
            let poly = polylines as! GMSPolyline
            
            dispatch_async(dispatch_get_main_queue()) {
                poly.strokeWidth = 2.0
            }
        }
        guard let name = busData.data[indexPath.row]["busName"] as? String else {
            return
        }
        
        guard let imageName = busData.data[indexPath.row]["geoJsonName"] as? String else{
            return
        }
        
        if (name == "Todas"){
            printRoutes()
            topImageView.image = UIImage(named: "todas")
            busName.text = "Todas"
            for cells in 1...busData.data.count{
                let indexPath: NSIndexPath = NSIndexPath(forRow: cells-1, inSection: 0)
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark;
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
            }
            
            let indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
        }else{
            busName.text = name
            printJustOneRoute(name)
            topImageView.image = UIImage(named: imageName)
           // [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark;
            let southeastArray: NSArray = busData.data[indexPath.row]["southeast"] as! NSArray
            let northeasteastArray: NSArray = busData.data[indexPath.row]["northeast"] as! NSArray
            let southEastLat = southeastArray[0] as! Double
            let southEastLon = southeastArray[1] as! Double
            let northEastLat = northeasteastArray[0] as! Double
            let northEastLon = northeasteastArray[1] as! Double
            let southeast = CLLocationCoordinate2DMake(southEastLat, southEastLon)
            let northeast = CLLocationCoordinate2DMake(northEastLat, northEastLon)
            let bounds = GMSCoordinateBounds(coordinate: southeast, coordinate: northeast)
            let update = GMSCameraUpdate.fitBounds(bounds, withPadding: 20.0)
            self.mapView.moveCamera(update)
        }
        
        //animateBottomPanel(false)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        for (_, polylines) in polylinesDictionary {
            
            let poly = polylines as! GMSPolyline
            
            dispatch_async(dispatch_get_main_queue()) {
                poly.strokeWidth = 2.0
            }
        }
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        
        guard let name = busData.data[indexPath.row]["busName"] as? String else {
            return
        }
        
        busName.text = "Rutas"
        
        if (name == "Todas"){
            self.mapView.clear()
            topImageView.image = UIImage(named: "blanco")
            for cells in 1...busData.data.count{
                let indexPath: NSIndexPath = NSIndexPath(forRow: cells-1, inSection: 0)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                 tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None;
            }
            
        }else{
            let indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            deleteRoute(name)
        }
    }
 
    func deleteRoute(name: String){
        let polyline: GMSPolyline = polylinesDictionary.objectForKey(name) as! GMSPolyline
        polyline.map = nil
    }
    func printJustOneRoute(busName: String){
        print(busName)
        let polyline = polylinesDictionary.objectForKey(busName) as! GMSPolyline
        polyline.map = self.mapView
        
    }
 
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        let panned = recognizer.translationInView(view)
        print(panned)
         if !(listBuses.frame.origin.y < self.view.frame.size.height/2)
         {
            switch recognizer.state {
            case .Changed:
                listBuses .updateConstraintsIfNeeded()
                
                listBuses.center.y = listBuses.center.y  + recognizer.translationInView(self.view).y
                recognizer.setTranslation(CGPointZero, inView: view)
                
            case .Ended:
               // print(panned)
                moveView()
            //tableView.frame = CGRectMake(0, 81, self.viewListBuses.frame.size.width, self.view.frame.size.height/2 - 74)
            default:
                break
            }
        }
         else{
           // moveView()
            if(panned.y > 0)  {
                
                listBuses.center.y = listBuses.center.y  + recognizer.translationInView(self.view).y
                recognizer.setTranslation(CGPointZero, inView: view)
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        //textAddress.resignFirstResponder()
        sendAddressToGeocode()
        return true
    }
    
    func sendAddressToGeocode(){
        if searchTextField.text != ""{
            self.marker.map = nil
            let address = searchTextField.text!
            
            
            geocodeAddress(address + ", Colima", withCompletionHandler: { (status, success) -> Void in
                if !success {
                    if status == "ZERO_RESULTS" {
                        self.showAlertWithMessage("Dirección no encontrada.")
                    }
                    self.showAlertWithMessage("Dirección no encontrada.")
                }
                else {
                    let coordinate = CLLocationCoordinate2D(latitude: self.fetchedAddressLatitude, longitude: self.fetchedAddressLongitude)
                    let  position = CLLocationCoordinate2DMake(self.fetchedAddressLatitude, self.fetchedAddressLongitude)
                    self.marker = GMSMarker(position: position)
                    self.marker.icon = UIImage(named: "marker")
                    self.marker.title = address + ", Colima"
                    self.marker.map = self.mapView
                   // self.dismissKeyboard()
                    self.view .endEditing(true)
                    self.mapView.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 14.0)
                }
            })
        }else{
            let alert = UIAlertView()
            alert.title = "Campo vacio"
            alert.message = "Ingresa alguna dirección"
            alert.addButtonWithTitle("Aceptar")
            alert.show()
            
        }
    }
    
    func geocodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void)) {
        if let lookupAddress = address {
            var geocodeURLString = baseURLGeocode + "address=" + lookupAddress
            geocodeURLString = geocodeURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            let geocodeURL = NSURL(string: geocodeURLString)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)
                
                do{
                    let dictionary: Dictionary<NSObject, AnyObject> = try NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: .MutableContainers) as! Dictionary<NSObject, AnyObject>
                    
                    // Get the response status.
                    let status = dictionary["status"] as! String
                    
                    if status == "OK" {
                        let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                        self.lookupAddressResults = allResults[0]
                        
                        // Keep the most important values.
                        self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
                        let geometry = self.lookupAddressResults["geometry"] as! Dictionary<NSObject, AnyObject>
                        self.fetchedAddressLongitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
                        self.fetchedAddressLatitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
                        
                        completionHandler(status: status, success: true)
                    }
                    else {
                        completionHandler(status: status, success: false)
                    }
                    
                }catch{
                    print(error)
                    completionHandler(status: "", success: false)
                }
            })
        }else{
            completionHandler(status: "Dirección no valida.", success: false)
        }
        
    }
    
    func showAlertWithMessage(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        alertController.addAction(closeAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        searchTextField .resignFirstResponder()
        viewSearch.hidden = true
    }
    
    func mapView(mapView: GMSMapView, didTapOverlay overlay: GMSOverlay) {
        
        for (_, polylines) in polylinesDictionary {
            let poly = polylines as! GMSPolyline
            poly.strokeWidth = 2.0
        }
        let polilyne:GMSPolyline = overlay as! GMSPolyline
        polilyne.strokeWidth = 5;
        let name: String = overlay.title!
        let imageName = name.stringByReplacingOccurrencesOfString(" ", withString: "-").lowercaseString
        busName.text = overlay.title!
        topImageView.image = UIImage(named: imageName)
    }
    @IBAction func didTapClose(sender: AnyObject) {
        searchTextField.text = ""
        searchTextField .resignFirstResponder()
    }
}
