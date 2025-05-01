//
//  Assignment1Tests.swift
//  Assignment1Tests
//
//  Created by udeesha rukshan on 2025-03-03.
//

import Testing
import SwiftUI
import CoreLocation
import MapKit
@testable import Assignment1

struct Assignment1Tests {

    // MARK: - CrimeViewModel Tests
    
    @Test func testAddCrime() throws {
        // Arrange
        let viewModel = CrimeViewModel()
        let initialCount = viewModel.criminalActivities.count
        
        let location = CrimeLocation(
            title: "Test Location",
            description: "Test location description",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            address: "123 Test St, San Francisco, CA",
            timestamp: Date(),
            evidencePhotos: [],
            witnesses: 2,
            isSolved: false
        )
        
        let crime = CriminalActivity(
            title: "Test Crime",
            description: "Test crime description",
            category: .theft,
            date: Date(),
            locations: [location],
            severity: 3,
            isPriority: false
        )
        
        // Act
        viewModel.addCrime(crime)
        
        // Assert
        #expect(viewModel.criminalActivities.count == initialCount + 1)
        if let addedCrime = viewModel.criminalActivities.last {
            #expect(addedCrime.title == "Test Crime")
            #expect(addedCrime.description == "Test crime description")
            #expect(addedCrime.category == .theft)
            #expect(addedCrime.severity == 3)
            #expect(addedCrime.isPriority == false)
            #expect(addedCrime.locations.count == 1)
            
            let addedLocation = addedCrime.locations[0]
            #expect(addedLocation.title == "Test Location")
            #expect(addedLocation.witnesses == 2)
        } else {
            
        }
    }
    
    @Test func testSelectActivity() throws {
        // Arrange
        let viewModel = CrimeViewModel()
        
        let location1 = CrimeLocation(
            title: "Location 1",
            description: "Description 1",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            address: "Address 1",
            timestamp: Date(),
            evidencePhotos: [],
            witnesses: 1,
            isSolved: false
        )
        
        let location2 = CrimeLocation(
            title: "Location 2",
            description: "Description 2",
            coordinate: CLLocationCoordinate2D(latitude: 37.7850, longitude: -122.4000),
            address: "Address 2",
            timestamp: Date(),
            evidencePhotos: [],
            witnesses: 2,
            isSolved: false
        )
        
        let crime = CriminalActivity(
            title: "Multiple Locations Crime",
            description: "Crime with multiple locations",
            category: .vandalism,
            date: Date(),
            locations: [location1, location2],
            severity: 4,
            isPriority: true
        )
        
        // Act
        viewModel.selectActivity(crime)
        
        // Assert
        #expect(viewModel.selectedActivity != nil)
        if let selectedActivity = viewModel.selectedActivity {
            #expect(selectedActivity.title == "Multiple Locations Crime")
            #expect(selectedActivity.locations.count == 2)
            
            // Check if the region was updated to encompass both locations
            let expectedCenter = CLLocationCoordinate2D(
                latitude: (location1.coordinate.latitude + location2.coordinate.latitude) / 2,
                longitude: (location1.coordinate.longitude + location2.coordinate.longitude) / 2
            )
            
            // Allow for small rounding differences
            #expect(abs(viewModel.region.center.latitude - expectedCenter.latitude) < 0.001)
            #expect(abs(viewModel.region.center.longitude - expectedCenter.longitude) < 0.001)
        }
    }
    
    @Test func testNotificationMessage() throws {
        // Arrange
        let viewModel = CrimeViewModel()
        #expect(viewModel.notificationMessage == nil)
        
        let location = CrimeLocation(
            title: "Notification Test Location",
            description: "Test location",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            address: "123 Test St",
            timestamp: Date(),
            evidencePhotos: [],
            witnesses: 0,
            isSolved: false
        )
        
        let crime = CriminalActivity(
            title: "Notification Test Crime",
            description: "Test description",
            category: .assault,
            date: Date(),
            locations: [location],
            severity: 5,
            isPriority: true
        )
        
        // Act
        viewModel.addCrime(crime)
        
        // Assert
        #expect(viewModel.notificationMessage != nil)
        if let message = viewModel.notificationMessage {
            #expect(message.contains("Notification Test Crime"))
        }
    }
    
    // MARK: - SOSViewModel Tests
    
    @Test func testSOSEmergencyPINValidation() throws {
        // Arrange
        let sosViewModel = SOSViewModel()
        
        // Assert - check default PIN
        #expect(sosViewModel.emergencyPin == "1234")
        
        // Test countdown active by default
        #expect(sosViewModel.isCountdownActive == true)
        
        // Test initial time is set
        #expect(sosViewModel.timeRemaining == 5)
    }
    
    @Test func testTriggerEmergency() throws {
        // Arrange
        let sosViewModel = SOSViewModel()
        
        // Act
        sosViewModel.triggerEmergency()
        
        // Assert
        #expect(sosViewModel.isCountdownActive == false)
    }
    
    // MARK: - Data Model Tests
    
    @Test func testCrimeCategoryProperties() throws {
        // Arrange & Act
        let theftCategory = CrimeCategory.theft
        let assaultCategory = CrimeCategory.assault
        let vandalismCategory = CrimeCategory.vandalism
        
        // Assert
        #expect(theftCategory.icon == "bag.fill.badge.minus")
        #expect(assaultCategory.icon == "person.fill.xmark")
        #expect(vandalismCategory.icon == "hammer.fill")
        
        // Check colors are distinct
        #expect(theftCategory.color != assaultCategory.color)
        #expect(assaultCategory.color != vandalismCategory.color)
        #expect(vandalismCategory.color != theftCategory.color)
    }
    
    @Test func testCriminalActivityInitialization() throws {
        // Arrange
        let location = CrimeLocation(
            title: "Init Test Location",
            description: "Test location",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            address: "123 Test St",
            timestamp: Date(),
            evidencePhotos: [],
            witnesses: 0,
            isSolved: false
        )
        
        // Act
        let crime = CriminalActivity(
            title: "Init Test Crime",
            description: "Test description",
            category: .other,
            date: Date(),
            locations: [location],
            severity: 2,
            isPriority: false
        )
        
        // Assert
        #expect(crime.title == "Init Test Crime")
        #expect(crime.description == "Test description")
        #expect(crime.category == .other)
        #expect(crime.severity == 2)
        #expect(crime.isPriority == false)
        #expect(crime.locations.count == 1)
        #expect(crime.locations[0].title == "Init Test Location")
    }
    
    // MARK: - ProfileViewModel Tests
    
    @Test func testProfileViewModelDefaultValues() throws {
        // Arrange & Act
        let profileViewModel = ProfileViewModel()
        
        // Assert
        #expect(profileViewModel.name == "Udeesha Rukshan")
        #expect(profileViewModel.email == "udeeshagamage12@gmail.com")
        #expect(profileViewModel.phone == "+940702796111")
        #expect(profileViewModel.location == "Kaduwela")
        
        // Check notification settings
        #expect(profileViewModel.crimeAlertsEnabled == true)
        #expect(profileViewModel.nearbyWarningsEnabled == true)
        #expect(profileViewModel.soundAlertsEnabled == true)
    }
    
    @Test func testProfileBadges() throws {
        // Arrange
        let profileViewModel = ProfileViewModel()
        
        // Act
        profileViewModel.loadProfile()
        
        // Assert
        #expect(profileViewModel.badges.isEmpty == false)
        
        // Check if at least some of the expected badges are present
        let badgeNames = profileViewModel.badges.map { $0.name }
        #expect(badgeNames.contains("Guardian"))
        #expect(badgeNames.contains("First Report"))
    }
}
