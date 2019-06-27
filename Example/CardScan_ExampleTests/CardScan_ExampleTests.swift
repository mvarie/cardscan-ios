//
//  CardScan_ExampleTests.swift
//  CardScan_ExampleTests
//
//  Created by Sam King on 6/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import CardScan

class CardScan_ExampleTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        FindFourOcr.detectModel = nil
        FindFourOcr.recognizeModel = nil
        FindFourOcr.findFourResource = "FindFour"
        FindFourOcr.fourRecognizeResource = "FourRecognize"
        
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        
        let detectModelc = documentDirectory.appendingPathComponent("FindFour.mlmodelc")
        let recognizeModelc = documentDirectory.appendingPathComponent("FourRecognize.mlmodelc")
        
        let _ = try? FileManager.default.removeItem(at: detectModelc)
        let _ = try? FileManager.default.removeItem(at: recognizeModelc)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModelLoading() {
        XCTAssert(FindFourOcr.detectModel == nil)
        XCTAssert(FindFourOcr.recognizeModel == nil)
        let ffOcr = FindFourOcr()
        ffOcr.warmUp()
        XCTAssert(FindFourOcr.detectModel != nil)
        XCTAssert(FindFourOcr.recognizeModel != nil)
    }
    
    func testModelLoadingFailure() {
        // first try it with a non existant resource
        FindFourOcr.fourRecognizeResource = "asdf"
        let ffOcr = FindFourOcr()
        ffOcr.warmUp()
        XCTAssert(FindFourOcr.detectModel == nil)
        XCTAssert(FindFourOcr.recognizeModel == nil)
    }
    
    func testModelLoadingFailure2() {
        // first try it with a non existant resource
        FindFourOcr.findFourResource = "asdf"
        let ffOcr = FindFourOcr()
        ffOcr.warmUp()
        
        // Note: this is a side effect of our implementation since the library tries
        // the recognize model first
        XCTAssert(FindFourOcr.detectModel == nil)
        XCTAssert(FindFourOcr.recognizeModel != nil)
    }
    
    func testModelLoadingWrongResource() {
        let tmpResource = FindFourOcr.findFourResource
        FindFourOcr.findFourResource = FindFourOcr.fourRecognizeResource
        FindFourOcr.fourRecognizeResource = tmpResource
        var ffOcr = FindFourOcr()
        ffOcr.warmUp()
        
        let kCardWidth = 480
        let kCardHeight = 302
        let kBoxWidth = 80
        let kBoxHeight = 36
        
        // first let's make sure that these models throw exceptions
        UIGraphicsBeginImageContext(CGSize(width: kCardWidth, height: kCardHeight))
        UIColor.white.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: kCardWidth, height: kCardHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let pixelBuffer = newImage.pixelBuffer(width: kCardWidth, height: kCardHeight)!
        XCTAssertThrowsError(try FindFourOcr.detectModel!.prediction(input1: pixelBuffer))
        
        let pixelBuffer2 = newImage.pixelBuffer(width: kBoxWidth, height: kBoxHeight)!
        XCTAssertThrowsError(try FindFourOcr.recognizeModel!.prediction(input1: pixelBuffer2))
        
        // now call the prediction function to make sure that we're handling model exceptions
        let prediction = ffOcr.predict(image: newImage)
        XCTAssert(prediction == nil)
    }
}
