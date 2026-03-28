//
//  OrbitApp.swift
//  Orbit
//
//  Created by Ahmed Gaafar on 25/03/2026.
//
//TODO: Remaining to add a menu bar icon
import SwiftUI

@main
struct OrbitApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
