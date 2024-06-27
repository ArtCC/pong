//
//  MultiplayerManager.swift
//  pong
//
//  Created by Arturo Carretero Calvo on 18/5/24.
//

import GameKit

class MultiplayerManager: NSObject, GKMatchmakerViewControllerDelegate, GKMatchDelegate {
    // MARK: - Properties

    static let shared = MultiplayerManager()

    var match: GKMatch?
    var presentingViewController: UIViewController?

    // MARK: - Public

    func findMatch(minPlayers: Int, maxPlayers: Int, presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController

        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers

        let matchmakerViewController = GKMatchmakerViewController(matchRequest: request)
        matchmakerViewController?.matchmakerDelegate = self

        presentingViewController.present(matchmakerViewController!, animated: true, completion: nil)
    }

    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        presentingViewController?.dismiss(animated: true, completion: nil)

        print("Error finding match: \(error.localizedDescription)")
    }

    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        presentingViewController?.dismiss(animated: true, completion: nil)

        self.match = match

        match.delegate = self

        if match.expectedPlayerCount == 0 {
            startMatch()
        }
    }

    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            if match.expectedPlayerCount == 0 {
                startMatch()
            }
        case .disconnected:
            print("Player disconnected")
        default:
            break
        }
    }

    func startMatch() {
        NotificationCenter.default.post(name: NSNotification.Name("StartGame"), object: nil)
    }

    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
    }
}
