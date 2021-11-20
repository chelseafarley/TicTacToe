import UIKit
import SpriteKit

protocol GameViewControllerDelegate: AnyObject {
    func didFinishMove(player: String,
                       setup: String,
                       gameWon: Bool,
                       snapshot gameSnapshot: UIImage)
}

class GameViewController: UIViewController {
    static let storyboardIdentifier = "GameViewController"

    weak var delegate: GameViewControllerDelegate?

    var scene: GameScene!
    var board: Board!
    var skView: SKView!

    @IBOutlet weak var boardView: UIView!

    func getGameSnapshot() -> UIImage {
        let cgImage = skView!.texture(from: scene.gameLayer)!.cgImage()
        return UIImage(cgImage: cgImage)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        skView = SKView(frame: view.frame)
        skView.isMultipleTouchEnabled = false
        view.addSubview(skView)

        scene = GameScene(size: skView.bounds.size)
        scene.gameSceneDelegate = self
        scene.scaleMode = .aspectFill
        scene.board = board
        scene.renderBoard()

        skView.presentScene(scene)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        skView.frame = boardView.frame
    }
}

extension GameViewController: GameSceneDelegate {
    func didFinishMove() {
        delegate?.didFinishMove(
            player: board.getOpposition(),
            setup: board.setupValue,
            gameWon: board.gameWon,
            snapshot: getGameSnapshot())
    }
    
    func getSKSpriteNode() -> SKSpriteNode {
        return SKSpriteNode(imageNamed: board.activePlayer)
    }
}
