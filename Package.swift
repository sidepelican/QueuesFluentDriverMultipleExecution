// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "QueuesFluentDriverMultipleExecution",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "App", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/queues", from: "1.11.1"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver", from: "2.2.6"),
        .package(url: "https://github.com/vapor/fluent", from: "4.4.0"),
        .package(url: "https://github.com/vapor/postgres-kit", from: "2.9.0"),
        .package(url: "https://github.com/m-barthelemy/vapor-queues-fluent-driver", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "PostgresKit", package: "postgres-kit"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Queues", package: "queues"),
                .product(name: "QueuesFluentDriver", package: "vapor-queues-fluent-driver"),
            ]
        ),
    ]
)
