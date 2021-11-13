import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func didFinishMove()
}

extension SKSpriteNode {
    func drawBorder(color: UIColor, width: CGFloat) {
        let shapeNode = SKShapeNode(rect: frame)
        shapeNode.fillColor = .clear
        shapeNode.strokeColor = color
        shapeNode.lineWidth = width
        addChild(shapeNode)
    }
}

class GameScene: SKScene {
    var tileSize: CGFloat!
    var pieceSize: CGFloat!

    let dimension = 3

    let gameLayer = SKNode()
    let boardLayer = SKNode()
    let piecesLayer = SKNode()

    var board: Board!

    weak var gameSceneDelegate: GameSceneDelegate?

    override init(size: CGSize) {
        super.init(size: size)

        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        tileSize = size.width / CGFloat(dimension) / 1.5
        pieceSize = tileSize * 0.9

        addChild(gameLayer)

        let layerPosition = CGPoint(x: -tileSize * CGFloat(dimension) / 2,
                                    y: -tileSize * CGFloat(dimension) / 2)

        boardLayer.position = layerPosition
        gameLayer.addChild(boardLayer)

        piecesLayer.position = layerPosition
        gameLayer.addChild(piecesLayer)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!board.gameWon) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: piecesLayer)
            let (success, column, row) = convert(point: location)

            if success {
                if board.pieceAt(column: column, row: row) == nil {
                    let position = pointFor(column: column, row: row)
                    let pieceSet = board.activePlayer == "X" ? PieceSet.cross : PieceSet.naught
                    let piece = Piece(column: column, row: row, pieceSet: pieceSet)
                    let sprite = SKSpriteNode(imageNamed: piece.spriteName)
                    sprite.size = CGSize(width: pieceSize, height: pieceSize)
                    sprite.position = position
                    board.addPiece(column: column, row: row, piece: piece)
                    
                    board.checkResult(column: column, row: row)

                    piecesLayer.addChild(sprite)

                    self.gameSceneDelegate?.didFinishMove()
                }
            }
        }
    }

    func renderBoard() {
        boardLayer.removeAllChildren()
        piecesLayer.removeAllChildren()

        for row in 0..<dimension {
            for column in 0..<dimension {
                let size = CGSize(width: tileSize, height: tileSize)
                let position = pointFor(column: column, row: row)
                let tileNode = SKSpriteNode(color: .white, size: size)
                tileNode.drawBorder(color: .black, width: 2)
                tileNode.position = position
                boardLayer.addChild(tileNode)

                if let piece = board.pieceAt(column: column, row: row) {
                    let sprite = SKSpriteNode(imageNamed: piece.spriteName)
                    sprite.size = CGSize(width: pieceSize, height: pieceSize)
                    sprite.position = position

                    piecesLayer.addChild(sprite)
                }
            }
        }
    }

    private func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(x: CGFloat(column) * tileSize + tileSize / 2,
                       y: CGFloat(row) * tileSize + tileSize / 2)
    }

    private func convert(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(dimension) * tileSize &&
            point.y >= 0 && point.y < CGFloat(dimension) * tileSize {
            return (true, Int(point.x / tileSize), Int(point.y / tileSize))
        } else {
            return (false, 0, 0)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not used")
    }
}
