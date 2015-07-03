//
//  GameScene.swift
//  TicTacToeStrategist
//
//  Created by Steffen Itterheim on 03/07/15.
//  Copyright (c) 2015 Steffen Itterheim. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameScene: SKScene {

	static var gameModelUpdateCount : Int = 0
	var strategist : GKMinmaxStrategist!
	var gameModel : TheGameModel!
	var playerX : TheGameModelPlayer!
	var playerO : TheGameModelPlayer!
	var moveCount : Int = 0

	override func didMoveToView(view: SKView) {
		// =================================================================
		// Create and setup the players
		// =================================================================

		playerX = TheGameModelPlayer(playerId: 1)
		playerO = TheGameModelPlayer(playerId: 2)
		
		// name is only used for logging
		playerX.name = "X"
		playerO.name = "O"

		// =================================================================
		// Create and setup the game model
		// =================================================================

		gameModel = TheGameModel(width: 3, height: 3, players: [playerX, playerO])

		// =================================================================
		// Create and setup the strategist
		// =================================================================
		
		strategist = GKMinmaxStrategist()
		strategist.gameModel = gameModel
		
		// Recommended: start with look ahead of 1 to implement basic algorithm, then go higher and improve algorithm.
		// Note: For TicTacToe the highest sensible look ahead is 7 because there are at most 7 moves.
		// A lookAhead of 7 will evaluate over 12,000 possible moves for the first move!
		strategist.maxLookAheadDepth = 1
		
		// Recommended: do not use random at first to get reproducable (testable) results every time.
		// Once algorithm is stable, use random to find all the flaws that occur due to randomizing moves with the same score.
		strategist.randomSource = GKMersenneTwisterRandomSource()
		
		// =================================================================
		// Commence game ...
		// =================================================================
		switchActivePlayer()
    }
	
	func switchActivePlayer() {
		// Players take turns, with X always making the first move
		if gameModel.activePlayer == nil || gameModel.activePlayer!.playerId == 2 {
			gameModel.activePlayer = playerX
		} else {
			gameModel.activePlayer = playerO
		}
		
		// check if we exceeded the maximum number of moves in a TicTacToe game - this means it's a draw!
		if moveCount == 9 {
			declareWinner(nil)
		} else {
			moveCount++
			performAIPlayerMove()
		}
	}
	
	func performAIPlayerMove() {
		// reset applyGameModelUpdate counter
		GameScene.gameModelUpdateCount = 0
		
		// get the strategist's best move for the active player
		let activePlayer = gameModel.activePlayer as! TheGameModelPlayer
		let move = strategist.bestMoveForPlayer(activePlayer) as? TheGameModelUpdate
		
		if move != nil {
			// set the board piece at the location specified by the move
			setBoardPieceForPlayer(activePlayer, move: move!)
			
			// If the player won after this move, declare him the winner. Otherwise continue playing.
			if gameModel.isWinForPlayer(activePlayer.playerId) == .WinThisMove {
				declareWinner(activePlayer)
			} else {
				switchActivePlayer()
			}
		}
	}
	
	func setBoardPieceForPlayer(player: TheGameModelPlayer!, move: TheGameModelUpdate!) {
		// update the gameModel's board with the move info
		gameModel.setBoardPieceForPlayer(player, move: move)
		
		// get the score for this move (it's important that the score function must not modify the game state!)
		let playerScore = gameModel.scoreForPlayer(player)
		print(String(format:"%@ placed at {%d,%d} with score %d (move: %d) considering %d moves", player.name, move.x, move.y, playerScore, move.value, GameScene.gameModelUpdateCount))
	}

	func declareWinner(player: TheGameModelPlayer?) {
		var label : SKLabelNode!
		
		if player == nil {
			print("Game Over: draw!\n\n")
			label = SKLabelNode(text: "It's a Draw!")
		} else {
			let message = String(format:"Game Over: %@ won!\n\n", player!.name)
			print(message)
			label = SKLabelNode(text: message)
		}

		label.fontName = "AvenirNext-Bold"
		label.fontSize = 64
		label.position = CGPoint(x: frame.size.width / 2.0, y: label.fontSize)
		addChild(label)
		
		drawBoard()
	}
	
	func drawBoard() {
		let boardNode = SKNode()
		boardNode.position = CGPoint(x: frame.size.width / 3.0, y: frame.size.height / 3.0)
		addChild(boardNode)
		
		let tileSize = 104
		var column = 0
		var row = 0
		
		for piece in gameModel.board {
			let bgSprite : SKSpriteNode! = SKSpriteNode(color: SKColor.darkGrayColor(), size: CGSize(width: tileSize, height: tileSize))
			bgSprite.anchorPoint = CGPointZero
			bgSprite.position = CGPoint(x: column * tileSize, y: row * tileSize)
			boardNode.addChild(bgSprite)
			
			var sprite : SKSpriteNode!
			if piece == 1 {
				sprite = SKSpriteNode(imageNamed: "swords.png")
			} else if piece == 2 {
				sprite = SKSpriteNode(imageNamed: "shield.png")
			}

			if sprite != nil {
				sprite.anchorPoint = bgSprite.anchorPoint
				sprite.position = bgSprite.position
				boardNode.addChild(sprite)
			}
			
			column++
			if column == 3 {
				column = 0
				row++
			}
		}
		
		let gridSprite : SKSpriteNode! = SKSpriteNode(imageNamed: "grid_3x3_104x104.png")
		gridSprite.anchorPoint = CGPointZero
		boardNode.addChild(gridSprite)
	}
	
    override func mouseDown(theEvent: NSEvent) {
		restart()
    }
	
	override func keyDown(event: NSEvent) {
		restart()
	}
	
	func restart() {
		if let scene = GameScene(fileNamed:"GameScene") {
			scene.scaleMode = .AspectFill
			view!.presentScene(scene)
		}
	}
}
