//
//  InterfaceController.swift
//  TicTacToeWatch WatchKit Extension
//
//  Created by chelsea on 20/11/21.
//  Copyright © 2021 tripwiretech. All rights reserved.
//

import WatchKit
import Foundation
import SpriteKit


class InterfaceController: WKInterfaceController {
    @IBOutlet var skScene: WKInterfaceSKScene!
    var scene: SceneBase!
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        scene = SceneBase(size: CGSize(width: contentFrame.size.width, height: contentFrame.size.width - 20))
        scene.gameSceneDelegate = self
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.board = Board(setup: "", activePlayer: "X", gameWon: false, isWatch: true)
        scene.renderBoard()
        
        // Present the scene
        skScene.presentScene(scene)
    }
    
    @IBAction func onTap(_ tapGesture: WKTapGestureRecognizer) {
        if (!scene.board.gameWon) {
            let location = tapGesture.locationInObject()
            scene.handleTouchAtPoint(location)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
}

extension InterfaceController: GameSceneDelegate {
    func didFinishMove() {
        scene.board.activePlayer = scene.board.activePlayer == "X" ? "O" : "X"
    }
    
    func getSKSpriteNode() -> SKSpriteNode {
        return SKSpriteNode(imageNamed: scene.board.activePlayer)
    }
}
