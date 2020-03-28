//
//  LocationTracker.swift
//  LocationTracker
//
//  Created by Denny Mathew on 28/03/20.
//  Copyright © 2020 Densigns. All rights reserved.
//

import Foundation
import CoreLocation
protocol LocationTrackerDelegate: class {
    func didUpdateLocation()
}
class LocationTracker: NSObject {
    static let shared = LocationTracker()
    weak var delegate: LocationTrackerDelegate?
    let geoCoder = CLGeocoder()
    let locationManager = CLLocationManager()
    let notificationManager = LocalNotificationManager()
    //    private(set) var locations: [Location]
    private override init() {
        super.init()
        locationManager.requestAlwaysAuthorization()
        notificationManager.requestPermission()
        locationManager.delegate = self
    }
    func startTracking() {
        locationManager.startMonitoringVisits()
        //Fake Locations
        locationManager.distanceFilter = 35 // 0
        locationManager.allowsBackgroundLocationUpdates = true // 1
        locationManager.startUpdatingLocation()  // 2
    }
}
// MARK: - Location manager delegates
extension LocationTracker: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // create CLLocation from the coordinates of CLVisit
        let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        
        // Get location description
        geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
            if let place = placemarks?.first {
                let description = "\(place)"
                self.newVisitReceived(visit, description: description)
            }
        }
        print("Location: ", clLocation.description)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                let description = "Fake visit: \(place)"
                //Fake visit
                let fakeVisit = FakeVisit(coordinates: location.coordinate, arrivalDate: Date(), departureDate: Date())
                self.newVisitReceived(fakeVisit, description: description)
            }
        }
    }
    func newVisitReceived(_ visit: CLVisit, description: String) {
        let location = Location(visit: visit, descriptionString: description)
        print("Location: ", location)
        // TODO:- Save location to core data
        notificationManager.postNotification(location)
    }
}
final class FakeVisit: CLVisit {
    private let myCoordinates: CLLocationCoordinate2D
    private let myArrivalDate: Date
    private let myDepartureDate: Date
    
    override var coordinate: CLLocationCoordinate2D {
        return myCoordinates
    }
    
    override var arrivalDate: Date {
        return myArrivalDate
    }
    
    override var departureDate: Date {
        return myDepartureDate
    }
    
    init(coordinates: CLLocationCoordinate2D, arrivalDate: Date, departureDate: Date) {
        myCoordinates = coordinates
        myArrivalDate = arrivalDate
        myDepartureDate = departureDate
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
