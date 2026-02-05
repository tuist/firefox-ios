// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "Sentry-Dynamic": .framework
    ],
    baseSettings: .settings(
        configurations: [
            .debug(name: "Fennec"),
            .debug(name: "Fennec_Testing"),
            .debug(name: "Fennec_Enterprise"),
            .release(name: "Firefox"),
            .release(name: "FirefoxBeta"),
            .release(name: "FirefoxStaging")
        ],
        defaultSettings: .recommended
    )
)
#endif

let package = Package(
    name: "FirefoxiOS",
    dependencies: [
        .package(url: "https://github.com/mozilla/glean-swift", from: "66.3.0"),
        .package(url: "https://github.com/adjust/ios_sdk.git", exact: "4.37.0"),
        .package(url: "https://github.com/nbhasin2/Fuzi.git", branch: "master"),
        .package(url: "https://github.com/AliSoftware/Dip.git", exact: "7.1.1"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", exact: "2.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", exact: "5.7.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "8.2.0"),
        .package(url: "https://github.com/nbhasin2/GCDWebServer.git", branch: "master"),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", exact: "8.36.0"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", exact: "4.4.0"),
        .package(url: "https://github.com/swhitty/SwiftDraw", exact: "0.18.3"),
        .package(url: "https://github.com/johnxnguyen/Down.git", exact: "0.11.0"),
        .package(url: "https://github.com/apple/swift-certificates.git", exact: "1.2.0")
    ]
)
