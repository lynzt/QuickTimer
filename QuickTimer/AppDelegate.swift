//
//  AppDelegate.swift
//  QuickTimer
//
//  Created by Inder Dhir on 5/24/17.
//  Copyright © 2017 Inder Dhir. All rights reserved.
//

import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let startStopMenuItem = NSMenuItem(title: "Start", action: #selector(startStopTimer), keyEquivalent: "S")
    var timeMenuItems: [NSMenuItem]!
    var isTimerRunning = false
    var selectedTimeInSeconds = 6
    var timeRemainingInSeconds = 6
    var timer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Menu
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(startStopMenuItem)
        menu.addItem(.separator())
        
        let sixSecondMenuItem = NSMenuItem(title: "6 sec", action: #selector(timer1), keyEquivalent: "6")
        sixSecondMenuItem.state = .on
        sixSecondMenuItem.isEnabled = true
        
        let oneMinuteMenuItem = NSMenuItem(title: "1 min", action: #selector(timer1), keyEquivalent: "1")
        oneMinuteMenuItem.isEnabled = true
        let fiveMinuteMenuItem = NSMenuItem(title: "5 min", action: #selector(timer5), keyEquivalent: "2")
        fiveMinuteMenuItem.isEnabled = true
        let fifteenMinuteMenuItem = NSMenuItem(title: "15 min", action: #selector(timer15), keyEquivalent: "3")
        fifteenMinuteMenuItem.isEnabled = true
        let thirtyMinuteMenuItem = NSMenuItem(title: "30 min", action: #selector(timer30), keyEquivalent: "4")
        thirtyMinuteMenuItem.isEnabled = true
        let sixtyMinuteMenuItem = NSMenuItem(title: "60 min", action: #selector(timer60), keyEquivalent: "5")
        sixtyMinuteMenuItem.isEnabled = true

        timeMenuItems = [sixSecondMenuItem, oneMinuteMenuItem, fiveMinuteMenuItem, fifteenMinuteMenuItem, thirtyMinuteMenuItem, sixtyMinuteMenuItem]

        menu.addItem(sixSecondMenuItem)
        menu.addItem(oneMinuteMenuItem)
        menu.addItem(fiveMinuteMenuItem)
        menu.addItem(fifteenMinuteMenuItem)
        menu.addItem(thirtyMinuteMenuItem)
        menu.addItem(sixtyMinuteMenuItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(terminate), keyEquivalent: "q"))

        statusItem.menu = menu
        statusItem.title = "Thymer"
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    // MARK: Selectors
    @objc func timer6() { timer(6) }
    
    @objc func timer1() { timer(1) }

    @objc func timer5() { timer(5) }

    @objc func timer15() { timer(15) }

    @objc func timer30() { timer(30) }

    @objc func timer60() { timer(60) }

    func timer(_ time: Int){
        let selectedIndex: Int
        print (time)
        switch time {
        case 6:
            selectedIndex = 5
            selectedTimeInSeconds = 6
            
        case 1:
            selectedIndex = 0
            selectedTimeInSeconds = 5
        case 5:
            selectedIndex = 1
            selectedTimeInSeconds = 300
        case 15:
            selectedIndex = 2
            selectedTimeInSeconds = 900
        case 30:
            selectedIndex = 3
            selectedTimeInSeconds = 1800
        case 60:
            selectedIndex = 4
            selectedTimeInSeconds = 3600
        default:
            selectedIndex = 5
            break
        }
        timeRemainingInSeconds = selectedTimeInSeconds

        for (index, menuItem) in timeMenuItems.enumerated() {
            menuItem.state = index == selectedIndex ? .on : .off
        }
    }

    @objc func startStopTimer() {
        isTimerRunning = !isTimerRunning
        isTimerRunning ? startTimer() : stopTimer()
    }

    @objc func timerUpdate() {
        timeRemainingInSeconds -= 1
        if timeRemainingInSeconds == 0 {
            stopTimer()
            displayNotification()

            timeRemainingInSeconds = selectedTimeInSeconds
        }
        else {
            let minutesLeftString = String(format: "%02d", timeRemainingInSeconds / 60)
            let secondsLeftString = String(format: "%02d", timeRemainingInSeconds % 60)
            statusItem.title = formatTimeRemaining()
            startStopMenuItem.title = "Stop (\(formatTimeRemaining()))"
        }
    }
    
    
    @objc func formatTimeRemaining() -> String {
        let minutesLeftString = String(format: "%02d", timeRemainingInSeconds / 60)
        let secondsLeftString = String(format: "%02d", timeRemainingInSeconds % 60)
        return "\(minutesLeftString):\(secondsLeftString)"

    }

    @objc func terminate() { NSApp.terminate(self) }

    // MARK: Private methods

    private func startTimer() {
        startStopMenuItem.title = "Stop"
        timeMenuItems.forEach { $0.isEnabled = false }
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(timerUpdate),
            userInfo: nil,
            repeats: true
        )
            if let timer = timer { RunLoop.main.add(timer, forMode: .commonModes) }
    }

    private func stopTimer() {
        startStopMenuItem.title = "Start"
        timeMenuItems.forEach { $0.isEnabled = true }
        timer?.invalidate()
        timer = nil
    }
    
    @objc func displayNotification() {
        let notification = NSUserNotification()
        notification.title = "It's time! 🕘"
        
        NSUserNotificationCenter.default.deliver(notification)
        
        NSApplication.shared.requestUserAttention(.criticalRequest)
        
        let soundURL = Bundle.main.url(forResource: "juand20__aparicion", withExtension: "wav")
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL! as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
        startTimer()
    }


    // MARK: NSUserNotificationCenterDelegate

    public func userNotificationCenter(
        _ center: NSUserNotificationCenter,
        shouldPresent notification: NSUserNotification
        ) -> Bool {
        return true
    }
}

