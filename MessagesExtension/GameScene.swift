import SpriteKit

class GameScene: SceneBase {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!board.gameWon) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: piecesLayer)
            
            handleTouchAtPoint(location)
        }
    }
}
