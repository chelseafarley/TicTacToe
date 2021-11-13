import Messages

class Board {
    private var pieces: Array2D<Piece>!
    private var _setup: String!
    private var _activePlayer: String!
    private var _gameWon: Bool!
    
    var gameWon: Bool {
        get {
            return _gameWon
        }
    }

    var setup: String {
        get {
            return _setup
        }

        set {
            _setup = newValue
        }
    }
    
    var activePlayer: String {
        get {
            return _activePlayer
        }

        set {
            _activePlayer = newValue
        }
    }

    var setupValue: String {
        var setup: [String] = []
        for row in 0...2 {
            for column in 0...2 {
                if let piece = pieces[column, row] {
                    setup.append("\(piece.symbol)\(piece.column)\(piece.row)")
                }
            }
        }
        return setup.joined(separator: ",")
    }
    
    func addPiece(column: Int, row: Int, piece: Piece) {
        pieces[column, row] = piece
    }

    func pieceAt(column: Int, row: Int) -> Piece? {
        guard column >= 0 && column < 3 else { return nil }
        guard row >= 0 && row < 3 else { return nil }

        return pieces[column, row]
    }

    func isPieceAt(column: Int, row: Int) -> Bool {
        return pieceAt(column: column, row: row) != nil
    }
    
    func getOpposition() -> String {
        return activePlayer == "X" ? "O" : "X"
    }
    
    func checkSquare(column: Int, row: Int) -> Bool {
        return pieces[column, row] != nil && pieces[column, row]?.symbol == activePlayer
    }
    
    func checkResult(column: Int, row: Int) {
        var checkForwardsDiagonal = row == column;
        var checkBackwardsDiagonal = row + column == 3;
        var checkRow = true;
        var checkCol = true;
        
        for i in 0...2 {
            if (checkForwardsDiagonal) {
                checkForwardsDiagonal = checkSquare(column: i, row: i)
            }

            if (checkBackwardsDiagonal) {
                checkBackwardsDiagonal = checkSquare(column: i, row: 2 - i)
            }

            if (checkRow) {
                checkRow = checkSquare(column: i, row: row)
            }

            if (checkCol) {
                checkCol = checkSquare(column: row, row: i)
            }
        }

        _gameWon = checkForwardsDiagonal || checkBackwardsDiagonal || checkRow || checkCol;
    }

    init(message: MSMessage?) {
        guard let message = message, let url = message.url else {
            setup = ""
            activePlayer = "X"
            _gameWon = false
            setUpBoard(with: setup)
            return
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
                    _gameWon = Bool(item.value!)
                    continue
                }
            }
        }

        setUpBoard(with: setup)
    }

    private func setUpBoard(with setup: String) {
        pieces = Array2D<Piece>(columns: 3, rows: 3)

        for piece in setup.components(separatedBy: ",") {
            if (piece != "") {
                let characters = Array(piece)
                let pieceSet = PieceSet.symbol(String(characters[0]))!
                let column = Int(String(characters[1]))!
                let row = Int(String(characters[2]))!
                
                pieces[column, row] = Piece(column: column, row: row, pieceSet: pieceSet)
            }
        }
    }
}
