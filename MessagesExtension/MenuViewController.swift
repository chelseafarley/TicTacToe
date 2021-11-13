import UIKit

protocol MenuViewControllerDelegate: AnyObject {
    func didStartGame()
}

class MenuViewController: UIViewController {
    static let storyboardIdentifier = "MenuViewController"

    weak var delegate: MenuViewControllerDelegate?

    @IBAction private func tapNewGameButton() {
        delegate?.didStartGame()
    }
}
