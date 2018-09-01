// swift-tools-version:3.0

import PackageDescription

let package = Package(
    name: "NordicDFU",
    targets: [
        Target(
            name: "NordicDFU"
        ),
        Target(
            name: "dfutool",
            dependencies: [
                "NordicDFU"
            ]
        )
    ],
    dependencies: [
        .Package(url: "https://github.com/PureSwift/GATT.git", majorVersion: 2),
        .Package(url: "https://github.com/PureSwift/Zip.git", majorVersion: 1)
    ],
    exclude: [
        "Assets"
    ]
)

#if swift(>=3.2)
#elseif swift(>=3.0)
package.dependencies.append(.Package(url: "https://github.com/PureSwift/Codable.git", majorVersion: 1))
#endif
