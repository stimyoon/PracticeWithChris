//
//  AddPersonView.swift
//  PracticeWithChris
//
//  Created by Tim Yoon on 2/8/22.
//

import SwiftUI

struct AddEditPersonView: View {
    @ObservedObject var vm: Repository
    @State var person : Person
    
    let shouldCreatePerson : Bool

    @Environment(\.dismiss) var dismiss
    
    enum Mode {
        case add, edit
    }
    
    var body: some View {
        Form{
            Group{
                TextField("last name", text: $person.lastName)
                TextField("first name", text: $person.firstName)
            }
            .padding(.horizontal)
            Button {
                if shouldCreatePerson {
                    vm.create(person: person)
                }
                else {
                    vm.update(person: person)
                }
                dismiss()
            } label: {
                Text("Save")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    init(vm: Repository, edit person: Person? = nil) {
        self.vm = vm
        
        if let person = person {
            _person = State(initialValue: person)
            self.shouldCreatePerson = false
        } else {
            _person = State(initialValue: Person())
            self.shouldCreatePerson = true
        }
    }
}

struct AddPersonView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditPersonView(vm: Repository(dataService: MockPersonDataService()))
    }
}
