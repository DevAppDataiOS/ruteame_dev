//
//  ViewController.swift
//  Ruteame
//
//  Created by Roberto Avalos on 31/03/16.
//  Copyright © 2016 Roberto Avalos. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMobileAds


enum SSlideOutState{
    case IsCollapse
    case BottomPanelExpanded
    
}

class MapViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate,
    UITableViewDataSource, GMSMapViewDelegate, UITextFieldDelegate{
    
    var mapNavigation: UINavigationController!
    var currentState: SSlideOutState = .IsCollapse
    var interstitial: GADInterstitial!
    var polylinesDictionary = NSMutableDictionary()
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    var fetchedFormattedAddress: String!
    var fetchedAddressLongitude: Double!
    var fetchedAddressLatitude: Double!
    var marker = GMSMarker()
    
    let locationManager = CLLocationManager()
    let busData = BusData()
    let topView: CGFloat = 11;
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var busIcon: UIImageView!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var textInHeader: UILabel!
    @IBOutlet weak var searchViewContainer: UIView!
    @IBOutlet weak var textAddress: UITextField!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var viewListBuses: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewMap: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Ruteame"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "[z] Arista", size: 22)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        bannerView.adUnitID = "ca-app-pub-2527087462892904/6379466872"
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.allowsMultipleSelection = true
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(19.244572, longitude: -103.725520, zoom: 13)
        
        viewMap.camera = camera
        viewMap.myLocationEnabled = true
        viewMap.delegate = self
        viewMap.settings.myLocationButton = true
        viewMap.padding = UIEdgeInsetsMake(0, 0, 80, 0)

        
        //viewMap.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        showAllRoutesAndFillDictionaries()
        
        textAddress.delegate = self
        
        let maskPath = UIBezierPath(roundedRect: roundedView.bounds,byRoundingCorners: [.TopRight, .TopLeft] , cornerRadii: CGSize(width: 30.0, height: 30.0))
        
        let maskLayer = CAShapeLayer(layer: maskPath)
        maskLayer.frame = roundedView.bounds
        maskLayer.path = maskPath.CGPath
        roundedView.layer.mask = maskLayer
        
        let gesture = UITapGestureRecognizer(target:  self, action: #selector(MapViewController.moveTheView))
        self.headerView.addGestureRecognizer(gesture)
        
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MapViewController.handlePanGesture(_:)))
        self.viewListBuses.addGestureRecognizer(panGestureRecognizer)
    }
   
    
    @IBAction func deleteTextAddress(sender: UIButton) {
        textAddress.text = ""
        
        self.marker.map = nil
    }
    
    @IBAction func searchAddressButton(sender: UIButton) {
        
        sendAddressToGeocode()
        
    }
    
    @IBAction func startSearching(sender: UIBarButtonItem) {
        
        
        if searchViewContainer.hidden {
            if (Reachability.isConnectedToNetwork()){
                textAddress.userInteractionEnabled = true
            }else{
                let alert = UIAlertView()
                alert.title = "No hay conexión a internet"
                alert.message = "Para poder buscar una dirección se necesita estar conectado a internet"
                alert.addButtonWithTitle("Aceptar")
                alert.show()
                textAddress.userInteractionEnabled = false
            }

            searchViewContainer.hidden = false
            textAddress.becomeFirstResponder()
            
        }else{
            textAddress.text = ""
            self.dismissKeyboard()
            
            searchViewContainer.hidden = true
        }
    }
    
    
    struct TableView {
        struct CellIdentifiers {
            static let BusesCell = "BusesCell"
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        //textAddress.resignFirstResponder()
        sendAddressToGeocode()
        return true
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

        textInHeader.text = overlay.title!
        
        busIcon.image = UIImage(named: imageName)
    }
    
    func sendAddressToGeocode(){
        if textAddress.text != ""{
            self.marker.map = nil
            let address = textAddress.text!
            
            geocodeAddress(address + ", Colima", withCompletionHandler: { (status, success) -> Void in
                if !success {
                    
                    if status == "ZERO_RESULTS" {
                        self.showAlertWithMessage("Dirección no encontrada.")
                    }
                }
                else {
                    let coordinate = CLLocationCoordinate2D(latitude: self.fetchedAddressLatitude, longitude: self.fetchedAddressLongitude)
                    let  position = CLLocationCoordinate2DMake(self.fetchedAddressLatitude, self.fetchedAddressLongitude)
                    self.marker = GMSMarker(position: position)
                    self.marker.icon = UIImage(named: "marker")
                    self.marker.title = address + ", Colima"
                    self.marker.map = self.viewMap
                    self.dismissKeyboard()
                    
                    self.viewMap.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 14.0)
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
    
    func dismissKeyboard(){
        view.endEditing(true)
    }

    override func viewDidAppear(animated: Bool) {
        
        tableView.frame = CGRectMake(0, 81, self.viewListBuses.frame.size.width, self.view.frame.size.height/2)
        selectAllCells()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        //print("locations = \(locations)")
        
    }
    
    /* TABLEVIEW */
    
    func selectAllCells(){
        for cells in 1...busData.data.count{
            let indexPath: NSIndexPath = NSIndexPath(forRow: cells-1, inSection: 0)
            
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
        }
        
        let indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
    }
    
    func unselectAllCells(){
        for cells in 1...busData.data.count{
            let indexPath: NSIndexPath = NSIndexPath(forRow: cells-1, inSection: 0)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    // when the user unselect a item in the list
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
        
        textInHeader.text = "Rutas"
        
        if (name == "Todas"){
            self.viewMap.clear()
            busIcon.image = UIImage(named: "blanco")
            unselectAllCells()
            
        }else{
            let indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            deleteRoute(name)
        }
        
        //animateBottomPanel(false)
        
    }
    
    // when the user select a item in the list
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
            busIcon.image = UIImage(named: "todas")
            textInHeader.text = "Todas"
            selectAllCells()
        }else{
            textInHeader.text = name
            printJustOneRoute(name)
            busIcon.image = UIImage(named: imageName)
            
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
            self.viewMap.moveCamera(update)

        }
        
        //animateBottomPanel(false)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busData.data.count
        
    }
    
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCell {
        let item = busData.data[indexPath.row]["busName"] as! String
        let image = busData.data[indexPath.row]["geoJsonName"] as! String
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.BusesCell, forIndexPath: indexPath) as! BusesCell
        
        cell.configurateForBuses(item, imageName: image)
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.clearColor()
        
    }
    
    /*
        Slide up Menu
     */
    func moveView(){
        let isExpanded = (currentState != .BottomPanelExpanded)
        print(isExpanded)
        animateBottomPanel(isExpanded)
    }
    
    
    func animateBottomPanel(shouldExpand: Bool){
        
        if (shouldExpand) {
            
            currentState = .BottomPanelExpanded
            
            animateCenterPanelYPosition(CGRectMake(0, (self.view.frame.size.height/2 - 116), self.view.frame.size.width, self.view.frame.size.height))
            
        } else {
            animateCenterPanelYPosition(CGRectMake(0, self.view.frame.size.height-116, self.view.frame.size.width, self.view.frame.size.height/2)) { finished in
                self.currentState = .IsCollapse
                
                
            }
        }
    }
    
    func animateCenterPanelYPosition(targetPosition: CGRect, completion: ((Bool) -> Void)! = nil) {
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.viewListBuses.frame = targetPosition
            }, completion: completion)
    }
    
    
    /* Print routes on the map */
   
    func printJustOneRoute(busName: String){
        print(busName)
        let polyline = polylinesDictionary.objectForKey(busName) as! GMSPolyline
        polyline.map = self.viewMap
        
    }
    
    func printRoutes(){
        for (_, polylines) in polylinesDictionary {
            
            let poly = polylines as! GMSPolyline
            
            dispatch_async(dispatch_get_main_queue()) {
                poly.strokeWidth = 2.0
                poly.map = self.viewMap
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
                            polyline.map = self.viewMap
                        }
                        
                    }catch{
                        
                    }
                }
            }
        }
    }
    
    
    func deleteRoute(name: String){
        let polyline: GMSPolyline = polylinesDictionary.objectForKey(name) as! GMSPolyline
        polyline.map = nil
    }
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            tableView.frame = CGRectMake(0, 81, self.viewListBuses.frame.size.width, self.view.frame.size.height/2)
            
        case .Changed:
            recognizer.view!.center.y = recognizer.view!.center.y  + recognizer.translationInView(view).y
            recognizer.setTranslation(CGPointZero, inView: view)
            
        case .Ended:
            let hasMovedGreaterThanHalfway = recognizer.view!.center.y < view.bounds.size.height-116
            
            animateBottomPanel(hasMovedGreaterThanHalfway)
            //tableView.frame = CGRectMake(0, 81, self.viewListBuses.frame.size.width, self.view.frame.size.height/2 - 74)
            
        default:
            break
        }
    }
    
    func moveTheView(){
        self.moveView()
    }
}

class BusesCell: UITableViewCell {
    
    @IBOutlet weak var identifierColor: UIImageView!
    
    @IBOutlet weak var busName: UILabel!
    func configurateForBuses(name: String, imageName: String){
        busName.text = name
        identifierColor.image = UIImage(named: "identifier-" + imageName)
    }
}


