// swift-tools-version:3.0

import PackageDescription

let package = Package(
    name: "NordicDFU",
    targets: [
        Target(
            name: "NordicDFU"
        )
    ],
    
    dependencies: [
        .Package(url: "https://github.com/PureSwift/GATT.git", majorVersion: 2)
    ]
)
