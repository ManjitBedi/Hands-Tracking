//
//  Hands_TrackingApp.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-16.
//

import SwiftUI

@main
struct Hands_TrackingApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .defaultSize(width: 375, height: 600)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            if appModel.selectedContent == .AirGuitar {
                AirGuitarImmersiveView()
                    .environment(appModel)
                    .onAppear {
                        appModel.immersiveSpaceState = .open
                    }
                    .onDisappear {
                        appModel.immersiveSpaceState = .closed
                    }
            } else {
                GrabThrowView()
                    .environment(appModel)
                    .onAppear {
                        appModel.immersiveSpaceState = .open
                    }
                    .onDisappear {
                        appModel.immersiveSpaceState = .closed
                    }

            }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
