import UIKit
import Flutter
import CoreLocation

var currentLocationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
var locationTimer:Timer?

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
	
	private lazy var locationManager: CLLocationManager = {
		let manager = CLLocationManager()
		manager.desiredAccuracy = kCLLocationAccuracyBest
		manager.delegate = self
		manager.requestAlwaysAuthorization()
		manager.allowsBackgroundLocationUpdates = true
		return manager
	}()
	
  override func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		locationManager.startUpdatingLocation()
		//Set the accuracy to 50 meter
		locationManager.desiredAccuracy = 50.0
		//start_timer
		startTimer()
		
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
	
	override func applicationWillEnterForeground(_ application: UIApplication) {
		startTimer()
	}
	override func applicationDidEnterBackground(_ application: UIApplication) {
		startTimer()
	}

}

// MARK: - CLLocationManagerDelegate

extension AppDelegate: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let mostRecentLocation = locations.last else {
			return
		}
		currentLocationCoordinate = mostRecentLocation.coordinate
	}
}

// MARK: - API Methods

extension AppDelegate {
    
    /**
     Send the web reuqest to submit the coordinates
     
     - Parameter latitude: Latitude of the current location
     - Parameter longitude: Longitude of the current location
     */
    static func sendWebReuestToSubmitCoordinates(withLatitude latitude:Double?, withLongitude longitude:Double?) {
        guard let lat = latitude, let long = longitude else {return}
        
        let params:[String:Any] = ["lat" : lat,
                                   "lng" : long]
        
        YARequestManager.shared.requestHTTPPOST(url: "https://api.taanni.com/v1/user/addgps", parameters: params, finished: { (response) in
            if let status = response["Success"] as? String, status == "True" {
                print("success")
            }
        }) { (error) in
            print(error)
        }
    }
	
	/**
	 Will start a timer to update the location to the server
	 */
	 fileprivate func startTimer() {
			locationTimer?.invalidate()
			locationTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
					DispatchQueue.global(qos: .background).async {
							AppDelegate.sendWebReuestToSubmitCoordinates(withLatitude: currentLocationCoordinate.latitude, withLongitude: currentLocationCoordinate.longitude)
					}
			}
	}
}
