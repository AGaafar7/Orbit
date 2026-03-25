//
//  OrbitApp.swift
//  Orbit
//
//  Created by Ahmed Gaafar on 25/03/2026.
//
//TODO: Remaining to add a menu bar icon and make icon for this app

import SwiftUI

@main
struct OrbitApp: App {
    // Attach our AppKit delegate to handle background lifecycle and permissions
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Using Settings prevents a main window from spawning automatically
        Settings {
            EmptyView()
        }
    }
}
