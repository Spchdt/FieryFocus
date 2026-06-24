# FieryFocus

FieryFocus is a time tracking tool designed to help you stay focused during your sessions. With its intuitive features, you can create customized focuses, track your statistics, and personalize your sessions. It's completely free and ad-free. View a video demo here on [Youtube](https://youtu.be/x1z1u7A7f5A).

## Key Features

- **Track your time and stay focused**: FieryFocus allows you to track your time and ensure that you stay focused during your sessions. By keeping an eye on your progress, you can improve your productivity and manage your time effectively.
- **Customize your focuses**: Personalize your sessions by creating custom focuses that align with your tasks or goals. Whether you're studying, working, or pursuing a hobby, you can tailor your focus to suit your needs with various colors and icons.
- **Live Activities & Dynamic Island**: See your timer at a glance on the Lock Screen and Dynamic Island without opening the app. Play, pause, and stop directly from the Live Activity.
- **History feature**: With FieryFocus, you can easily view your past sessions and track your progress over time. The history feature provides valuable insights into your productivity and helps you identify areas for improvement.
- **Simplicity at its core**: We've designed FieryFocus with simplicity in mind. The user-friendly interface ensures a seamless experience, allowing you to focus on what matters most without any distractions.

## Background

One thing FieryFocus does is make it way easier to stay focused and manage your time during work or study sessions. Lots of people have trouble keeping their concentration and avoiding distractions, which really messes with their productivity. But with FieryFocus, you can keep an eye on your progress and make changes as needed to stay on track.

FieryFocus also lets you look back on past sessions and see how you've been doing over time. It's got this history feature that lets you easily see your progress and figure out where you can make improvements. It's a great way to get some insight and figure out how to be even more productive in the future.

Overall, FieryFocus is all about making it easier to stay focused, personalizing your time tracking, and giving you a way to track your progress. It's got a user-friendly interface and customizable features, all aimed at helping you improve your focus and productivity.

## Tech Stack

- **SwiftUI** — UI framework
- **SwiftData** — local persistence with iCloud sync via CloudKit
- **AlarmKit** — powers the timer with Live Activities and Dynamic Island support
- **MVVM** architecture with `@Observable` ViewModels

## Building Locally

1. Clone the repo and open `FieryFocus.xcodeproj` in Xcode 16+.
2. In **Signing & Capabilities**, replace the team and bundle identifier with your own Apple Developer account details.
3. The app uses **CloudKit** for iCloud sync. You'll need to create your own CloudKit container in the [Apple Developer portal](https://developer.apple.com) and update the container identifier in the entitlements file, or remove the CloudKit entitlement entirely if you don't need iCloud sync.
4. Build and run on a real device (AlarmKit and Live Activities are not supported in the Simulator).

> **Note:** The `DEVELOPMENT_TEAM` and `PRODUCT_BUNDLE_IDENTIFIER` values in `project.pbxproj` are left in as placeholders — you'll need to replace them with your own.

## Get FieryFocus

FieryFocus is available for download on the [App Store](https://apps.apple.com/us/app/fieryfocus-timer-and-focus/id6470216311). It's an open-source application, ensuring transparency and eliminating any privacy concerns.
