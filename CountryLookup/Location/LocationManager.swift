//
//  LocationManager.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 15/11/2025.
//

import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol {
    func requestLocationAndGetCountryCode() async -> String?
}

final class LocationManager: NSObject, ObservableObject, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<String?, Never>?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocationAndGetCountryCode() async -> String? {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                self.continuation = continuation
                locationManager.requestWhenInUseAuthorization()
            }
        case .authorizedWhenInUse, .authorizedAlways:
            return await withCheckedContinuation { continuation in
                self.continuation = continuation
                locationManager.requestLocation()
            }
        case .denied, .restricted:
            return nil
        default:
            return nil
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if continuation != nil {
                locationManager.requestLocation()
            }
            
        case .denied, .restricted:
            if let continuation = continuation {
                self.continuation = nil
                continuation.resume(returning: nil)
            }
            
        case .notDetermined:
            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            continuation?.resume(returning: nil)
            continuation = nil
            return
        }
        Task {
            do {
                let geocoder = CLGeocoder()
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                let countryCode = placemarks.first?.isoCountryCode
                continuation?.resume(returning: countryCode)
                continuation = nil
            } catch {
                continuation?.resume(returning: nil)
                continuation = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(returning: nil)
        continuation = nil
    }
}
