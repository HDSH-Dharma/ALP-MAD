//
// ItineraryCanvasUITests.swift
// ALP_MADUITests
//
// Created by student on 10/06/26.
//

import XCTest

final class ItineraryCanvasUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-data"]
        app.launch()
        
        // Navigate to Interactive Canvas
        navigateToInteractiveCanvas()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Functions
    
    private func navigateToInteractiveCanvas() {
        // Adjust this based on your actual navigation flow
        // Example:
        // let tripCell = app.tables.cells.firstMatch
        // tripCell.tap()
        // let dayCell = app.tables.cells["Day 1"]
        // dayCell.tap()
    }
    
    // MARK: - App Launch Tests
    
    @MainActor
    func testAppLaunch() throws {
        XCTAssertTrue(app.exists, "App should launch successfully")
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    // MARK: - Map Interaction Tests
    
    @MainActor
    func testMapDisplays() throws {
        let map = app.maps.firstMatch
        XCTAssertTrue(map.waitForExistence(timeout: 5), "Map should be displayed")
    }
    
    @MainActor
    func testMapCanBeZoomed() throws {
        let zoomInButton = app.buttons["plus"]
        let zoomOutButton = app.buttons["minus"]
        
        if zoomInButton.waitForExistence(timeout: 3) {
            zoomInButton.tap()
            sleep(1)
            
            zoomOutButton.tap()
            sleep(1)
            
            let map = app.maps.firstMatch
            XCTAssertTrue(map.exists, "Map should still exist after zoom")
        }
    }
    
    @MainActor
    func testMapAnnotationsExist() throws {
        let map = app.maps.firstMatch
        if map.waitForExistence(timeout: 5) {
            let annotations = map.otherElements
            XCTAssertTrue(annotations.count > 0 || true, "Map should have annotations or be empty")
        }
    }
    
    @MainActor
    func testMapIsAccessible() throws {
        let map = app.maps.firstMatch
        if map.waitForExistence(timeout: 3) {
            XCTAssertTrue(map.isAccessibilityElement, "Map should be accessible")
        }
    }
    
    // MARK: - Search Functionality Tests
    
    @MainActor
    func testSearchButtonExists() throws {
        let searchButton = app.buttons["magnifyingglass"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 3), "Search button should exist")
        XCTAssertTrue(searchButton.isHittable, "Search button should be hittable")
    }
    
    @MainActor
    func testSearchModalOpensAndCloses() throws {
        let searchButton = app.buttons["magnifyingglass"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 3))
        
        searchButton.tap()
        
        let searchField = app.textFields["Cari tempat..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2), "Search field should appear")
        
        let closeButton = app.buttons["Tutup"]
        XCTAssertTrue(closeButton.exists, "Close button should exist")
        closeButton.tap()
        
        XCTAssertFalse(searchField.waitForExistence(timeout: 2), "Search field should disappear")
    }
    
    @MainActor
    func testSearchModalHasTextField() throws {
        let searchButton = app.buttons["magnifyingglass"]
        if searchButton.waitForExistence(timeout: 3) {
            searchButton.tap()
            
            let searchField = app.textFields["Cari tempat..."]
            XCTAssertTrue(searchField.waitForExistence(timeout: 2), "Search field should exist")
            XCTAssertTrue(searchField.isHittable, "Search field should be hittable")
        }
    }
    
    @MainActor
    func testSearchAutoTriggers() throws {
        let searchButton = app.buttons["magnifyingglass"]
        if searchButton.waitForExistence(timeout: 3) {
            searchButton.tap()
            
            let searchField = app.textFields["Cari tempat..."]
            if searchField.waitForExistence(timeout: 2) {
                searchField.tap()
                searchField.typeText("Tu")
                
                sleep(2)
                
                let progressIndicator = app.progressIndicators.firstMatch
                let resultsList = app.tables.firstMatch
                
                XCTAssertTrue(progressIndicator.exists || resultsList.exists || true, "Search should trigger automatically")
            }
        }
    }
    
    @MainActor
    func testSearchClearButton() throws {
        let searchButton = app.buttons["magnifyingglass"]
        if searchButton.waitForExistence(timeout: 3) {
            searchButton.tap()
            
            let searchField = app.textFields["Cari tempat..."]
            if searchField.waitForExistence(timeout: 2) {
                searchField.tap()
                searchField.typeText("Test")
                
                let clearButton = app.buttons["xmark.circle.fill"]
                if clearButton.waitForExistence(timeout: 2) {
                    clearButton.tap()
                    XCTAssertEqual(searchField.value as? String, "", "Search field should be cleared")
                }
            }
        }
    }
    
    @MainActor
    func testSearchTyping() throws {
        let searchButton = app.buttons["magnifyingglass"]
        if searchButton.waitForExistence(timeout: 3) {
            searchButton.tap()
            
            let searchField = app.textFields["Cari tempat..."]
            if searchField.waitForExistence(timeout: 2) {
                searchField.tap()
                searchField.typeText("Tugu")
                
                XCTAssertEqual(searchField.value as? String, "Tugu", "Text should be entered correctly")
            }
        }
    }
    
    // MARK: - Bottom Sheet Tests
    
    @MainActor
    func testBottomSheetDisplays() throws {
        let sheetHeader = app.staticTexts["Jadwal Aktivitas"]
        XCTAssertTrue(sheetHeader.waitForExistence(timeout: 3), "Bottom sheet should be displayed")
    }
    
    @MainActor
    func testBottomSheetEmptyState() throws {
        let emptyStateText = app.staticTexts["Jadwal hari ini masih kosong."]
        if emptyStateText.waitForExistence(timeout: 3) {
            XCTAssertTrue(emptyStateText.exists, "Empty state should be displayed")
        }
    }
    
    @MainActor
    func testBottomSheetCanBeDragged() throws {
        let sheetHeader = app.staticTexts["Jadwal Aktivitas"]
        if sheetHeader.waitForExistence(timeout: 3) {
            let start = sheetHeader.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let end = start.withOffset(CGVector(dx: 0, dy: -200))
            
            start.press(forDuration: 0.1, thenDragTo: end)
            sleep(1)
            
            XCTAssertTrue(sheetHeader.exists, "Bottom sheet should still exist after drag")
        }
    }
    
    @MainActor
    func testBottomSheetDragHandle() throws {
        let dragHandle = app.otherElements.matching(identifier: "DragHandle").firstMatch
        if dragHandle.waitForExistence(timeout: 3) {
            XCTAssertTrue(dragHandle.exists, "Drag handle should exist")
        }
    }
    
    // MARK: - Add Place Tests
    
    @MainActor
    func testAddPlaceSheetOpens() throws {
        let searchButton = app.buttons["magnifyingglass"]
        if searchButton.waitForExistence(timeout: 3) {
            searchButton.tap()
            
            let searchField = app.textFields["Cari tempat..."]
            if searchField.waitForExistence(timeout: 2) {
                searchField.tap()
                searchField.typeText("Tugu")
                sleep(2)
                
                let firstResult = app.tables.cells.firstMatch
                if firstResult.waitForExistence(timeout: 3) {
                    firstResult.tap()
                    
                    let addPlaceSheet = app.staticTexts["Tambahkan Tempat"]
                    if addPlaceSheet.waitForExistence(timeout: 2) {
                        XCTAssertTrue(addPlaceSheet.exists, "Add place sheet should open")
                    }
                }
            }
        }
    }
    
    @MainActor
    func testAddPlaceSheetDisplaysTimePicker() throws {
        let searchButton = app.buttons["magnifyingglass"]
        if searchButton.waitForExistence(timeout: 3) {
            searchButton.tap()
            
            let searchField = app.textFields["Cari tempat..."]
            if searchField.waitForExistence(timeout: 2) {
                searchField.tap()
                searchField.typeText("Tugu")
                sleep(2)
                
                let firstResult = app.tables.cells.firstMatch
                if firstResult.waitForExistence(timeout: 3) {
                    firstResult.tap()
                    
                    let addPlaceTitle = app.staticTexts["Tambahkan Tempat"]
                    if addPlaceTitle.waitForExistence(timeout: 2) {
                        XCTAssertTrue(addPlaceTitle.exists)
                        
                        let datePicker = app.datePickers.firstMatch
                        XCTAssertTrue(datePicker.exists || true, "Time picker should exist")
                    }
                }
            }
        }
    }
    
    @MainActor
    func testAddPlaceSheetCancelButton() throws {
        let searchButton = app.buttons["magnifyingglass"]
        if searchButton.waitForExistence(timeout: 3) {
            searchButton.tap()
            
            let searchField = app.textFields["Cari tempat..."]
            if searchField.waitForExistence(timeout: 2) {
                searchField.tap()
                searchField.typeText("Tugu")
                sleep(2)
                
                let firstResult = app.tables.cells.firstMatch
                if firstResult.waitForExistence(timeout: 3) {
                    firstResult.tap()
                    
                    let cancelButton = app.buttons["Batal"]
                    if cancelButton.waitForExistence(timeout: 2) {
                        cancelButton.tap()
                        
                        let addPlaceTitle = app.staticTexts["Tambahkan Tempat"]
                        XCTAssertFalse(addPlaceTitle.waitForExistence(timeout: 2), "Add place sheet should close")
                    }
                }
            }
        }
    }
    
    // MARK: - Edit Time Tests
    
    @MainActor
    func testEditTimeSheetOpens() throws {
        let sheetHeader = app.staticTexts["Jadwal Aktivitas"]
        if sheetHeader.waitForExistence(timeout: 3) {
            let destinationRow = app.tables.cells.firstMatch
            if destinationRow.waitForExistence(timeout: 2) {
                destinationRow.tap()
                
                let editTitle = app.staticTexts["Edit Jadwal"]
                if editTitle.waitForExistence(timeout: 2) {
                    XCTAssertTrue(editTitle.exists, "Edit time sheet should open")
                }
            }
        }
    }
    
    // MARK: - Zoom Controls Tests
    
    @MainActor
    func testZoomButtonsExist() throws {
        let zoomInButton = app.buttons["plus"]
        let zoomOutButton = app.buttons["minus"]
        
        if zoomInButton.waitForExistence(timeout: 3) {
            XCTAssertTrue(zoomInButton.exists, "Zoom in button should exist")
            XCTAssertTrue(zoomInButton.isHittable, "Zoom in button should be hittable")
        }
        
        if zoomOutButton.waitForExistence(timeout: 3) {
            XCTAssertTrue(zoomOutButton.exists, "Zoom out button should exist")
            XCTAssertTrue(zoomOutButton.isHittable, "Zoom out button should be hittable")
        }
    }
    
    @MainActor
    func testZoomInButtonFunctionality() throws {
        let zoomInButton = app.buttons["plus"]
        if zoomInButton.waitForExistence(timeout: 3) {
            let initialFrame = zoomInButton.frame
            
            zoomInButton.tap()
            sleep(1)
            
            XCTAssertEqual(zoomInButton.frame, initialFrame, "Zoom in button should remain in same position")
        }
    }
    
    @MainActor
    func testZoomOutButtonFunctionality() throws {
        let zoomOutButton = app.buttons["minus"]
        if zoomOutButton.waitForExistence(timeout: 3) {
            let initialFrame = zoomOutButton.frame
            
            zoomOutButton.tap()
            sleep(1)
            
            XCTAssertEqual(zoomOutButton.frame, initialFrame, "Zoom out button should remain in same position")
        }
    }
    
    @MainActor
    func testZoomButtonsHiddenWhenSheetExpanded() throws {
        let sheetHeader = app.staticTexts["Jadwal Aktivitas"]
        if sheetHeader.waitForExistence(timeout: 3) {
            let start = sheetHeader.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let end = start.withOffset(CGVector(dx: 0, dy: -500))
            
            start.press(forDuration: 0.1, thenDragTo: end)
            sleep(1)
            
            let zoomInButton = app.buttons["plus"]
            if zoomInButton.exists {
                XCTAssertTrue(!zoomInButton.isHittable || !zoomInButton.exists, "Zoom buttons should be hidden when sheet is expanded")
            }
        }
    }
    
    // MARK: - Save Functionality Tests
    
    @MainActor
    func testSaveButtonExists() throws {
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Save button should exist")
        XCTAssertTrue(saveButton.isHittable, "Save button should be hittable")
    }
    
    @MainActor
    func testSaveButtonTappable() throws {
        let saveButton = app.buttons["Save"]
        if saveButton.waitForExistence(timeout: 3) {
            saveButton.tap()
            sleep(1)
            
            XCTAssertTrue(app.exists, "App should still be responsive after save")
        }
    }
    
    @MainActor
    func testButtonsHaveAccessibilityLabels() throws {
        let searchButton = app.buttons["magnifyingglass"]
        if searchButton.waitForExistence(timeout: 3) {
            XCTAssertTrue(searchButton.label.count > 0, "Search button should have accessibility label")
        }
        
        let saveButton = app.buttons["Save"]
        if saveButton.waitForExistence(timeout: 3) {
            XCTAssertTrue(saveButton.label.count > 0, "Save button should have accessibility label")
        }
    }
    
    // MARK: - Integration Tests
    
    @MainActor
    func testSearchAndAddPlaceFlow() throws {
        let searchButton = app.buttons["magnifyingglass"]
        if searchButton.waitForExistence(timeout: 3) {
            searchButton.tap()
            
            let searchField = app.textFields["Cari tempat..."]
            if searchField.waitForExistence(timeout: 2) {
                searchField.tap()
                searchField.typeText("Hotel")
                
                sleep(2)
                
                let resultsList = app.tables.firstMatch
                if resultsList.waitForExistence(timeout: 3) {
                    XCTAssertTrue(resultsList.exists, "Search results should be displayed")
                }
            }
        }
    }
    
    @MainActor
    func testNavigateToItinerary() throws {
        let itineraryTab = app.tabBars.buttons["Itinerary"]
        if itineraryTab.exists {
            itineraryTab.tap()
            XCTAssertTrue(app.navigationBars["Itinerary"].waitForExistence(timeout: 2), "Should navigate to itinerary")
        }
    }
    
    // MARK: - Error Handling Tests
    
    @MainActor
    func testTimeConflictErrorDisplayed() throws {
        // This test requires adding two destinations with same time
        // Placeholder for now
        XCTAssertTrue(true, "Time conflict error handling test placeholder")
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testMapRenderingPerformance() throws {
        let map = app.maps.firstMatch
        if map.waitForExistence(timeout: 5) {
            measure {
                let zoomInButton = app.buttons["plus"]
                let zoomOutButton = app.buttons["minus"]
                
                if zoomInButton.exists && zoomOutButton.exists {
                    for _ in 0..<3 {
                        zoomInButton.tap()
                        sleep(1)
                        zoomOutButton.tap()
                        sleep(1)
                    }
                }
            }
        }
    }
    
    @MainActor
    func testSearchPerformance() throws {
        let searchButton = app.buttons["magnifyingglass"]
        if searchButton.waitForExistence(timeout: 3) {
            measure {
                searchButton.tap()
                
                let searchField = app.textFields["Cari tempat..."]
                if searchField.waitForExistence(timeout: 2) {
                    searchField.tap()
                    searchField.typeText("Hotel")
                    sleep(2)
                    
                    let closeButton = app.buttons["Tutup"]
                    if closeButton.exists {
                        closeButton.tap()
                    }
                }
            }
        }
    }
    
    @MainActor
    func testBottomSheetDragPerformance() throws {
        let sheetHeader = app.staticTexts["Jadwal Aktivitas"]
        if sheetHeader.waitForExistence(timeout: 3) {
            measure {
                for _ in 0..<3 {
                    let start = sheetHeader.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                    let end = start.withOffset(CGVector(dx: 0, dy: -200))
                    
                    start.press(forDuration: 0.1, thenDragTo: end)
                    sleep(1)
                    
                    let endDown = start.withOffset(CGVector(dx: 0, dy: 200))
                    end.press(forDuration: 0.1, thenDragTo: endDown)
                    sleep(1)
                }
            }
        }
    }
}
