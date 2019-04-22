//
//  Repository.swift
//  VideoFace
//
//  Created by Marco Rossi on 19/09/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxSwift
import RxRealm

protocol AbstractRepository {
    associatedtype T
    func queryAll() -> Observable<[T]>
    func query(with predicate: NSPredicate,
               sortDescriptors: [NSSortDescriptor]) -> Observable<[T]>
    func save(entity: T) -> Observable<Void>
    func save(entities: [T]) -> Observable<Void>
    func delete(entity: T) -> Observable<Void>
}

final class Repository<T:RealmRepresentable>: AbstractRepository where T == T.RealmType.DomainType, T.RealmType: Object {
    private let configuration: Realm.Configuration
    private let scheduler: RunLoopThreadScheduler
    
    private var realm: Realm {
        return try! Realm(configuration: self.configuration)
    }
    
    init(configuration: Realm.Configuration = Realm.Configuration()) {
        self.configuration = configuration
        let name = "com.cynny.videoface.RealmRepository"
        self.scheduler = RunLoopThreadScheduler(threadName: name)
        print("File 📁 url: \(RLMRealmPathForFile("default.realm"))")
    }
    
    func queryAll() -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.RealmType.self)
            
            let objs = objects.toArray()
            
            return Observable.just(objs)
                .mapToDomain()
            }
            .subscribeOn(scheduler)
    }
    
    func queryAllResults() -> Observable<Results<T.RealmType>> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.RealmType.self).sorted(byKeyPath: "createdAt", ascending: false)
            
            return Observable.collection(from: objects)
            }
            .subscribeOn(MainScheduler.instance)
    }
    
    func query(with predicate: NSPredicate,
               sortDescriptors: [NSSortDescriptor] = []) -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.RealmType.self)
            //            The implementation is broken since we are not using predicate and sortDescriptors
            //            but it cause compiler to crash with xcode 8.3 ¯\_(ツ)_/¯
            //                            .filter(predicate)
            //                            .sorted(by: sortDescriptors.map(SortDescriptor.init))
            
            return Observable.array(from: objects)
                .mapToDomain()
            }
            .subscribeOn(scheduler)
    }
    
    func save(entity: T) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.save(entity: entity)
            }.subscribeOn(scheduler)
    }
    
    func save(entities: [T]) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.save(entities: entities)
            }.subscribeOn(scheduler)
    }
    
    func delete(entity: T) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.delete(entity: entity)
            }.subscribeOn(scheduler)
    }
    
}

