import UIKit
import Messages
import SpriteKit

class MessagesViewController: MSMessagesAppViewController {
    var controller = UIViewController()

    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)

        presentVC(for: conversation, with: presentationStyle)
    }

    override func didBecomeActive(with conversation: MSConversation) {
        super.didBecomeActive(with: conversation)

        guard let message = conversation.selectedMessage else { return }

        if controller.isMember(of: GameViewController.self) {
            let isSenderSameAsRecipient = message.senderParticipantIdentifier == conversation.localParticipantIdentifier
            (controller as? GameViewController)?.scene.isUserInteractionEnabled = !isSenderSameAsRecipient
        }
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        guard let conversation = activeConversation else {
            fatalError("Expected the active conversation")
        }

        presentVC(for: conversation, with: presentationStyle)
    }
    
    private func getBoard(message: MSMessage?) -> Board {
        var setup = ""
        var activePlayer = "X"
        var gameWon = false
        guard let message = message, let url = message.url else {
            return Board(setup: setup, activePlayer: activePlayer, gameWon: gameWon, isWatch: false)
        }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            for item in components.queryItems! {
                if item.name == "setup" {
                    setup = item.value!
                    continue
                }

                if item.name == "player" {
                    activePlayer = item.value!
                    continue
                }
                
                if item.name == "gameWon" {
                    gameWon = Bool(item.value!)!
                    continue
                }
            }
        }
        
        return Board(setup: setup, activePlayer: activePlayer, gameWon: gameWon, isWatch: false)
    }

    private func presentVC(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == .compact {
            controller = instantiateMenuVC()
        } else {
            let board = getBoard(message: conversation.selectedMessage)
            controller = instantiateGameVC(with: board)
        }

        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        addChild(controller)
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)

        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        controller.didMove(toParent: self)
    }

    private func instantiateMenuVC() -> UIViewController {
        guard let menuVC = storyboard?.instantiateViewController(withIdentifier: MenuViewController.storyboardIdentifier) as? MenuViewController else {
            fatalError("Can't instantiate MenuViewController")
        }

        menuVC.delegate = self

        return menuVC
    }

    private func instantiateGameVC(with board: Board) -> UIViewController {
        guard let gameVC = storyboard?.instantiateViewController(withIdentifier: GameViewController.storyboardIdentifier) as? GameViewController else {
            fatalError("Can't instantiate GameViewController")
        }

        gameVC.board = board
        gameVC.delegate = self

        return gameVC
    }
}

extension MessagesViewController: MenuViewControllerDelegate {
    func didStartGame() {
        requestPresentationStyle(.expanded)
    }
}

extension MessagesViewController: GameViewControllerDelegate {
    func didFinishMove(player: String,
                       setup: String,
                       gameWon: Bool,
                       snapshot gameSnapshot: UIImage) {
        dismiss()

        let conversation = activeConversation
        let session = conversation?.selectedMessage?.session ?? MSSession()

        let layout = MSMessageTemplateLayout()
        layout.image = gameSnapshot

        var components = URLComponents()
        let setupQueryItem = URLQueryItem(name: "setup", value: setup)
        let playerQueryItem = URLQueryItem(name: "player", value: player)
        let gameWonQueryItem = URLQueryItem(name: "gameWon", value: String(gameWon))
        components.queryItems = [setupQueryItem, playerQueryItem, gameWonQueryItem]

        let message = MSMessage(session: session)
        message.layout = layout
        message.url = components.url
        
        if (gameWon) {
            message.summaryText = "The game has finished."
        } else {
            message.summaryText = "A move was made in tic tac toe. It's \(player)'s turn!"
        }

        conversation?.insert(message)
    }
}
