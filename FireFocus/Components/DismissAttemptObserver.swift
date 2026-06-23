import SwiftUI
import UIKit

struct DismissAttemptObserver: UIViewControllerRepresentable {
    let isEnabled: Bool
    let onAttempt: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.isEnabled = isEnabled
        context.coordinator.onAttempt = onAttempt

        DispatchQueue.main.async {
            uiViewController.parent?.presentationController?.delegate = context.coordinator
            uiViewController.parent?.isModalInPresentation = isEnabled
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isEnabled: isEnabled, onAttempt: onAttempt)
    }

    final class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var isEnabled: Bool
        var onAttempt: () -> Void

        init(isEnabled: Bool, onAttempt: @escaping () -> Void) {
            self.isEnabled = isEnabled
            self.onAttempt = onAttempt
        }

        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            !isEnabled
        }

        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
            onAttempt()
        }
    }
}

