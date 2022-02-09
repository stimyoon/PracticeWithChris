//
//  PracticeWithChrisApp.swift
//  PracticeWithChris
//
//  Created by Tim Yoon on 2/8/22.
//

import SwiftUI

@main
struct PracticeWithChrisApp: App {
    @StateObject var vm: Repository = Repository(dataService: PersonCoreDataService())
    var body: some Scene {
        WindowGroup {
            PersonListView(vm: vm)
        }
    }
}
