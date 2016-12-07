//
//  AppDelegate.swift
//  FredServe
//
//  Created by Michael Cornell on 7/5/16.
//  Copyright © 2016 Spies & Assassins. All rights reserved.
//

import Cocoa
import Swifter

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2);
    let server = HttpServer();
    var textField: NSTextField = NSTextField();
    var serverIsRunning: Bool = false;
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        print("application did launch");
        let version: String = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String;
        print("version \(version)");

        if let button = statusItem.button {
            print("made the button!");
            button.image = NSImage(named: "StatusBarButtonImage");
            
            let menu = NSMenu()
            menu.delegate = self;
            
            let titleItem = NSMenuItem(title: "FredServe \(version)", action: nil, keyEquivalent: "");
            titleItem.enabled = false;
            menu.addItem(titleItem);
            
            menu.addItem(NSMenuItem(title: "Start", action: #selector(start), keyEquivalent: "r"));
            menu.addItem(NSMenuItem(title: "Stop", action: #selector(stop), keyEquivalent: "w"));
            
            menu.addItem(NSMenuItem.separatorItem())
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(terminate), keyEquivalent: "q"));
            statusItem.menu = menu;
            server["/:path"] = HttpHandlers.shareFilesFromDirectory(NSHomeDirectory());
            server.notFoundHandler = { r in
                return HttpResponse.NotFound;
            }
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        server.stop();
    }
    
    func start() {
        let urls = openFiles();
        print("got urls! \(urls)");
        var revisedURLS: [NSURL] = [];
        if (urls.count > 0){
            for url in urls {
                let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true);
                components?.scheme = "http";
                components?.host = "localhost";
                components?.port = 8080;
                print("path \(components?.path)");
                components?.path = "/" + url.pathComponents![3 ..< url.pathComponents!.count].joinWithSeparator("/"); // down to just home directory
                print("path \(components?.path)");
                let newURL = components?.URL;
                revisedURLS.append(newURL!);
            }
            if !serverIsRunning {
                do {
                    try server.start();
                    print("started server on port 8080");
                    serverIsRunning = true;
                }
                catch {
                    print("error starting fredserve: \(error)");
                    delay(1, closure: {
                        let alert = NSAlert();
                        alert.messageText = "Error starting FredServe";
                        alert.informativeText = "\(error)";
                        alert.addButtonWithTitle("OK");
                    });
                }
            }
            if serverIsRunning {
                NSWorkspace.sharedWorkspace().openURL(revisedURLS[0]);
            }
        }
    }
    
    func stop() {
        serverIsRunning = false;
        server.stop();
    }
    
    func terminate(){
        NSApplication.sharedApplication().terminate(self)
    }
    
    
    //MARK: - NSMenuDelegate
    
    func menuWillOpen(menu: NSMenu) {
        print("will open!");
    }
    
    func menuDidClose(menu: NSMenu) {
        print("closed");
    }
    
    
    //MARK: - Helpers
    func openFiles() -> [NSURL] {
        let fileTypes = ["jpg","jpeg","html"];
        let panel = NSOpenPanel();
        panel.allowedFileTypes = fileTypes;
        panel.allowsMultipleSelection = false;
        panel.canChooseFiles = true;
        panel.canChooseDirectories = false;
        panel.floatingPanel = true;
        let result = panel.runModal();
        if result == NSModalResponseOK {
            return panel.URLs;
        }
        else {
            return [];
        }
    }
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}

