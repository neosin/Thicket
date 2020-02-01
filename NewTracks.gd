extends GridContainer

var OpenSeed
var Thicket
#var thread = Thread.new()
var newtracks = load("res://elements/MusicBoxMedium.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# warning-ignore:unused_signal
var playlist = []
var textureList = []
var new_num = 15
var imageFile = Image.new()
var textureFile = [ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),
ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new()]
signal getNew()
# warning-ignore:unused_signal
signal playlist()
# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	#OpenSeed.connect("socket_returns",self,"socket_returned")
	Thicket.connect("new_tracks_ready",self,"set_new_tracks")
	pass # Replace with function body.

# warning-ignore:unused_argument
#func get_new_tracks(num):
	#OpenSeed.thread.start(OpenSeed,"get_from_socket_threaded",['{"act":"newtracks_json","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'"}',"newtracks"])
	#var new_tracks = Thicket.new_tracks
	#return new_tracks

func new_tracks(data):
	pass

func set_new_tracks():
	#print("Setting new tracks")
	playlist = []
	#var children = get_child_count() - 1
	#while children >= 0:
	#	var track = get_child(children)
	#	remove_child(track)
	#	track.queue_free()
	#	children -= 1
	var list = Thicket.new_tracks
	var count = 0
	if get_child_count() < new_num:
		for track in list:
			var NewTrack = newtracks.instance()
			var artist = track["author"]
			var title = track["title"]
			var post = track["post"]
			var img = track["img"]
			if count < new_num:
				NewTrack.title = title
				NewTrack.artist = artist
				NewTrack.img = img
				NewTrack.block = imageFile
				NewTrack.post = post
				NewTrack.texblock = textureFile[count]
				NewTrack.track = track["ogg"]
				NewTrack.connect("play",get_parent().get_parent().get_parent().get_parent(),"play_track")
				
				call_deferred("add_child", NewTrack)
				playlist.append(track)
			count += 1
	else:
		for track in list:
			var artist = track["author"]
			var title = track["title"]
			var post = track["post"]
			var img = track["img"]
			var instance
			if count < new_num:
				instance = get_child(count)
				instance.title = title
				instance.artist = artist
				instance.img = img
				instance.block = imageFile
				instance.post = post
				instance.texblock = textureFile[count]
				instance.track = track["ogg"]
				#instance.connect("play",get_parent().get_parent().get_parent().get_parent(),"play_track")
				playlist.append(track)
			count += 1

func _on_NewTracks_getNew():
	print("New_Tracks")
	OpenSeed.thread.start(OpenSeed,"get_from_socket_threaded",['{"act":"newtracks_json","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'"}',"newtracks"])
	#set_new_tracks()
	pass # Replace with function body.


func _on_NewTracks_playlist():
	return(playlist)

func _on_NewMusic_getNew():
	print("New_Music")
	#Thicket.parsing = false
	set_new_tracks()
	pass # Replace with function body.
	
#func socket_returned(data):
#	print("From New Tracks")
#	if data[0] == "tracks":
		#print(data[0])
#		pass
