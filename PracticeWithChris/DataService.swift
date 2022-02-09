//
//  DataService.swift
//  PracticeWithChris
//
//  Created by Tim Yoon on 2/8/22.
//

import Foundation
import Combine
import CoreData

struct Person : Identifiable, Hashable {
    var id : String? = UUID().uuidString
    var firstName: String = ""
    var lastName: String = ""
}

protocol PersonDataServiceProtocol {
    func getData() -> AnyPublisher<[Person], Error>
    func create(person: Person)
    func update(person: Person)
    func delete(person: Person)
}

class MockPersonDataService : PersonDataServiceProtocol {
    @Published var persons : [Person] = []
    
    func getData() -> AnyPublisher<[Person], Error> {
        $persons.tryMap({$0}).eraseToAnyPublisher()
    }
    
    func create(person: Person) {
        persons.append(person)
    }
    
    func update(person: Person) {
        guard let index = persons.firstIndex(where: {$0.id == person.id }) else { return }
        persons[index] = person
    }
    
    func delete(person: Person) {
        guard let index = persons.firstIndex(where: {$0.id == person.id }) else { return }
        
        persons.remove(at: index)
    }
    init(){
        self.persons = [
            Person(firstName: "Chris", lastName: "Yoon"),
            Person(firstName: "John", lastName: "Smith")
        ]
    }
}

class PersonCoreDataService : PersonDataServiceProtocol {
    @Published private (set) var persons : [Person] = []
    @Published private var personEntities : [PersonEntity] = []
    let manager = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()

    func fetch() {
        let request = NSFetchRequest<PersonEntity>(entityName: "PersonEntity")
        let sort = [NSSortDescriptor(key: "lastName", ascending: true),
                    NSSortDescriptor(key: "firstName", ascending: true)
                    ]
        request.sortDescriptors = sort
        do {
            personEntities = try manager.context.fetch(request)
        } catch let error {
            fatalError("Unable to fetch from coredata: \(error)")
        }
    }
    init(){
        fetch()
        $personEntities
            .map({ personEntities in
                personEntities.map { (personEntity) -> Person     in
                    var person = Person()
                    person.id = personEntity.id
                    person.firstName = personEntity.firstName ?? ""
                    person.lastName = personEntity.lastName ?? ""
                    return person
                }
            })
            .sink { error in
                fatalError("Unable to sink: \(error)")
            } receiveValue: { [weak self] persons in
                self?.persons = persons
            }
            .store(in: &cancellables)
    }
    
    func getData() -> AnyPublisher<[Person], Error> {
        $persons.tryMap({$0}).eraseToAnyPublisher()
    }
    
    func create(person: Person) {
        let entity = PersonEntity(context: manager.context)
        entity.id = person.id
        entity.firstName = person.firstName
        entity.lastName = person.lastName
        manager.save()
        fetch()
    }
    
    func update(person: Person) {
        guard let index = persons.firstIndex(where: {$0.id == person.id}) else { return }
        let entity = personEntities[index]
        entity.id = person.id
        entity.firstName = person.firstName
        entity.lastName = person.lastName
        manager.save()
        fetch()
    }
    
    func delete(person: Person) {
        guard let index = persons.firstIndex(where: {$0.id == person.id}) else { return }
        manager.context.delete(personEntities[index])
        manager.save()
        fetch()
    }
}

class Repository : ObservableObject {
    @Published var persons : [Person] = []
    var dataService : PersonDataServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    func create(person: Person) {
        dataService.create(person: person)
    }
    func update(person: Person) {
        dataService.update(person: person)
    }
    func delete(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        dataService.delete(person: persons[index])
    }
    
    init(dataService: PersonDataServiceProtocol){
        self.dataService = dataService
        dataService.getData()
            .sink { error in
                fatalError("Could not get data from DataService: \(error)")
            } receiveValue: { [weak self] persons in
                self?.persons = persons
            }
            .store(in: &cancellables)
    }
}
