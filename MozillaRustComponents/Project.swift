import ProjectDescription

let deploymentTargets = DeploymentTargets.iOS("15.0")

let configurations: [Configuration] = [
    .debug(name: "Fennec", xcconfig: "../firefox-ios/Client/Configuration/Fennec.xcconfig"),
    .debug(name: "Fennec_Testing", xcconfig: "../firefox-ios/Client/Configuration/Fennec.xcconfig"),
    .debug(name: "Fennec_Enterprise", xcconfig: "../firefox-ios/Client/Configuration/Fennec.enterprise.xcconfig"),
    .release(name: "Firefox", xcconfig: "../firefox-ios/Client/Configuration/Firefox.xcconfig"),
    .release(name: "FirefoxBeta", xcconfig: "../firefox-ios/Client/Configuration/FirefoxBeta.xcconfig"),
    .release(name: "FirefoxStaging", xcconfig: "../firefox-ios/Client/Configuration/FirefoxStaging.xcconfig")
]

let baseSettings: SettingsDictionary = [
    "SWIFT_VERSION": "6.0"
]

let projectSettings = Settings.settings(
    base: baseSettings,
    configurations: configurations,
    defaultSettings: .recommended
)

func targetSettings(additional: SettingsDictionary = [:]) -> Settings {
    var settings = baseSettings
    for (key, value) in additional {
        settings[key] = value
    }
    return .settings(
        base: settings,
        configurations: configurations,
        defaultSettings: .recommended
    )
}

func sourceFiles(_ path: String) -> SourceFilesList {
    .sourceFilesList(globs: [.glob(.relativeToManifest("\(path)/**/*.swift"))])
}

let project = Project(
    name: "MozillaRustComponents",
    settings: projectSettings,
    targets: [
        Target.target(
            name: "MozillaAppServices",
            destinations: .iOS,
            product: .framework,
            bundleId: "org.mozilla.rustcomponents.MozillaAppServices",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: sourceFiles("Sources/MozillaRustComponentsWrapper"),
            dependencies: [
                .xcframework(path: .relativeToManifest("Binaries/MozillaRustComponents.xcframework")),
                .external(name: "Glean")
            ],
            settings: targetSettings(
                additional: [
                    "SWIFT_VERSION": "5.10",
                    "SWIFT_STRICT_CONCURRENCY": "minimal",
                    "OTHER_LDFLAGS": .string("$(inherited) -lc++ -lswiftCompatibility56 -lswiftCompatibilityPacks"),
                    "LIBRARY_SEARCH_PATHS": .array([
                        "$(inherited)",
                        "$(DEVELOPER_DIR)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/$(PLATFORM_NAME)"
                    ])
                ]
            )
        ),
        Target.target(
            name: "FocusAppServices",
            destinations: .iOS,
            product: .framework,
            bundleId: "org.mozilla.rustcomponents.FocusAppServices",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: sourceFiles("Sources/FocusRustComponentsWrapper"),
            dependencies: [
                .xcframework(path: .relativeToManifest("Binaries/FocusRustComponents.xcframework"))
            ],
            settings: targetSettings(
                additional: [
                    "SWIFT_VERSION": "5.10",
                    "SWIFT_STRICT_CONCURRENCY": "minimal"
                ]
            )
        ),
        Target.target(
            name: "MozillaRustComponentsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "org.mozilla.rustcomponents.MozillaRustComponentsTests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: sourceFiles("Tests/MozillaRustComponentsTests"),
            dependencies: [
                .target(name: "MozillaAppServices")
            ],
            settings: targetSettings(
                additional: [
                    "SWIFT_VERSION": "5.10",
                    "SWIFT_STRICT_CONCURRENCY": "minimal"
                ]
            )
        )
    ],
    resourceSynthesizers: []
)
