import ProjectDescription

let deploymentTargets: DeploymentTargets = .iOS("15.0")

let baseSettings: SettingsDictionary = [
    "DEVELOPMENT_TEAM": "43AQ936H96",
    "EAGER_LINKING": "YES",
    "FUSE_BUILD_SCRIPT_PHASES": "YES",
    "GCC_TREAT_WARNINGS_AS_ERRORS": "NO",
    "SWIFT_TREAT_WARNINGS_AS_ERRORS": "NO",
    "SWIFT_VERSION": "5.0",
    "SWIFT_UPCOMING_FEATURE_CONCISE_MAGIC_FILE": "YES",
    "SWIFT_UPCOMING_FEATURE_DEPRECATE_APPLICATION_MAIN": "YES",
    "SWIFT_UPCOMING_FEATURE_DISABLE_OUTWARD_ACTOR_ISOLATION": "YES",
    "SWIFT_UPCOMING_FEATURE_DYNAMIC_ACTOR_ISOLATION": "YES",
    "SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES": "YES",
    "SWIFT_UPCOMING_FEATURE_GLOBAL_CONCURRENCY": "YES",
    "SWIFT_UPCOMING_FEATURE_IMPLICIT_OPEN_EXISTENTIALS": "YES",
    "SWIFT_UPCOMING_FEATURE_IMPORT_OBJC_FORWARD_DECLS": "YES",
    "SWIFT_UPCOMING_FEATURE_INFER_SENDABLE_FROM_CAPTURES": "YES",
    "SWIFT_UPCOMING_FEATURE_ISOLATED_DEFAULT_VALUES": "YES",
    "SWIFT_UPCOMING_FEATURE_NONFROZEN_ENUM_EXHAUSTIVITY": "YES",
    "SWIFT_UPCOMING_FEATURE_REGION_BASED_ISOLATION": "YES",
    "VALIDATE_WORKSPACE": "YES"
]

let bridgingHeaderSearchPaths: [String] = [
    "$(inherited)",
    "$(SRCROOT)",
    "$(SRCROOT)/Shared",
    "$(SRCROOT)/Client",
    "$(SRCROOT)/Client/Frontend/Reader/Resources",
    "$(SRCROOT)/Client/Utils",
    "$(SRCROOT)/Account",
    "$(SRCROOT)/Storage"
]

let accountHeaderSearchPaths = bridgingHeaderSearchPaths + [
    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include",
    "$(SDKROOT)/usr/include/libxml2",
    "$(BUILD_DIR)/Release$(EFFECTIVE_PLATFORM_NAME)/include/**",
    "ThirdParty/ecec/include/**",
    "FxA/FxA/include"
]

let configurations: [Configuration] = [
    .debug(
        name: "Fennec",
        settings: [
            "DEBUG_INFORMATION_FORMAT": "dwarf",
            "SWIFT_STRICT_CONCURRENCY": "complete"
        ],
        xcconfig: "Client/Configuration/Fennec.xcconfig"
    ),
    .debug(
        name: "Fennec_Testing",
        settings: [
            "DEBUG_INFORMATION_FORMAT": "dwarf",
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "TESTING",
            "SWIFT_STRICT_CONCURRENCY": "complete"
        ],
        xcconfig: "Client/Configuration/Fennec.xcconfig"
    ),
    .debug(
        name: "Fennec_Enterprise",
        settings: [
            "SWIFT_STRICT_CONCURRENCY": "complete"
        ],
        xcconfig: "Client/Configuration/Fennec.enterprise.xcconfig"
    ),
    .release(
        name: "Firefox",
        settings: [
            "SWIFT_STRICT_CONCURRENCY": "minimal"
        ],
        xcconfig: "Client/Configuration/Firefox.xcconfig"
    ),
    .release(
        name: "FirefoxBeta",
        settings: [
            "SWIFT_STRICT_CONCURRENCY": "minimal"
        ],
        xcconfig: "Client/Configuration/FirefoxBeta.xcconfig"
    ),
    .release(
        name: "FirefoxStaging",
        settings: [
            "SWIFT_STRICT_CONCURRENCY": "minimal"
        ],
        xcconfig: "Client/Configuration/FirefoxStaging.xcconfig"
    )
]

let projectSettings = Settings.settings(
    base: baseSettings,
    configurations: configurations,
    defaultSettings: .none
)

func targetSettings(
    bridgingHeader: String? = nil,
    swiftVersion: String? = nil,
    additionalSettings: SettingsDictionary = [:],
    configurationOverrides: [String: SettingsDictionary] = [:]
) -> Settings {
    var settings = baseSettings
    if let bridgingHeader {
        settings["SWIFT_OBJC_BRIDGING_HEADER"] = .string(bridgingHeader)
    }
    if let swiftVersion {
        settings["SWIFT_VERSION"] = .string(swiftVersion)
    }
    for (key, value) in additionalSettings {
        settings[key] = value
    }
    let targetConfigurations = configurations.map { configuration -> Configuration in
        let overrides = configurationOverrides[configuration.name.rawValue] ?? [:]
        let mergedSettings = configuration.settings.merging(overrides) { _, new in new }
        switch configuration.variant {
        case .debug:
            return .debug(name: configuration.name, settings: mergedSettings, xcconfig: configuration.xcconfig)
        case .release:
            return .release(name: configuration.name, settings: mergedSettings, xcconfig: configuration.xcconfig)
        }
    }
    return .settings(
        base: settings,
        configurations: targetConfigurations,
        defaultSettings: .none
    )
}

let codePatterns = [
    "**/*.swift",
    "**/*.h",
    "**/*.m",
    "**/*.mm",
    "**/*.c",
    "**/*.cpp",
    "**/*.metal",
    "**/*.intentdefinition"
]

func sources(
    _ directories: [String],
    extra: [String] = [],
    excluding: [Path] = []
) -> SourceFilesList {
    var globs: [SourceFileGlob] = []
    for directory in directories {
        for pattern in codePatterns {
            globs.append(.glob(
                .relativeToRoot("\(directory)/\(pattern)"),
                excluding: excluding
            ))
        }
    }
    for path in extra {
        globs.append(.glob(.relativeToRoot(path)))
    }
    return .sourceFilesList(globs: globs)
}

let resourcePatterns = [
    "**/*.storyboard",
    "**/*.xib",
    "**/*.xcassets",
    "**/*.strings",
    "**/*.stringsdict",
    "**/*.xcstrings",
    "**/*.json",
    "**/*.png",
    "**/*.jpg",
    "**/*.jpeg",
    "**/*.gif",
    "**/*.pdf",
    "**/*.svg",
    "**/*.ttf",
    "**/*.otf",
    "**/*.js",
    "**/*.css",
    "**/*.html",
    "**/*.dat",
    "**/*.txt",
    "**/*.xcprivacy"
]

let plistExcludes: [Path] = [
    .relativeToRoot("**/Info.plist")
]

func resources(
    _ directories: [String],
    extra: [ResourceFileElement] = [],
    excluding: [Path] = []
) -> ResourceFileElements {
    var elements: [ResourceFileElement] = []
    let combinedExcludes = plistExcludes + excluding
    for directory in directories {
        for pattern in resourcePatterns {
            elements.append(.glob(
                pattern: .relativeToRoot("\(directory)/\(pattern)"),
                excluding: combinedExcludes
            ))
        }
        elements.append(.glob(
            pattern: .relativeToRoot("\(directory)/**/*.plist"),
            excluding: combinedExcludes
        ))
    }
    elements.append(contentsOf: extra)
    return .resources(elements)
}

func browserKit(_ name: String) -> TargetDependency {
    .project(target: name, path: "../BrowserKit")
}

func mozillaRustComponents(_ name: String) -> TargetDependency {
    .project(target: name, path: "../MozillaRustComponents")
}

let accountSourcePaths = [
    "Client/Application/ImageIdentifiers.swift",
    "Client/GeneralizedImageFetcher.swift",
    "Push/Autopush.swift",
    "Push/PushConfiguration.swift",
    "RustFxA/Avatar.swift",
    "RustFxA/PushNotificationSetup.swift",
    "RustFxA/RustFirefoxAccounts.swift",
]

let storageSourcePaths = [
    "Client/Application/ImageIdentifiers.swift",
    "Storage/CertStore.swift",
    "Storage/Clients.swift",
    "Storage/Cursor.swift",
    "Storage/DatabaseError.swift",
    "Storage/DefaultSuggestedSites.swift",
    "Storage/DiskImageStore.swift",
    "Storage/ExtensionUtils.swift",
    "Storage/FileAccessor.swift",
    "Storage/Generated/Metrics.swift",
    "Storage/MockRustKeychain.swift",
    "Storage/PageMetadata.swift",
    "Storage/PinnedSites.swift",
    "Storage/Queue.swift",
    "Storage/ReadingList.swift",
    "Storage/RecentlyClosedTabs.swift",
    "Storage/RemoteTabs.swift",
    "Storage/Rust/RustAutofill.swift",
    "Storage/Rust/RustFirefoxSuggest.swift",
    "Storage/Rust/RustFirefoxSuggestion.swift",
    "Storage/Rust/RustLogins.swift",
    "Storage/Rust/RustPlaces.swift",
    "Storage/Rust/RustRemoteTabs.swift",
    "Storage/Rust/RustShared.swift",
    "Storage/Rust/UnencryptedAddressFields.swift",
    "Storage/Rust/UnencryptedCreditCardFields.swift",
    "Storage/RustKeychain.swift",
    "Storage/SQL/BrowserDB.swift",
    "Storage/SQL/BrowserSchema.swift",
    "Storage/SQL/ReadingListSchema.swift",
    "Storage/SQL/SQLiteHistoryFactories.swift",
    "Storage/SQL/SQLitePinnedSites.swift",
    "Storage/SQL/SQLiteQueue.swift",
    "Storage/SQL/SQLiteReadingList.swift",
    "Storage/SQL/Schema.swift",
    "Storage/Sharing.swift",
    "Storage/Sites/PinnedSiteInfo.swift",
    "Storage/Sites/Site.swift",
    "Storage/Sites/SiteType.swift",
    "Storage/Sites/SponsoredSiteInfo.swift",
    "Storage/Sites/SuggestedSiteInfo.swift",
    "Storage/ThirdParty/SwiftData.swift",
    "Storage/Visit.swift",
    "Storage/ZoomLevelStore.swift",
]

let syncSourcePaths = [
    "Sync/RustSyncManagerAPI.swift",
    "Sync/SyncConstants.swift",
]

let localizationsSourcePaths = [
    "Shared/Date+relativeTimeString.swift",
    "Shared/DeviceInfo+defaultClientName.swift",
    "Shared/FSUtils.m",
    "Shared/Strings.swift",
]

let notificationServiceSourcePaths = [
    "Account/FxAPushMessageHandler.swift",
    "Client/Application/RemoteSettings/Application Services/RemoteSettingsServiceSyncCoordinator.swift",
    "Client/Frontend/Browser/Event Queue/AppEvent.swift",
    "Client/Frontend/Browser/Event Queue/EventQueue.swift",
    "Client/Utils/LocaleProvider.swift",
    "Extensions/NotificationService/NotificationPayloads.swift",
    "Extensions/NotificationService/NotificationService.swift",
    "Providers/LoginRecordExtension.swift",
    "Providers/Profile.swift",
    "Providers/RustErrors.swift",
    "Providers/RustProtocols/AutofillProvider.swift",
    "Providers/RustProtocols/LoginProvider.swift",
    "Providers/RustProtocols/PlacesProvider.swift",
    "Providers/RustProtocols/TabsProvider.swift",
    "Providers/RustSyncManager.swift",
    "Providers/SyncDisplayState.swift",
    "Push/Autopush.swift",
    "Push/PushConfiguration.swift",
    "firefox-ios-tests/Tests/ClientTests/Autofill/Mocks/MockLoginProvider.swift",
    "firefox-ios-tests/Tests/ClientTests/Mocks/MockPlaces.swift",
    "firefox-ios-tests/Tests/ClientTests/Mocks/MockRemoteTabs.swift",
]

let shareToSourcePaths = [
    "Client/Application/AccessibilityIdentifiers.swift",
    "Client/Application/ImageIdentifiers.swift",
    "Client/Application/RemoteSettings/Application Services/RemoteSettingsServiceSyncCoordinator.swift",
    "Client/Frontend/Browser/DefaultSearchPrefs.swift",
    "Client/Frontend/Browser/Event Queue/AppEvent.swift",
    "Client/Frontend/Browser/Event Queue/EventQueue.swift",
    "Client/Frontend/Browser/SearchEngines/Redux/SearchEngineModel.swift",
    "Client/Frontend/Browser/String+Punycode.swift",
    "Client/Frontend/Browser/URIFixup.swift",
    "Client/Frontend/DevicePickerTableViewCell.swift",
    "Client/Frontend/DevicePickerTableViewHeaderCell.swift",
    "Client/Frontend/Extensions/DevicePickerViewController.swift",
    "Client/Frontend/HelpView.swift",
    "Client/Frontend/HostingTableViewCell.swift",
    "Client/Frontend/InstructionsView.swift",
    "Client/Frontend/Share/SendToDeviceHelper.swift",
    "Client/Utils/LocaleProvider.swift",
    "Extensions/ShareTo/EmbeddedNavController.swift",
    "Extensions/ShareTo/InitialViewController.swift",
    "Extensions/ShareTo/SendToDevice.swift",
    "Extensions/ShareTo/ShareViewController.swift",
    "Extensions/ShareTo/UXConstants.swift",
    "Providers/LoginRecordExtension.swift",
    "Providers/Profile.swift",
    "Providers/RustErrors.swift",
    "Providers/RustProtocols/AutofillProvider.swift",
    "Providers/RustProtocols/LoginProvider.swift",
    "Providers/RustProtocols/PlacesProvider.swift",
    "Providers/RustProtocols/TabsProvider.swift",
    "Providers/RustSyncManager.swift",
    "Providers/SyncDisplayState.swift",
    "firefox-ios-tests/Tests/ClientTests/Autofill/Mocks/MockLoginProvider.swift",
    "firefox-ios-tests/Tests/ClientTests/Mocks/MockPlaces.swift",
    "firefox-ios-tests/Tests/ClientTests/Mocks/MockRemoteTabs.swift",
]

let widgetKitSourcePaths = [
    "Client/Application/ImageIdentifiers.swift",
    "Client/Frontend/Browser/DownloadHelper/DownloadLiveActivityIntent.swift",
    "Client/Frontend/Browser/PrivilegedRequest.swift",
    "Client/Frontend/InternalSchemeHandler/InternalSchemeHandler.swift",
    "WidgetKit/DownloadManager/DownloadLiveActivity.swift",
    "WidgetKit/Helpers.swift",
    "WidgetKit/ImageButtonWithLabel.swift",
    "WidgetKit/OpenTabs/OpenTabsWidget.swift",
    "WidgetKit/OpenTabs/SimpleTab.swift",
    "WidgetKit/OpenTabs/TabProvider.swift",
    "WidgetKit/QuickLink.swift",
    "WidgetKit/SearchQuickLinksMedium/SearchQuickLinks.swift",
    "WidgetKit/SearchQuickLinksSmall/SmallQuickLink.swift",
    "WidgetKit/TopSites/TopSitesProvider.swift",
    "WidgetKit/TopSites/TopSitesWidget.swift",
    "WidgetKit/UIView+extension.swift",
    "WidgetKit/WidgetKit.swift",
    "WidgetKit/Base.lproj/WidgetIntents.intentdefinition",
]

let credentialProviderSourcePaths = [
    "Client/Application/RemoteSettings/Application Services/RemoteSettingsServiceSyncCoordinator.swift",
    "Client/Extensions/UIView+Extension.swift",
    "Client/Frontend/AuthenticationManager/AppAuthenticator.swift",
    "Client/Frontend/Browser/Event Queue/AppEvent.swift",
    "Client/Frontend/Browser/Event Queue/EventQueue.swift",
    "Client/Frontend/Theme/PrivateModeUI.swift",
    "Client/Frontend/UIConstants.swift",
    "Client/Utils/Layout.swift",
    "Client/Utils/LocaleProvider.swift",
    "CredentialProvider/Cells/EmptyPlaceholderCell.swift",
    "CredentialProvider/Cells/ItemListCell.swift",
    "CredentialProvider/Cells/NoSearchResultCell.swift",
    "CredentialProvider/Cells/SelectPasswordCell.swift",
    "CredentialProvider/CredentialListPresenter.swift",
    "CredentialProvider/CredentialListViewController.swift",
    "CredentialProvider/CredentialPasscodeRequirementViewController.swift",
    "CredentialProvider/CredentialProviderPresenter.swift",
    "CredentialProvider/CredentialProviderViewController.swift",
    "CredentialProvider/CredentialWelcomeViewController.swift",
    "CredentialProvider/Extensions/UIFontExtension.swift",
    "CredentialProvider/Extensions/UIImageExtension.swift",
    "Providers/LoginRecordExtension.swift",
    "Providers/Profile.swift",
    "Providers/RustErrors.swift",
    "Providers/RustProtocols/AutofillProvider.swift",
    "Providers/RustProtocols/LoginProvider.swift",
    "Providers/RustProtocols/PlacesProvider.swift",
    "Providers/RustProtocols/TabsProvider.swift",
    "Providers/RustSyncManager.swift",
    "Providers/SyncDisplayState.swift",
    "firefox-ios-tests/Tests/ClientTests/Autofill/Mocks/MockLoginProvider.swift",
    "firefox-ios-tests/Tests/ClientTests/Mocks/MockPlaces.swift",
    "firefox-ios-tests/Tests/ClientTests/Mocks/MockRemoteTabs.swift",
]

let clientExtraSourcePaths = [
    "Account/FxAPushMessageHandler.swift",
    "firefox-ios-tests/Tests/ClientTests/Autofill/Mocks/MockCreditCardProvider.swift",
    "firefox-ios-tests/Tests/ClientTests/Autofill/Mocks/MockLoginProvider.swift",
    "firefox-ios-tests/Tests/ClientTests/Mocks/MockPlaces.swift",
    "firefox-ios-tests/Tests/ClientTests/Mocks/MockRemoteTabs.swift",
    "firefox-ios-tests/Tests/ClientTests/OnboardingTests/Helpers/NimbusOnboardingTestingConfigUtility.swift",
    "firefox-ios-tests/Tests/ClientTests/Search/MockRustFirefoxSuggest.swift",
    "Extensions/NotificationService/NotificationPayloads.swift",
    "RustFxA/FirefoxAccountSignInViewController.swift",
    "RustFxA/FxAEntryPoint.swift",
    "RustFxA/FxALaunchParams.swift",
    "RustFxA/FxASignInViewParameters.swift",
    "RustFxA/FxAWebViewController.swift",
    "RustFxA/FxAWebViewModel.swift",
    "RustFxA/FxAWebViewTelemetry.swift",
    "WidgetKit/DownloadManager/DownloadLiveActivity.swift",
    "WidgetKit/OpenTabs/SimpleTab.swift",
]

let updateVersionScript = #"""
#!/bin/sh

VERSION_FILE="${SRCROOT}/../version.txt"
XCCONFIG_FILE="${SRCROOT}/Client/Configuration/version.xcconfig"

# Read version from file
if [ -f "$VERSION_FILE" ]; then
    FULL_VERSION=$(tr -d '[:space:]' < "$VERSION_FILE")
else
    echo "Error: version.txt not found!"
    exit 1
fi

# Extract only numeric parts (e.g., "123.0" from "123.0b2")
VERSION_NUMBER=$(echo "$FULL_VERSION" | sed -E 's/^([0-9]+(\.[0-9]+)*).*/\1/')

# Update the xcconfig file with the version number
echo "APP_VERSION = $VERSION_NUMBER" > "$XCCONFIG_FILE"

echo "Updated Version.xcconfig with version: $VERSION_NUMBER"
"""#

let gleanGeneratorScript = """
OUTPUT_DIR="${SRCROOT}/Client/Generated/Metrics/"
# remove old Metrics file if present
rm "${SRCROOT}/Client/Generated/Metrics/Metrics.swift"
bash $PWD/bin/sdk_generator.sh -g Glean -o $OUTPUT_DIR
"""

let nimbusGeneratorScript = """
if [ "$ACTION" != "indexbuild" ]; then
    /usr/bin/env -i HOME=$HOME PROJECT=$PROJECT CONFIGURATION=$CONFIGURATION SOURCE_ROOT=$SOURCE_ROOT bash "$SOURCE_ROOT/bin/nimbus-fml.sh" --verbose
fi
"""

let optionalResourcesScript = """
## Add setting bundle to app bundle
if [ "${INCLUDE_SETTINGS_BUNDLE}" = "YES" ]; then
    cp -r "${PROJECT_DIR}/${TARGET_NAME}/Application/Settings.bundle" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"
fi

## copy debug files to app bundle
if [ "$CONFIGURATION" = "Fennec" ]; then
    cp -R "${PROJECT_DIR}/${TARGET_NAME}/Assets/Debug/" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/"
fi
"""

let accountSources = SourceFilesList.paths(accountSourcePaths.map { .relativeToRoot($0) })
let storageSources = SourceFilesList.paths(storageSourcePaths.map { .relativeToRoot($0) })
let syncSources = SourceFilesList.paths(syncSourcePaths.map { .relativeToRoot($0) })
let localizationsSources = SourceFilesList.paths(localizationsSourcePaths.map { .relativeToRoot($0) })
let notificationServiceSources = SourceFilesList.paths(notificationServiceSourcePaths.map { .relativeToRoot($0) })
let shareToSources = SourceFilesList.paths(shareToSourcePaths.map { .relativeToRoot($0) })
let widgetKitSources = SourceFilesList.paths(widgetKitSourcePaths.map { .relativeToRoot($0) })
let credentialProviderSources = SourceFilesList.paths(credentialProviderSourcePaths.map { .relativeToRoot($0) })

let clientSources = sources(
    ["Client", "Providers", "Push", "FxA", "ThirdParty"],
    extra: clientExtraSourcePaths,
    excluding: [
        .relativeToRoot("Client/Frontend/Browser/PrivateModeButton.swift"),
        .relativeToRoot("Client/Frontend/Browser/TranslationToastHandler.swift"),
        .relativeToRoot("Client/Frontend/Browser/Tabs/State/TabViewState.swift"),
        .relativeToRoot("Client/Frontend/Settings/Main/Support/StudiesToggleSetting.swift"),
        .relativeToRoot("ThirdParty/Deferred/DeferredTests/**"),
        .relativeToRoot("ThirdParty/Deferred/DeferredMacTests/**"),
        .relativeToRoot("ThirdParty/ecec/test/**"),
        .relativeToRoot("ThirdParty/ecec/tool/**")
    ]
)

let clientResourceExcludes: [Path] = [
    .relativeToRoot("Client/ContentBlocker/TrackingProtectionStats.js"),
    .relativeToRoot("Client/Frontend/UserContent/UserScripts/TranslationsEngine/TranslationsEngine.js"),
    .relativeToRoot("Client/Assets/CC_Script/translations-engine.worker.js"),
    .relativeToRoot("Client/Frontend/UserContent/UserScripts/AllFrames/AtDocumentStart/__firefox__.js"),
    .relativeToRoot("Client/Frontend/UserContent/UserScripts/AllFrames/AtDocumentEnd/__firefox__.js"),
    .relativeToRoot("Client/Frontend/UserContent/UserScripts/AllFrames/NightModeAtDocumentStart/__firefox__.js"),
]

let clientResources = resources(
    ["Client", "ThirdParty"],
    extra: [
        .folderReference(path: .relativeToRoot("Client/Application/Settings.bundle")),
        .glob(pattern: .relativeToRoot("PrivacyInfo.xcprivacy"))
    ],
    excluding: clientResourceExcludes
)

let localizationsResources = resources(["Shared"])

let notificationServiceResources = resources(
    ["Extensions/NotificationService"],
    extra: [.glob(pattern: .relativeToRoot("PrivacyInfo.xcprivacy"))]
)

let shareToResources = resources(
    ["Extensions/ShareTo"],
    extra: [.glob(pattern: .relativeToRoot("PrivacyInfo.xcprivacy"))]
)

let widgetKitResources = resources(
    ["WidgetKit"],
    extra: [.glob(pattern: .relativeToRoot("PrivacyInfo.xcprivacy"))]
)

let credentialProviderResources = resources(
    ["CredentialProvider"],
    extra: [.glob(pattern: .relativeToRoot("PrivacyInfo.xcprivacy"))]
)

let actionExtensionResources = resources(["Extensions/ActionExtension"])
let stickerResources: ResourceFileElements = .resources([
    .glob(pattern: .relativeToRoot("sticker/**/*.xcstickers"))
])

let clientScripts: [TargetScript] = [
    .pre(script: updateVersionScript, name: "Update Version"),
    .pre(
        script: gleanGeneratorScript,
        name: "Glean SDK Generator Script",
        inputPaths: [
            .glob(.relativeToRoot("Client/Glean/probes/*.yaml")),
            .glob(.relativeToRoot("Storage/metrics.yaml")),
            .glob(.relativeToRoot("Client/Glean/pings.yaml")),
            .glob(.relativeToRoot("Client/Glean/tags.yaml"))
        ],
        outputPaths: [
            .relativeToRoot("Client/Generated/Metrics/Metrics.swift")
        ]
    ),
    .pre(script: nimbusGeneratorScript, name: "Nimbus Feature Manifest Generator Script"),
    .post(script: optionalResourcesScript, name: "Conditionally Add Optional Resources")
]

let clientDependencies: [TargetDependency] = [
    .target(name: "Account"),
    .target(name: "Sync"),
    .target(name: "Localizations"),
    mozillaRustComponents("MozillaAppServices"),
    .target(name: "CredentialProvider"),
    .target(name: "NotificationService"),
    .target(name: "ShareTo"),
    .target(name: "WidgetKitExtension"),
    .target(name: "Sticker"),
    .target(name: "ActionExtension"),
    .external(name: "GCDWebServers"),
    .external(name: "Glean"),
    .external(name: "Adjust"),
    .external(name: "Fuzi"),
    browserKit("SiteImageView"),
    .external(name: "SnapKit"),
    browserKit("Common"),
    browserKit("TabDataStore"),
    browserKit("Redux"),
    browserKit("ComponentLibrary"),
    .external(name: "Lottie"),
    .external(name: "X509"),
    browserKit("ToolbarKit"),
    .external(name: "Kingfisher"),
    browserKit("MenuKit"),
    browserKit("UnifiedSearchKit"),
    browserKit("WebEngine"),
    .external(name: "Sentry-Dynamic"),
    browserKit("Shared"),
    browserKit("OnboardingKit"),
    browserKit("SummarizeKit"),
    .sdk(name: "Accelerate", type: .framework),
    .sdk(name: "AdServices", type: .framework),
    .sdk(name: "AdSupport", type: .framework),
    .sdk(name: "AuthenticationServices", type: .framework),
    .sdk(name: "ImageIO", type: .framework),
    .sdk(name: "PassKit", type: .framework),
    .sdk(name: "SafariServices", type: .framework),
    .sdk(name: "iAd", type: .framework),
    .sdk(name: "xml2", type: .library),
    .sdk(name: "z", type: .library)
]

let project = Project(
    name: "Client",
    settings: projectSettings,
    targets: [
        Target.target(
            name: "Client",
            destinations: .iOS,
            product: .app,
            bundleId: "org.mozilla.ios.Fennec",
            deploymentTargets: deploymentTargets,
            infoPlist: .file(path: "Client/Info.plist"),
            sources: clientSources,
            resources: clientResources,
            entitlements: .file(path: "Client/Entitlements/FennecApplication.entitlements"),
            scripts: clientScripts,
            dependencies: clientDependencies,
            settings: targetSettings(
                bridgingHeader: "Client/Client-Bridging-Header.h",
                additionalSettings: [
                    "HEADER_SEARCH_PATHS": .array(bridgingHeaderSearchPaths)
                ],
                configurationOverrides: [
                    "Fennec": [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": ""
                    ],
                    "Fennec_Testing": [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "TESTING"
                    ],
                    "Fennec_Enterprise": [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": ""
                    ]
                ]
            )
        ),
        Target.target(
            name: "Account",
            destinations: .iOS,
            product: .staticLibrary,
            bundleId: "org.mozilla.ios.Account",
            deploymentTargets: deploymentTargets,
            infoPlist: .file(path: "Account/Info.plist"),
            sources: accountSources,
            dependencies: [
                .target(name: "Storage"),
                .target(name: "Localizations"),
                .external(name: "GCDWebServers"),
                mozillaRustComponents("MozillaAppServices")
            ],
            settings: targetSettings(
                bridgingHeader: "Account/Account-Bridging-Header.h",
                swiftVersion: "6.0",
                additionalSettings: [
                    "HEADER_SEARCH_PATHS": .array(accountHeaderSearchPaths),
                    "LIBRARY_SEARCH_PATHS": .array([
                        "$(inherited)",
                        "$(PROJECT_DIR)/FxA/FxA/lib"
                    ])
                ]
            )
        ),
        Target.target(
            name: "Storage",
            destinations: .iOS,
            product: .staticLibrary,
            bundleId: "org.mozilla.ios.Storage",
            deploymentTargets: deploymentTargets,
            infoPlist: .file(path: "Storage/Info.plist"),
            sources: storageSources,
            dependencies: [
                .target(name: "Localizations"),
                .external(name: "GCDWebServers"),
                .external(name: "Kingfisher"),
                browserKit("Shared"),
                browserKit("SiteImageView"),
                browserKit("Common"),
                mozillaRustComponents("MozillaAppServices")
            ],
            settings: targetSettings(
                bridgingHeader: "Storage/Storage-Bridging-Header.h",
                swiftVersion: "6.0",
                additionalSettings: [
                    "HEADER_SEARCH_PATHS": .array(bridgingHeaderSearchPaths)
                ]
            )
        ),
        Target.target(
            name: "Sync",
            destinations: .iOS,
            product: .framework,
            bundleId: "org.mozilla.ios.Sync",
            deploymentTargets: deploymentTargets,
            infoPlist: .file(path: "Sync/Info.plist"),
            sources: syncSources,
            dependencies: [
                .target(name: "Account"),
                .target(name: "Localizations"),
                browserKit("Shared"),
                browserKit("SiteImageView"),
                browserKit("Common"),
                .external(name: "Fuzi"),
                mozillaRustComponents("MozillaAppServices")
            ],
            settings: targetSettings(
                bridgingHeader: "Sync/Sync-Bridging-Header.h",
                swiftVersion: "6.0",
                additionalSettings: [
                    "HEADER_SEARCH_PATHS": .array(bridgingHeaderSearchPaths),
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        ),
        Target.target(
            name: "Localizations",
            destinations: .iOS,
            product: .framework,
            bundleId: "org.mozilla.ios.Localizations",
            deploymentTargets: deploymentTargets,
            infoPlist: .file(path: "Shared/Supporting Files/Info.plist"),
            sources: localizationsSources,
            resources: localizationsResources,
            dependencies: [
                browserKit("Common"),
                .external(name: "GCDWebServers"),
                browserKit("WebEngine"),
                browserKit("Shared")
            ],
            settings: targetSettings(
                bridgingHeader: "Shared/Shared-Bridging-Header.h",
                swiftVersion: "6.0",
                additionalSettings: [
                    "HEADER_SEARCH_PATHS": .array(bridgingHeaderSearchPaths),
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        ),
        Target.target(
            name: "NotificationService",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "org.mozilla.ios.Fennec.NotificationService",
            deploymentTargets: deploymentTargets,
            infoPlist: .file(path: "Extensions/NotificationService/Info.plist"),
            sources: notificationServiceSources,
            resources: notificationServiceResources,
            entitlements: .file(path: "Extensions/Entitlements/Fennec.entitlements"),
            dependencies: [
                .target(name: "Sync"),
                .target(name: "Localizations"),
                browserKit("Common"),
                browserKit("Shared"),
                mozillaRustComponents("MozillaAppServices")
            ],
            settings: targetSettings(
                swiftVersion: "6.0",
                additionalSettings: [
                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": .string("$(inherited) MOZ_TARGET_NOTIFICATIONSERVICE")
                ]
            )
        ),
        Target.target(
            name: "ShareTo",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "org.mozilla.ios.Fennec.ShareTo",
            deploymentTargets: deploymentTargets,
            infoPlist: .file(path: "Extensions/ShareTo/Info.plist"),
            sources: shareToSources,
            resources: shareToResources,
            entitlements: .file(path: "Extensions/Entitlements/Fennec.entitlements"),
            dependencies: [
                .target(name: "Localizations"),
                .target(name: "Sync"),
                .external(name: "SnapKit"),
                browserKit("Common"),
                browserKit("Shared"),
                .external(name: "Fuzi"),
                mozillaRustComponents("MozillaAppServices"),
                .sdk(name: "ImageIO", type: .framework)
            ],
            settings: targetSettings(
                swiftVersion: "6.0",
                additionalSettings: [
                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": .string("$(inherited) MOZ_TARGET_SHARETO")
                ]
            )
        ),
        Target.target(
            name: "WidgetKitExtension",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "org.mozilla.ios.Fennec.WidgetKit",
            deploymentTargets: deploymentTargets,
            infoPlist: .file(path: "WidgetKit/Info.plist"),
            sources: widgetKitSources,
            resources: widgetKitResources,
            entitlements: .file(path: "Extensions/Entitlements/Fennec.entitlements"),
            dependencies: [
                .target(name: "Localizations"),
                .target(name: "Storage"),
                .external(name: "GCDWebServers"),
                .external(name: "Fuzi"),
                browserKit("Common"),
                browserKit("SiteImageView"),
                browserKit("TabDataStore"),
                browserKit("Shared"),
                .sdk(name: "SwiftUI", type: .framework),
                .sdk(name: "WidgetKit", type: .framework)
            ],
            settings: targetSettings(swiftVersion: "6.0")
        ),
        Target.target(
            name: "CredentialProvider",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "org.mozilla.ios.Fennec.CredentialProvider",
            deploymentTargets: deploymentTargets,
            infoPlist: .file(path: "CredentialProvider/Info.plist"),
            sources: credentialProviderSources,
            resources: credentialProviderResources,
            entitlements: .file(path: "CredentialProvider/CredentialProviderFennec.entitlements"),
            dependencies: [
                .target(name: "Localizations"),
                .target(name: "Sync"),
                .external(name: "SnapKit"),
                browserKit("Common"),
                browserKit("Shared"),
                mozillaRustComponents("MozillaAppServices"),
                .sdk(name: "AuthenticationServices", type: .framework)
            ],
            settings: targetSettings(
                swiftVersion: "6.0",
                additionalSettings: [
                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": .string("$(inherited) MOZ_TARGET_CREDENTIAL_PROVIDER")
                ]
            )
        ),
        Target.target(
            name: "Sticker",
            destinations: .iOS,
            product: .stickerPackExtension,
            bundleId: "org.mozilla.ios.Fennec.Sticker",
            deploymentTargets: deploymentTargets,
            infoPlist: .file(path: "sticker/Info.plist"),
            resources: stickerResources,
            settings: targetSettings(swiftVersion: "6.0")
        ),
        Target.target(
            name: "ActionExtension",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "org.mozilla.ios.Fennec.ActionExtension",
            deploymentTargets: deploymentTargets,
            infoPlist: .file(path: "Extensions/ActionExtension/Info.plist"),
            sources: sources(["Extensions/ActionExtension"]),
            resources: actionExtensionResources,
            entitlements: .file(path: "Extensions/Entitlements/Fennec.entitlements"),
            dependencies: [
                browserKit("ActionExtensionKit"),
                .sdk(name: "UniformTypeIdentifiers", type: .framework)
            ],
            settings: targetSettings(swiftVersion: "6.0")
        )
    ],
    resourceSynthesizers: []
)
