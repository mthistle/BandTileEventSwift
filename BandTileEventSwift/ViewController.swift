//
//  ViewController.swift
//  BandTileEventSwift
//
//  Created by Mark Thistle on 4/21/15.
//  Copyright (c) 2015 New Thistle LLC. All rights reserved.
//

import UIKit

// 1. implement Client Tile Delegate Protocol
class ViewController: UIViewController, MSBClientManagerDelegate, MSBClientTileDelegate {

    @IBOutlet weak var txtOutput: UITextView!
    weak var client: MSBClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MSBClientManager.sharedManager().delegate = self
        if let client = MSBClientManager.sharedManager().attachedClients().first as? MSBClient {
            self.client = client
            // 2. Set Tile Event Delegate
            client.tileDelegate = self;

            MSBClientManager.sharedManager().connectClient(self.client)
            self.output("Please wait. Connecting to Band...")
        } else {
            self.output("Failed! No Bands attached.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func runExampleCode(sender: AnyObject) {
        if let client = self.client {
            if client.isDeviceConnected == false {
                self.output("Band is not connected. Please wait....")
                return
            }
            self.output("Button tile...")
            let tileName = "D tile"
            let tileIcon = MSBIcon(UIImage: UIImage(named: "D.png"), error: nil)
            let smallIcon = MSBIcon(UIImage: UIImage(named: "Dd.png"), error: nil)
            let tileID = NSUUID(UUIDString: "CDBDBA9F-12FD-47A5-8453-E7270A43BB99")
            var tile = MSBTile(id: tileID, name: tileName, tileIcon: tileIcon, smallIcon: smallIcon, error: nil)
            
            var textBlock = MSBPageTextBlock(rect: MSBPageRect(x: 0, y: 0, width: 200, height: 40), font: MSBPageTextBlockFont.Small)
            textBlock.elementId = 10
            textBlock.color = MSBColor.colorWithUIColor(UIColor.redColor(), error: nil) as! MSBColor!
            textBlock.margins = MSBPageMargins(left: 5, top: 2, right: 5, bottom: 2)

            var button = MSBPageTextButton(rect: MSBPageRect(x: 0, y: 0, width: 200, height: 40))
            button.elementId = 11
            button.horizontalAlignment = MSBPageHorizontalAlignment.Center
            button.pressedColor = MSBColor.colorWithUIColor(UIColor.purpleColor(), error : nil) as! MSBColor!
            button.margins = MSBPageMargins(left: 5, top: 2, right: 5, bottom: 2)
            
            var flowList = MSBPageFlowPanel(rect: MSBPageRect(x: 15, y: 0, width: 230, height: 105))
            flowList.addElement(textBlock)
            flowList.addElement(button)
            
            var page = MSBPageLayout()
            page.root = flowList
            tile.pageLayouts.addObject(page)
            
            client.tileManager.addTile(tile, completionHandler: { (error: NSError!) in
                if error == nil || MSBErrorType(rawValue: error.code) == MSBErrorType.TileAlreadyExist {
                    self.output("Creating page...")
                    
                    var pageID = NSUUID(UUIDString: "1234BA9F-12FD-47A5-83A9-E7270A43BB99")
                    var pageValues = [MSBPageTextButtonData(elementId: 11, text: "Press Me", error: nil),
                        MSBPageTextBlockData(elementId: 10, text: "TextButton Sample", error: nil)]
                    var page = MSBPageData(id: pageID, layoutIndex: 0, value: pageValues)
                    
                    client.tileManager.setPages([page], tileId: tile.tileId, completionHandler: { (error: NSError!) in
                        if error != nil {
                            self.output("Error setting page: \(error.description)")
                        } else {
                            self.output("Successfully Finished!!!")
                            self.output("You can press the button on the D Tile to observe Tile Events,")
                            self.output("or remove the tile via Microsoft Health App.")
                        }
                    })
                } else {
                    self.output(error.localizedDescription)
                }
            })
        } else {
            self.output("Band is not connected. Please wait....")
        }
    }
    
    func output(message: String) {
        self.txtOutput.text = NSString(format: "%@\n%@", self.txtOutput.text, message) as String
        let p = self.txtOutput.contentOffset
        self.txtOutput.setContentOffset(p, animated: false)
        self.txtOutput.scrollRangeToVisible(NSMakeRange(self.txtOutput.text.lengthOfBytesUsingEncoding(NSASCIIStringEncoding), 0))
    }
    
    // MARK - Client Manager Delegates
    func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        self.output("Band connected.")
    }
    
    func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        self.output("Band disconnected.")
    }
    
    func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        self.output("Failed to connect to Band.")
        self.output(error.description)
    }
    
    // MARK - Client Tile Delegate
    func client(client: MSBClient!, buttonDidPress event: MSBTileButtonEvent!) {
        self.output("\(event.description)")
    }
    
    func client(client: MSBClient!, tileDidClose event: MSBTileEvent!) {
        self.output("\(event.description)")
    }
    
    func client(client: MSBClient!, tileDidOpen event: MSBTileEvent!) {
        self.output("\(event.description)")
    }

}

