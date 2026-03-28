//
//  OrbitAppInfo.swift
//  Orbit
//
//  Created by Ahmed Gaafar on 25/03/2026.
//

import Cocoa

struct OrbitAppInfo: Identifiable, Equatable {
    let id: pid_t
    let runningApp: NSRunningApplication
    let name: String
    let icon: NSImage
    
    static func == (lhs: OrbitAppInfo, rhs: OrbitAppInfo) -> Bool {
        lhs.id == rhs.id
    }
}

class OrbitAppFetcher {
    static func fetchRunningApps() -> [OrbitAppInfo] {
        let myBundleId = Bundle.main.bundleIdentifier ?? ""
        
        let apps = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular && $0.bundleIdentifier != myBundleId
        }
        
        let sortedApps = apps.sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
        
        return sortedApps.compactMap { app in
            guard let name = app.localizedName, let icon = app.icon else { return nil }
            return OrbitAppInfo(id: app.processIdentifier, runningApp: app, name: name, icon: icon)
        }
    }
}
