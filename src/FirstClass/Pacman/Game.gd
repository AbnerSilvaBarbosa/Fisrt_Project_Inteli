extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var storedScore

const FILE_NAME = "user://game-data.json"

var FILE_NAME_MOBILE = 'user://infos.json'
var playerMobile = {
	'isMobile': false
}

var player = {
	"hscore": 0,
}

func loadInfos():
	var file = File.new()
	if file.file_exists(FILE_NAME_MOBILE): #Verifica se o arquivo já havia sido criado antes
		file.open(FILE_NAME_MOBILE, File.READ) #Le o arquivo local, com infos de vida e XP
		var data = parse_json(file.get_as_text()) #Torna o JSON em objeto para o GODOT
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			playerMobile = data #Define player com as informações do arquivo local
		else:
			printerr("Arquivo Corrompido!")
	else:
		printerr("Não existe arquivo!")

# Called when the node enters the scene tree for the first time.
func _ready():
	fruitSpawned = 0
	MyGlobals.powerUpActive = 0
	MyGlobals.pickupCount = 0
	MyGlobals.score = 0
	MyGlobals.lifes = 3
	
	print(MyGlobals.score)
	
	if MyGlobals.score == 1000:
		print('Foi')
	
	#set up game over 
	MyGlobals.gameOver = 0
	get_node("GameOverText").visible = false
	#hide fruit until spawned
	var pickUps = get_tree().get_nodes_in_group("fruit")
	for i in pickUps:
		i.visible = true
		i.get_node("Area2D").set_collision_layer_bit(0,0)
		i.get_node("Area2D").set_collision_mask_bit(0,0)
	
	
	#save()
	loadf()
	MyGlobals.savedHighScore = player.hscore
	print(MyGlobals.savedHighScore)
	
	get_node("HighScore/HighScoreNumber").text = str(MyGlobals.savedHighScore)
	
	#displays first score
	get_node("Score/ScoreNumber").text = str(MyGlobals.score)
	
	#displays life
	displayLife()
	
	#displays level fruit icon 
	displayLevel()
	
	newStage()
	
	pass # Replace with function body.

var fruitSpawned = 0

func spawnFruit():
	print("spawning fruit")
	var pickUps = get_tree().get_nodes_in_group("fruit")
	for i in pickUps:
		i.visible = true
		i.get_node("Sprite").visible = true
		i.get_node("Area2D").set_collision_layer_bit(0,1)
		i.get_node("Area2D").set_collision_mask_bit(0,1)

func save():
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(player))
	file.close()

func loadf():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			player = data
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")

#calls when a pickUp is touched, checks if all pick ups are not visable to win
func checkWin():
	var hasWin = 1
	var pickUps = get_tree().get_nodes_in_group("pickUp")
	for i in pickUps:
		if(i.visible == true):
			hasWin = 0
	if(hasWin == 1):
		var tempLevel = MyGlobals.level + 1
		MyGlobals.level = tempLevel
		print("stage win")
		resetStage2()
	pass

#calls on new game, refreshes the pickups and level++
func newStage():
	#remask reshow pickups
	var pickUps = get_tree().get_nodes_in_group("pickUp")
	for i in pickUps:
		i.visible = true
		i.get_node("Area2D").set_collision_layer_bit(0,1)
		i.get_node("Area2D").set_collision_mask_bit(0,1)
	#get_node("GhostSpawn").position

#called when stage won
func resetStage2():
		#reposition Player
		var playerLoc = get_node("PlayerSpawn").position
		get_node("Player").position = playerLoc
		get_node("Player").lastDir = ""
		
		#repositions ghosts
		var ghostLoc = get_node("GhostSpawn").position
		var ghosts = get_tree().get_nodes_in_group("Ghost")
		for i in ghosts:
			i.position = ghostLoc
		#get_node("GhostSpawn").position
		
		#refresh pickUps twice, sloppy fix for spawning missing pickup bug
		newStage()
		$PickupTimer.start()


#called when touched by ghost, reset positions if have life
func resetStage():
	#remove life
	var tempLife = MyGlobals.lifes - 1
	if (tempLife < 0):
		MyGlobals.gameOver = 1
		get_node("GameOverText").visible = true
		get_node("GameOverText/ReplayButton").grab_focus()
		
		if(MyGlobals.score > MyGlobals.savedHighScore):
			print("New high score!")
			player.hscore = MyGlobals.score
			save()
		else:
			print("No high score.")
		
	else:
		MyGlobals.lifes = tempLife
		displayLife()
		
		#repositions ghosts
		var ghostLoc = get_node("GhostSpawn").position
		var ghosts = get_tree().get_nodes_in_group("Ghost")
		for i in ghosts:
			i.position = ghostLoc
		#get_node("GhostSpawn").position
		
		
		#reposition Player
		var playerLoc = get_node("PlayerSpawn").position
		get_node("Player").position = playerLoc
		get_node("Player").lastDir = ""
		
		#refresh pickUps
		#newStage()

func displayLevel():
	get_node("fruit0").visible = false
	get_node("fruit1").visible = false
	get_node("fruit2").visible = false
	get_node("fruit3").visible = false
	get_node("fruit4").visible = false
	get_node("fruit5").visible = false
	get_node("fruit6").visible = false
	match MyGlobals.level:
		0:
			get_node("fruit0").visible = false
			get_node("fruit1").visible = false
			get_node("fruit2").visible = false
			get_node("fruit3").visible = false
			get_node("fruit4").visible = false
			get_node("fruit5").visible = false
			get_node("fruit6").visible = false
		1:
			get_node("fruit0").visible = true
		2:
			get_node("fruit0").visible = true
			get_node("fruit1").visible = true
		3:
			get_node("fruit0").visible = true
			get_node("fruit1").visible = true
			get_node("fruit2").visible = true
		4:
			get_node("fruit0").visible = true
			get_node("fruit1").visible = true
			get_node("fruit2").visible = true
			get_node("fruit3").visible = true
		5:
			get_node("fruit0").visible = true
			get_node("fruit1").visible = true
			get_node("fruit2").visible = true
			get_node("fruit3").visible = true
			get_node("fruit4").visible = true
		6:
			get_node("fruit0").visible = true
			get_node("fruit1").visible = true
			get_node("fruit2").visible = true
			get_node("fruit3").visible = true
			get_node("fruit4").visible = true
			get_node("fruit5").visible = true
		7:
			get_node("fruit0").visible = true
			get_node("fruit1").visible = true
			get_node("fruit2").visible = true
			get_node("fruit3").visible = true
			get_node("fruit4").visible = true
			get_node("fruit5").visible = true
			get_node("fruit6").visible = true
		_:
			get_node("fruit0").visible = true
			get_node("fruit1").visible = true
			get_node("fruit2").visible = true
			get_node("fruit3").visible = true
			get_node("fruit4").visible = true
			get_node("fruit5").visible = true
			get_node("fruit6").visible = true

func displayLife():
	get_node("life0").visible = false
	get_node("life1").visible = false
	get_node("life2").visible = false
	get_node("life3").visible = false
	get_node("life4").visible = false
	match MyGlobals.lifes:
		0:
			get_node("life0").visible = false
			get_node("life1").visible = false
			get_node("life2").visible = false
			get_node("life3").visible = false
			get_node("life4").visible = false
		1:
			get_node("life0").visible = true
		2:
			get_node("life0").visible = true
			get_node("life1").visible = true
		3:
			get_node("life0").visible = true
			get_node("life1").visible = true
			get_node("life2").visible = true
		4:
			get_node("life0").visible = true
			get_node("life1").visible = true
			get_node("life2").visible = true
			get_node("life3").visible = true
		5:
			get_node("life0").visible = true
			get_node("life1").visible = true
			get_node("life2").visible = true
			get_node("life3").visible = true
			get_node("life4").visible = true

var extralifeReward1 = 0
var extralifeReward2 = 0
var extralifeReward3 = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	loadInfos()
	if (playerMobile.isMobile == true):
		$Cima.visible = true
		$Baixo.visible = true
		$Esquerda.visible = true
		$Direita.visible = true
		$fecharTouch.visible = true
	
	if(MyGlobals.score >= 10000 && MyGlobals.score < 15000 && extralifeReward1 == 0):
		extralifeReward1 = 1
		var tempLife = MyGlobals.lifes + 1
		MyGlobals.lifes = tempLife
		displayLife()
		print("rewarding first 1up")
	elif(MyGlobals.score >= 15000 && MyGlobals.score < 20000 && extralifeReward2 == 0):
		extralifeReward2 = 1
		var tempLife = MyGlobals.lifes + 1
		MyGlobals.lifes = tempLife
		displayLife()
		print("rewarding second 1up")
	elif(MyGlobals.score >= 20000 && extralifeReward3 == 0):
		extralifeReward3 = 1
		var tempLife = MyGlobals.lifes + 1
		MyGlobals.lifes = tempLife
		displayLife()
		print("rewarding second 1up")
	if(MyGlobals.pickupCount == 50 && fruitSpawned == 0):
		fruitSpawned = 1
		MyGlobals.pickupCount = 0
		spawnFruit()
	get_node("Score/ScoreNumber").text = str(MyGlobals.score)
	if (MyGlobals.score >= 2000):
		get_tree().paused = true
		yield(get_tree().create_timer(3.0), "timeout") #Aguarda 3 segundo
		get_tree().paused = false
		get_tree().change_scene("res://D&IFobia.tscn")
	#get_node("HighScore/HighScoreNumber").text = str(MyGlobals.score)
	pass


func _on_GhostCage_body_entered(body):
	if body.is_in_group("Ghost"):
		body.isCaged = true
		#var tempScore = MyGlobals.score + 50
		#MyGlobals.score = tempScore
		#queue_free()
	pass # Replace with function body.


func _on_GhostCage_body_exited(body):
	if body.is_in_group("Ghost"):
		body.isCaged = false
	#var tempScore = MyGlobals.score + 50
	#MyGlobals.score = tempScore
	#queue_free()
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	if body.is_in_group("Ghost"):
		body.moveUp()
	pass # Replace with function body.


func _on_ReplayButton_pressed():
	get_tree().change_scene("res://Game.tscn")
	pass # Replace with function body.

#resume game when stage is setup
func _on_PickupTimer_timeout():
	newStage()
	pass # Replace with function body.

func setPowerUp():
	#repositions ghosts
	#var ghostLoc = get_node("GhostSpawn").position
	var ghosts = get_tree().get_nodes_in_group("Ghost")
	for i in ghosts:
		i.set_modulate(Color(0,0,1))
	#get_node("GhostSpawn").position

func unsetPowerUp():
	var ghosts = get_tree().get_nodes_in_group("Ghost")
	for i in ghosts:
		i.set_modulate(Color(1,1,1))

func _on_PowerupTimer_timeout():
	MyGlobals.powerUpActive = 0
	MyGlobals.eatCombo = 0
	unsetPowerUp()
	pass # Replace with function body.


func _on_leftTeleport_body_entered(body):
	#reposition Player
	if body.is_in_group("Ghost") || body.is_in_group("Player"):
		var rightLoc = get_node("rightTeleportSpot").position
		body.position = rightLoc
	#get_node("Player").lastDir = ""
	pass # Replace with function body.


func _on_rightTeleport_body_entered(body):
	if body.is_in_group("Ghost") || body.is_in_group("Player"):
		var leftLoc = get_node("leftTeleportSpot").position
		body.position = leftLoc
	pass # Replace with function body.


func _fecharTouch():
	get_tree().change_scene("res://D&IFobia.tscn")
