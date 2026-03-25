import Cocoa
import CoreGraphics

// A C-compatible callback required by macOS to intercept the raw input stream
func cgEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    // If macOS temporarily disables our tap (e.g., if the system is overloaded), we immediately turn it back on.
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = OrbitInputManager.shared.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passUnretained(event)
    }
    
    // Pass the event to our Swift class
    return OrbitInputManager.shared.handleEvent(proxy: proxy, type: type, event: event)
}

class OrbitInputManager {
    static let shared = OrbitInputManager()
    
    // Hold a strong reference to the Event Tap
    var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    func startMonitoring() {
        // We want to listen for physical key presses and modifier key changes (Option key)
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        
        // Create the tap directly at the OS Session level
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: cgEventCallback,
            userInfo: nil
        )
        
        guard let eventTap = eventTap else {
            print("Failed to create event tap. Make sure Orbit has Accessibility permissions in System Settings.")
            return
        }
        
        // Add the tap to the main application run loop
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .keyDown {
            // Get the raw keyboard code
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags
            
            // KeyCode 48 is Tab. We only care if Option (.maskAlternate) is being held.
            if keyCode == 48 && flags.contains(.maskAlternate) {
                let isShiftHeld = flags.contains(.maskShift)
                
                // Dispatch async so we don't hold up the OS input stream
                DispatchQueue.main.async {
                    if !OrbitOverlayManager.shared.isVisible {
                        OrbitOverlayManager.shared.showOverlay()
                    }
                    OrbitOverlayManager.shared.cycle(forward: !isShiftHeld)
                }
                
                // CRITICAL FIX: Returning nil completely deletes/swallows the event!
                // The underlying app will never know Tab was pressed.
                return nil
            }
            
        } else if type == .flagsChanged {
            let flags = event.flags
            let isOptionHeld = flags.contains(.maskAlternate)
            
            DispatchQueue.main.async {
                if isOptionHeld {
                    // Instantly show the UI when Option is pressed alone
                    if !OrbitOverlayManager.shared.isVisible {
                        OrbitOverlayManager.shared.showOverlay()
                    }
                } else {
                    // Option was released, switch to the selected app
                    if OrbitOverlayManager.shared.isVisible {
                        OrbitOverlayManager.shared.activateSelectedApp()
                    }
                }
            }
        }
        
        // For all other keys (letters, numbers, etc.), let them pass through to the system normally.
        return Unmanaged.passUnretained(event)
    }
}
