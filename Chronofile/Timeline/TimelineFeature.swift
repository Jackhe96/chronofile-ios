//
//  LogFeature.swift
//  Chronofile
//
//  Created by Jack He on 12/28/21.
//

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import Foundation

struct TimelineState: Equatable {
    var timelineEntries: [TimelineEntry] = []
    var latitude: Double?
    var longitude: Double?
}

enum TimelineAction: Equatable {
    case onAppear
    case dataLoaded(Result<[TimelineEntry], TimelineErrors>)
    case addEntryTapped(TimelineEntry)
    case entryAdded(Result<[TimelineEntry], TimelineErrors>)
    case locationManager(LocationManager.Action)
}

struct TimelineEnvironment {
    var mainQueue: () -> AnySchedulerOf<DispatchQueue>
    var timelineRequest: (@escaping (Data) throws -> [TimelineEntry]) -> Effect<[TimelineEntry], TimelineErrors>
    var addEntryRequest: ([TimelineEntry]) -> Effect<Void, TimelineErrors>
    var parser: (Data) throws -> [TimelineEntry]
    var locationManager: LocationManager

    static func live() -> TimelineEnvironment {
        TimelineEnvironment(
            mainQueue: { .main },
            timelineRequest: loadTimeline,
            addEntryRequest: writeTimeline,
            parser: timelineParser,
            locationManager: .live
        )
    }
}

let timelineReducer = Reducer<
    TimelineState,
    TimelineAction,
    TimelineEnvironment
> { state, action, environment in
    // A unique identifier for our location manager, just in case we want to use
    // more than one in our application.
    struct LocationManagerId: Hashable {}

    switch action {
    case .onAppear:
        return .merge(
            environment.timelineRequest(environment.parser)
                .receive(on: environment.mainQueue())
                .catchToEffect()
                .map(TimelineAction.dataLoaded),
            environment.locationManager.create(id: LocationManagerId())
                  .map(TimelineAction.locationManager)
        )
    case .dataLoaded(let result):
        switch result {
        case .success(let entries):
            state.timelineEntries = entries
        case .failure(let error):
            // If the file doesn't exist yet generate one with an initial mock entry
            let mockEntry = TimelineEntry.dummyEntry(startTime: .now)
            let newTimeline = getNewTimeline(with: mockEntry, oldTimeline: [])
            return environment.addEntryRequest(newTimeline)
                .receive(on: environment.mainQueue())
                .catchToEffect()
                .map { result in
                    switch result {
                    case .success:
                        return Result.success(newTimeline)
                    case .failure(let error):
                        return Result.failure(error)
                    }
                }
                .map(TimelineAction.entryAdded)
        }
        return .none
    case .addEntryTapped(let entry):
        let newTimeline = getNewTimeline(with: entry, oldTimeline: state.timelineEntries)
        return environment.addEntryRequest(newTimeline)
            .receive(on: environment.mainQueue())
            .catchToEffect()
            .map { result in
                switch result {
                case .success:
                    return Result.success(newTimeline)
                case .failure(let error):
                    return Result.failure(error)
                }
            }
            .map(TimelineAction.entryAdded)
    case .entryAdded(let result):
        switch result {
        case .success(let timeline):
            state.timelineEntries = timeline
        case .failure(let error):
            break
        }
        return .none
    case .locationManager(.didChangeAuthorization(.authorizedAlways)),
         .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
        return environment.locationManager
            .requestLocation(id: LocationManagerId())
            .fireAndForget()
    case .locationManager(.didChangeAuthorization(.denied)),
         .locationManager(.didChangeAuthorization(.restricted)):
        state.latitude = nil
        state.longitude = nil
        return .none
    case .locationManager(.didChangeAuthorization(.notDetermined)):
        return environment.locationManager
            .requestWhenInUseAuthorization(id: LocationManagerId())
            .fireAndForget()
    case .locationManager(.didUpdateLocations(let locations)):
        guard let coordinate = locations.first?.coordinate else {
            return .none
        }
        state.latitude = coordinate.latitude
        state.longitude = coordinate.longitude
        return environment.locationManager
            .requestLocation(id: LocationManagerId())
            .fireAndForget()
    case .locationManager:
        return .none
    }
}

func getNewTimeline(with newEntry: TimelineEntry, oldTimeline: [TimelineEntry]) -> [TimelineEntry] {
    var timeline = oldTimeline
    if oldTimeline.isEmpty {
        timeline.append(newEntry)
    } else {
        let newDummyStartTime = Date.now
        timeline.removeLast()
        timeline.append(newEntry)
        timeline.append(TimelineEntry.dummyEntry(startTime: newDummyStartTime))
    }
    return timeline
}
