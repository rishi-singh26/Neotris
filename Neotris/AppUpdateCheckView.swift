//
//  AppUpdateCheckView.swift
//  Neotris
//
//  Created by Rishi Singh on 12/04/26.
//

import SwiftUI

struct AppUpdateCheckView: View {
    @Environment(RemoteDataService.self) private var remoteDataService
    @State private var updateAppInfo: VersionCheckService.ReturnResult?
    @State private var forcedUpdate: Bool = false
    
    var body: some View {
        TetrisGameView()
            .navigationTitle("App Update")
            .sheet(item: $updateAppInfo, content: { info in
                AppUpdateView(appInfo: info, forcedUpdate: forcedUpdate)
            })
            .task {
                if let result = await VersionCheckService.shared.checkIfAppUpdateAvailable() {
                    updateAppInfo = result
                }
                //else {
                //    print("No Updates Available")
                //}
            }
            .task {
                await remoteDataService.fetchAllData()
            }
    }
}

#Preview {
    AppUpdateCheckView()
}
