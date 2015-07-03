//
//  GameModel.swift
//  TicTacToeStrategist
//
//  Created by Steffen Itterheim on 03/07/15.
//  Copyright © 2015 Steffen Itterheim. All rights reserved.
//

import Foundation
import GameplayKit

class TheGameModel: NSObject, NSCopying, GKGameModel {
	
	var board : Array<Int>
	var boardWidth : Int
	var boardHeight : Int
	
	required init(width: Int, height: Int, players: [GKGameModelPlayer]) {
		//NSLog("TheGameModel init(width=%d, height=%d, players=%@)", width, height, players)
		boardWidth = width;
		boardHeight = height;
		board = Array<Int>(count: width * height, repeatedValue: 0);
		_players = players
	}
	
	// ===========================================================================
	// NSCopying Protocol
	// ===========================================================================
	func copyWithZone(zone: NSZone) -> AnyObject { // NSCopying protocol function
		let copy = self.dynamicType.init(width: boardWidth, height: boardHeight, players: players!)
		//NSLog("TheGameModel copyWithZone() - self: %@, copy: %@", self, copy)
		copy.setGameModel(self) // this copies the game model state
		return copy
	}
	
	// ===========================================================================
	// GKGameModel Protocol
	// ===========================================================================
	func setGameModel(gameModel: GKGameModel) {
		//NSLog("TheGameModel setGameModel(%@)", gameModel.description)
		// copy the gameModel's state into ours (ie self.xyz = gameModel.xyz)
		let inputModel = gameModel as! TheGameModel
		self.board = inputModel.board
		self.activePlayer = inputModel.activePlayer
	}

	var _players : [GKGameModelPlayer]?
	var players: [GKGameModelPlayer]? {
		get {
			// return the list of all players (both human and AI)
			//NSLog("TheGameModel get players: %@", _players!)
			return _players
		}
	}
	
	var _activePlayer : GKGameModelPlayer?
	var activePlayer: GKGameModelPlayer? {
		get {
			// return the player set to make the next move
			//NSLog("TheGameModel get activePlayer: %@", _activePlayer != nil ? _activePlayer!.description : "nil")
			return _activePlayer
		}
		set {
			//NSLog("TheGameModel set activePlayer: %@", newValue!.description)
			_activePlayer = newValue
		}
	}
	
	func gameModelUpdatesForPlayer(player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
		// create instances of GKGameModelUpdate for every possible move, then return them in an array
		var moves = [GKGameModelUpdate]()
		for y in 0 ... boardHeight - 1 {
			for x in 0 ... boardWidth - 1 {
				// if there's no piece there we can make that move (== adding a piece)
				if boardPieceAtCoord(x, y: y) == 0 {
					let move = TheGameModelUpdate(x: x, y: y)
					moves.append(move)
				}
			}
		}
		
		//NSLog("TheGameModel gameModelUpdatesForPlayer(%@) moves: %@", (player as! TheGameModelPlayer).name, moves)
		return moves.count > 0 ? moves : nil
	}

	func applyGameModelUpdate(gameModelUpdate: GKGameModelUpdate) {
		GameScene.gameModelUpdateCount++
		
		// have activePlayer change the game model according to the move described by gameModelUpdate
		setBoardPieceForPlayer(activePlayer!, move: gameModelUpdate as! TheGameModelUpdate)
		//NSLog("TheGameModel applyGameModelUpdate(%@) (%d,%d) = %d", gameModelUpdate.description, (gameModelUpdate as! TheGameModelUpdate).x, (gameModelUpdate as! TheGameModelUpdate).y, board[indexForCoord((gameModelUpdate as! TheGameModelUpdate).x, y: (gameModelUpdate as! TheGameModelUpdate).y)])
		
		// After every move, the next turn is handed over to the next player.
		// This assumes that playerId start with 1, which makes it easy to advance to the next player in the array.
		let activeId = _activePlayer!.playerId
		for player in _players! {
			if activeId != player.playerId {
				self.activePlayer = player
				break
			}
		}
	}
	
	func scoreForPlayer(player: GKGameModelPlayer) -> Int {
		// From the perspective of player, calculate how desirable the current game model state is.
		// Higher values indicate higher desirability. Return Int.min (NSIntegerMin) if the move is not valid.
		
		// Note: just determining whether a player has won isn't nearly enough to create a good AI.
		// For instance, you will want the AI to also consider not letting the other player win, or to place himself
		// in a strategic advantage, such as forcing the other player in a situation where he can only lose. You need to
		// algorithmically determine such states and design the score values accordingly.
		
		let playerId = player.playerId
		var finalScore = 0
		
		// give winning a score without considering the opponent
		var winScore = 0
		var winAnalysis = isWinForPlayer(playerId)
		if winAnalysis == .WinThisMove {
			winScore = 100
		} else if winAnalysis == .MultiplePossibleWinsNextMove {
			winScore = 50
		} else if winAnalysis == .PossibleWinNextMove {
			winScore = 30
		}
		
		// give preventing to lose a generally higher score because there's little point in
		// trying a strategy to win if you are going to lose next turn ...
		var dontLoseScore = 0
		for otherPlayer in _players! {
			if otherPlayer.playerId != playerId {
				winAnalysis = isWinForPlayer(otherPlayer.playerId)
				if winAnalysis == .MultiplePossibleWinsNextMove {
					dontLoseScore = -75 // prevent other player from achieving a sure-win situation
				} else if winAnalysis == .PossibleWinNextMove {
					dontLoseScore = -60 // prevent other player from winning next move
				}
			}
		}
		
		finalScore = winScore + dontLoseScore
		/*
		if finalScore == 0 {
			// rate the positions on the board if neither loss nor win are imminent
			// useful for early game, especially when starting (who wouldn't pick the center?)
			let boardScores =
				[3, 1, 3,
				 1, 9, 1,
				 3, 1, 3];
			
			// this is a naive implementation as fields could have 0 value in some game states
			for y in 0 ... boardHeight - 1 {
				for x in 0 ... boardWidth - 1 {
					if boardPieceAtCoord(x, y: y) == playerId {
						let scoreForCoord = boardScores[indexForCoord(x, y: y)]
						if scoreForCoord > finalScore {
							finalScore = scoreForCoord
						}
					}
				}
			}
		}
		*/
		
		//NSLog("Board: %@Score = %d for Player %@\n\n", convertBoardToString(), finalScore, (player as! TheGameModelPlayer).name)
		
		return finalScore
	}
	
	// ===========================================================================
	// Other functions
	// ===========================================================================
	
	func indexForCoord(x: Int, y: Int) -> Int {
		if x < 0 || x >= boardWidth || y < 0 || y >= boardHeight {
			NSLog("Coord {%d,%d} out of bounds: {%d,%d}", x, y, boardWidth, boardHeight)
			return -1
		}
		return y * boardWidth + x
	}
	
	func setBoardPieceForPlayer(player: GKGameModelPlayer, move: TheGameModelUpdate) -> Bool {
		let index = indexForCoord(move.x, y: move.y)
		if index >= 0 {
			board[index] = player.playerId
			//NSLog("set %d at {%d,%d}", playerId, move.x, move.y)
			return true
		}
		return false
	}
	
	func boardPieceAtCoord(x: Int, y: Int) -> Int {
		let index = indexForCoord(x, y: y)
		if index >= 0 {
			return board[index]
		}
		return -1
	}
	
	enum WinAnalysis {
		case WontWinThisMove, WinThisMove, PossibleWinNextMove, MultiplePossibleWinsNextMove
	}
	
	func isWinForPlayer(playerId: Int) -> WinAnalysis {
		// find a sequence of 3 matching playerId on the board
		var result : WinAnalysis = .WontWinThisMove
		var possibleWinCount = 0
		var sequenceCount = 0
		var zeroCount = 0
		
		// find horizontal wins
		for y in 0 ... boardHeight - 1 {
			sequenceCount = 0
			zeroCount = 0
			for x in 0 ... boardWidth - 1 {
				if (boardPieceAtCoord(x, y: y) == playerId) {
					sequenceCount++;
				} else if (zeroCount == 0 && boardPieceAtCoord(x, y: y) == 0) {
					zeroCount++;
					sequenceCount++;
				}
			}
			if sequenceCount == boardWidth {
				result = (zeroCount == 0 ? .WinThisMove : .PossibleWinNextMove)
				possibleWinCount += Int(result == .PossibleWinNextMove)
				if result == .WinThisMove {
					return .WinThisMove
				}
			}
		}
		
		// find vertical wins
		for x in 0 ... boardWidth - 1 {
			sequenceCount = 0
			zeroCount = 0
			for y in 0 ... boardHeight - 1 {
				if (boardPieceAtCoord(x, y: y) == playerId) {
					sequenceCount++;
				} else if (zeroCount == 0 && boardPieceAtCoord(x, y: y) == 0) {
					zeroCount++;
					sequenceCount++;
				}
			}
			if sequenceCount == boardHeight {
				//NSLog("Vertical win for playerId %d", playerId)
				result = (zeroCount == 0 ? .WinThisMove : .PossibleWinNextMove)
				possibleWinCount += Int(result == .PossibleWinNextMove)
				if result == .WinThisMove {
					return .WinThisMove
				}
			}
		}
		
		// find diagonal win (upper left to bottom right)
		sequenceCount = 0
		zeroCount = 0
		for x in 0 ... boardWidth - 1 {
			let y = x
			if (boardPieceAtCoord(x, y: y) == playerId) {
				sequenceCount++;
			} else if (zeroCount == 0 && boardPieceAtCoord(x, y: y) == 0) {
				zeroCount++;
				sequenceCount++;
			}
		}
		if sequenceCount == boardWidth {
			//NSLog("Diagonal (UL/BR) win for playerId %d", playerId)
			result = (zeroCount == 0 ? .WinThisMove : .PossibleWinNextMove)
			possibleWinCount += Int(result == .PossibleWinNextMove)
			if result == .WinThisMove {
				return .WinThisMove
			}
		}
		
		// find diagonal win (lower left to top right)
		sequenceCount = 0
		zeroCount = 0
		for y in 0 ... boardHeight - 1 {
			let x = boardWidth - y - 1
			if (boardPieceAtCoord(x, y: y) == playerId) {
				sequenceCount++;
			} else if (zeroCount == 0 && boardPieceAtCoord(x, y: y) == 0) {
				zeroCount++;
				sequenceCount++;
			}
		}
		if sequenceCount == boardHeight {
			//NSLog("Diagonal (LL/TR) win for playerId %d", playerId)
			result = (zeroCount == 0 ? .WinThisMove : .PossibleWinNextMove)
			possibleWinCount += Int(result == .PossibleWinNextMove)
			if result == .WinThisMove {
				return .WinThisMove
			}
		}
		
		if possibleWinCount == 0 {
			result = .WontWinThisMove
		} else if possibleWinCount > 1 {
			result = .MultiplePossibleWinsNextMove
		} else {
			result = .PossibleWinNextMove
		}
		
		return result
	}
	
	func convertBoardToString() -> String {
		var s : String = "\n"
		
		for y in 0 ... boardHeight - 1 {
			for x in 0 ... boardWidth - 1 {
				let value = boardPieceAtCoord(x, y: y)
				s = String(format: "%@%@", s, value == 0 ? "☼" : (value == 1 ? "X" : "O"))
			}
			
			s = String(format: "%@\n", s)
		}
		
		return s
	}
}


class TheGameModelPlayer : NSObject, GKGameModelPlayer {
	
	required init(playerId: Int) {
		//NSLog("TheGameModelPlayer init(%d)", playerId)
		_playerId = playerId
	}
	
	override var description : String {
		return String(format: "%@ playerId: %d", super.description, _playerId)
	}
	
	var name : String = ""
	var _playerId : Int // an integer uniquely identifying a specific player
	
	// ===========================================================================
	// GKGameModelPlayer Protocol
	// ===========================================================================
	var playerId : Int {
		get {
			//NSLog("TheGameModelPlayer get playerId: %d", _playerId)
			return _playerId;
		}
	}
}


class TheGameModelUpdate : NSObject, GKGameModelUpdate {
	
	required init(x: Int, y: Int) {
		//NSLog("TheGameModelUpdate init(x=%d, y=%d)", x, y)
		self.x = x
		self.y = y
	}
	
	// This is all we need to define our "move": the location of where to set the piece.
	// Since the gameModel.activePlayer records whose turn it is the type of piece (X or O) need not be stored here.
	var x : Int = 0
	var y : Int = 0
	
	override var description : String {
		return String(format: "%@ {%d,%d} value: %d", super.description, x, y, _value)
	}
	
	// ===========================================================================
	// GKGameModelUpdate Protocol
	// ===========================================================================
	// value rates desirability of the move
	var _value: Int = 0
	var value: Int {
		get {
			// This is never called but must be implemented (no setter without a getter).
			return _value
		}
		set {
			// The newValue is only ever set once, after the scoreForPlayer function ran.
			_value = newValue
		}
	}
}
