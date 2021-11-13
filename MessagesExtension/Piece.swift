import SpriteKit

enum PieceSet: String {
    case cross, naught

    var symbol: String {
        switch self {
        case .naught:
            return "O"
        case .cross:
            return "X"
        }
    }
    
    static func symbol(_ symbol: String) -> PieceSet? {
        let symbols: [String: PieceSet] = [
            "O": .naught,
            "X": .cross
        ]

        return symbols[symbol]
    }

    var symbolImage: String {
        switch self {
        case .naught:
            return "O"
        case .cross:
            return "X"
        }
    }
}

class Piece: CustomStringConvertible {
    var column: Int
    var row: Int
    var pieceSet: PieceSet

    var spriteName: String {
        return pieceSet.symbolImage
    }

    var symbol: String {
        return "\(pieceSet.symbol)"
    }

    var description: String {
        return "\(pieceSet), column: \(column), row: \(row)"
    }

    init(column: Int, row: Int, pieceSet: PieceSet) {
        self.column = column
        self.row = row
        self.pieceSet = pieceSet
    }
}
