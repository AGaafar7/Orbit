//
//  OrbitInputManager.swift
//  Orbit
//
//  Created by Ahmed Gaafar on 25/03/2026.
//


import Cocoa
import CoreGraphics

func cgEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = OrbitInputManager.shared.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passUnretained(event)
    }
    
    return OrbitInputManager.shared.handleEvent(proxy: proxy, type: type, event: event)
}

class OrbitInputManager {
    static let shared = OrbitInputManager()
    
    var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    // Tracks if we are actively cycling (prevents accidental triggers)
    private var isSwitchingSessionActive = false
    
    func startMonitoring() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: cgEventCallback,
            userInfo: nil
        )
        
        guard let eventTap = eventTap else {
            print("Failed to create event tap. Make sure Orbit has Accessibility permissions.")
            return
        }
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        let flags = event.flags
        let isOptionHeld = flags.contains(.maskAlternate)
        let isControlHeld = flags.contains(.maskControl)
        
        let isModifierComboHeld = isOptionHeld && isControlHeld
        
        if type == .keyDown {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            
            if keyCode == 48 && isModifierComboHeld {
                let isShiftHeld = flags.contains(.maskShift)
                isSwitchingSessionActive = true
                DispatchQueue.main.async {
                    if !OrbitOverlayManager.shared.isVisible {
                        OrbitOverlayManager.shared.showOverlay()
                    }
                    OrbitOverlayManager.shared.cycle(forward: !isShiftHeld)
                }
                return nil
                
            } else if isSwitchingSessionActive {
                isSwitchingSessionActive = false
                DispatchQueue.main.async {
                    OrbitOverlayManager.shared.hideOverlay()
                }
            }
            
        } else if type == .flagsChanged {
            if !isModifierComboHeld && isSwitchingSessionActive {
                isSwitchingSessionActive = false // End the session
                
                DispatchQueue.main.async {
                    if OrbitOverlayManager.shared.isVisible {
                        OrbitOverlayManager.shared.activateSelectedApp()
                    }
                }
            }
        }
            return Unmanaged.passUnretained(event)
    }
}
