//
//  ContentView.swift
//  PracticeWithChris
//
//  Created by Tim Yoon on 2/8/22.
//

import SwiftUI

struct PersonCellView : View {
    let person : Person
    
    var body: some View {
        HStack{
            Text("\(person.lastName), ")
            Text("\(person.firstName)")
        }
    }
}

struct PersonListView: View {
    @ObservedObject var vm: Repository
    @State var person : Person = Person()
    
    var body: some View {
        NavigationView {
            List{
                Section(header: Text("people")){
                    ForEach(vm.persons) { person in
                        NavigationLink {
                            PersonView(person: person, completion: vm.update)
                        } label: {
                            PersonCellView(person: person)
                        }
                    }.onDelete(perform: vm.delete )
                }
                Section(header: Text("Chairman")) {
                    PersonCellView(person: person)
                    Picker("Chairman", selection: $person) {
                        ForEach(vm.persons, id: \.self){ person in
                            PersonCellView(person: person).tag(person)
                        }
                    }
                }
            }
            .navigationTitle("Peeps")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        PersonView(person: Person(), completion: vm.create)
                    } label: {
                        Label("Add", systemImage: "plus")
                    }

                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PersonListView(vm: Repository(dataService: MockPersonDataService()))
    }
}
