//
//  FileReaderPublisher.swift
//  Chronofile
//
//  Created by Jack He on 12/30/21.
//

import Combine
import CombineSchedulers
import Foundation

final class FileWriterSubscription<S: Subscriber>: Subscription
    where S.Input == Void, S.Failure == Error {
    // fileURL is the url of the file to write to
    private let fileUrl: URL

    private let data: Data

    private var subscriber: S?

    init(fileUrl: URL, data: Data, subscriber: S) {
        self.fileUrl = fileUrl
        self.data = data
        self.subscriber = subscriber
    }

    func request(_ demand: Subscribers.Demand) {
        if demand > 0 {
            do {
                try data.write(to: fileUrl, options: .atomic)
                _ = subscriber?.receive()
                subscriber?.receive(completion: .finished)
            }
            catch let error {
                // Failure case, this subscription finishes
                // and propagates the error
                subscriber?.receive(
                    completion: .failure(error)
                )
            }
        }
    }

    // Set the subscriber reference to nil, cancelling
    // the subscription
    func cancel() {
        subscriber = nil
    }
}

struct FileWriterPublisher: Publisher {
    typealias Output = Void

    typealias Failure = Error

    // fileURL is the url of the file to write to
    let fileURL: URL

    // Data to write to the file
    let data: Data

    func receive<S>(subscriber: S) where S : Subscriber,
        Failure == S.Failure, Output == S.Input {

        // Create a FileSubscription for the new subscriber
        // and set the file to be loaded to fileURL
        let subscription = FileWriterSubscription(
            fileUrl: fileURL,
            data: data,
            subscriber: subscriber
        )

        subscriber.receive(subscription: subscription)
    }
}
