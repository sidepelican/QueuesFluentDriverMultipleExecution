import Foundation
import Fluent
import Queues
import Vapor
import FluentPostgresDriver
import QueuesFluentDriver
import Logging

struct EchoJob: Job {
    struct Payload: Codable {
        var p_id: String
    }

    func dequeue(_ queueContext: QueueContext, _ payload: Payload) -> EventLoopFuture<Void> {
        Self.queue.async {
            Self.dequeued.append(payload.p_id)
        }
        return queueContext.eventLoop.submit {
            queueContext.logger.info("EchoJob!", metadata: [
                "p_id": .string(payload.p_id)
            ])
        }
    }

    static let queue = DispatchQueue(label: "EchoJob")
    static var dequeued: [String] = []

    static func detectMultipleExecution() -> [String] {
        let dic = queue.sync {
            let dic = Dictionary(grouping: dequeued, by: { $0 })
            dequeued = []
            return dic
        }

        var result: [String] = []
        for (k, v) in dic {
            if v.count > 1 {
                result.append(k)
            }
        }
        return result
    }
}

@main
struct App {
    static func main() throws {
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 32)
        let app = Application(.development, .shared(elg))
        app.logger = Logger(label: "main")

        app.databases.use(.postgres(configuration: PostgresConfiguration(
            hostname: "127.0.0.1",
            username: "admin",
            password: "admin",
            database: "playground"
        )), as: .psql)
        app.migrations.add(JobModelMigrate())
        app.queues.use(.fluent(useSoftDeletes: false))
        try app.autoMigrate().wait()

        app.queues.add(EchoJob())
        try app.queues.startInProcessJobs()

        for _ in 0... {
            for _ in 0..<10 {
                let slowEventLoop = elg.next()
                _ = slowEventLoop.submit {
                    usleep(1000 * 1000)
                }
                _ = app.queues.queue(.default, on: slowEventLoop)
                    .dispatch(EchoJob.self, .init(p_id: UUID().uuidString))
                _ = slowEventLoop.submit {
                    usleep(1000 * 1000)
                }
                _ = slowEventLoop.submit {
                    usleep(1000 * 1000)
                }
                _ = slowEventLoop.submit {
                    usleep(1000 * 1000)
                }
            }
            sleep(5)
            let multipleExecutedPayloadIDs = EchoJob.detectMultipleExecution()
            for multipleExecutedPayloadID in multipleExecutedPayloadIDs {
                print("p_id=\(multipleExecutedPayloadID) is multiple executed!")
            }
            if !multipleExecutedPayloadIDs.isEmpty {
                return
            }
        }
    }
}
