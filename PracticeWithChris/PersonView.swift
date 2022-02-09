//
//  AddPersonView.swift
//  PracticeWithChris
//
//  Created by Tim Yoon on 2/8/22.
//

import SwiftUI

struct PersonView: View {
    @State var person : Person
    var completion : (Person) -> Void
    @Environment(\.dismiss) var dismiss    
    
    var body: some View {
        Form{
            Group{
                TextField("last name", text: $person.lastName)
                TextField("first name", text: $person.firstName)
            }
            .padding(.horizontal)
            Button {
                completion(person)
                dismiss()
            } label: {
                Text("Save")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    init(person: Person, completion: @escaping (Person)->Void) {
        _person = State(initialValue: person)
        self.completion = completion
    }
}

struct AddPersonView_Previews: PreviewProvider {
    static var previews: some View {
        PersonView(person: Person(), completion: Repository(dataService: MockPersonDataService()).create )
    }
}
