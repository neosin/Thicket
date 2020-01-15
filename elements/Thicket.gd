extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var OpenSeed
var connections_list
var artists = []
var new_artists = []
var new_tracks = []
var tracks = []
var genres = []
var applications = []
var favorite_apps = []

#var parsed = []
var parsing = false

var music_color = Color("#6A1B5D")
var app_color = Color("#1B6A28") 
var social_color = Color("#6A501B") 
var games_color = Color("#1B356A")

var selected_color = Color(0.8,0.8,0.8)

signal new_tracks_ready()

var dev_profile = ""
# Called when the node enters the scene tree for the first time.

func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	OpenSeed.connect("new_tracks",self,"_on_new_tracks")
	pass

func developer_save(dev):
	var file = File.new()
	var content = '{'+dev+'}'
	file.open("user://dev.dat",File.WRITE)
	file.store_string(content)
	file.close()
	
func settings_save(cf,p2p,ipfs,dev,mf,vf):
	var file = File.new()
	var content = '{"customFolders":"'+str(cf)+'","p2p":"'+str(p2p)+'","ipfs":"'+str(ipfs)+'","devMode":"'+str(dev)+'","MusicFolder":"'+str(mf)+'","VideoFolder":"'+str(vf)+'"}'
	file.open("user://settings.dat", File.WRITE)
	file.store_string(content)
	file.close()
	
func settings_load():
	var file = File.new()
	if file.file_exists("user://settings.dat"):
		file.open("user://settings.dat", File.READ)
		var content = parse_json(file.get_as_text())
		file.close()
		if content["ipfs"]:
			OpenSeed.check_ipfs()
		
		return content
	
func developer_post():
	pass
	
func game_post():
	pass
	
func get_post(author,url):
	var post = OpenSeed.get_from_socket('{"act":"post","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'","author":"'+author+'","permlink":"'+url+'"}')
	return post
	
func playlist_load(type):
	var file = File.new()
	var list
	match(type):
		"recent":
			if file.file_exists("user://database/"+type+".dat"):
				file.open("user://database/"+type+".dat", File.READ)
				list = file.get_as_text()
				file.close()
		_:
			if file.file_exists("user://database/"+type+".dat"):
				file.open("user://database/"+type+".dat", File.READ)
				list = file.get_as_text()
				file.close()
	return(list)
			

func playlist_save(type,data):
	var list = playlist_load(type)
	var file = File.new()
	var index = find_track(data)
	var Tdata = to_json(Thicket.tracks[index])
	if list:
		if list.find(Tdata) == -1:
			file.open("user://database/"+type+".dat", File.WRITE)
			file.store_string(Tdata+", \n"+list)
	else:
		file.open("user://database/"+type+".dat", File.WRITE)
		file.store_string(Tdata+", \n")
		
	file.close()

func create_folders():
	var dir = Directory.new()
	if !dir.dir_exists("user://cache"):
		dir.make_dir("user://cache")
	if !dir.dir_exists("user://cache/Music"):
		dir.make_dir("user://cache/Music")
	if !dir.dir_exists("user://cache/Img"):
		dir.make_dir("user://cache/Img")
	if !dir.dir_exists("user://favorites"):
		dir.make_dir("user://favorites")
	if !dir.dir_exists("user://database"):
		dir.make_dir("user://database")
	if !dir.dir_exists("user://database/connections"):
		dir.make_dir("user://database/connections")
	if !dir.dir_exists("user://database/artists"):
		dir.make_dir("user://database/artists")
	if !dir.dir_exists("user://database/genres"):
		dir.make_dir("user://database/genres")
	if !dir.dir_exists("user://games"):
		dir.make_dir("user://games")
	if !dir.dir_exists("user://games/database"):
		dir.make_dir("user://games/database")
	if !dir.dir_exists("user://games/database/images"):
		dir.make_dir("user://games/database/images")
	if !dir.dir_exists("user://updates"):
		dir.make_dir("user://updates")
	if !dir.dir_exists("user://playlists"):
		dir.make_dir("user://playlists")

# warning-ignore:unused_argument
func played_song_record(track):
	var file = File.new()
# warning-ignore:unused_variable
	var current_records
	if file.file_exists("user://records.dat"):
		file.open("user://records.dat", File.READ)
		current_records = parse_json(file.get_as_text())
		file.close()
	pass

func local_knowledge_load(type):
	var file = File.new()
	var list = []
	if file.file_exists("user://database/"+type+".dat"):
		file.open("user://database/"+type+".dat", File.READ)
		match(type):
			"tracks":
				var count = 0
				for t in file.get_as_text().split(", \n"):
					if count > 0:
						list.append(parse_json(t))
					count +=1
			"genres":
				var count = 0
				for t in file.get_as_text().split(", \n"):
					if count > 0:
						list.append(t.split('"')[1])
					count +=1
			"artists":
				var count = 0
				for t in file.get_as_text().split(", \n"):
					if count > 0:
						list.append(t.split('"')[1])
					count +=1
			_:
				list = file.get_as_text().split(", \n")
		file.close()
	else:
		list = []
	return(list)
	
func local_knowledge_add(type,track):
	var list = str(local_knowledge_load(type))
	var file = File.new()
	file.open("user://database/"+type+".dat", File.WRITE)
	if list.find(track) == -1:
		list = list+", \n"+str(track)
	file.store_string(list)
	file.close()

func store(type):
	var list 
	var file = File.new()
	file.open("user://database/"+type+".dat", File.WRITE)
	match type:
		"tracks":
			#load_cache("tracks")
			list = str(tracks.size())
			for t in tracks:
				list = list+", \n"+to_json(t)
		"artists":
			#load_cache("artists")
			list = str(artists.size())
			for t in artists:
				list = list+", \n"+to_json(t)
		"genres":
			#load_cache("genres")
			list = str(genres.size())
			for t in genres:
				list = list+", \n"+to_json(t)
				
	file.store_string(list)
	file.close()

func build_genres(track):
	var list = ""
	var genre = ""
	var file = File.new()
	var tracked = str(track).split("', ")
	if len(tracked) == 17 or len(tracked) == 19:
		if tracked[7].split("'")[1]:
			genre = tracked[7].split("'")[1]
			list =local_knowledge_load(tracked[7].split("'")[1])
	if len(tracked) == 16 or len(tracked) == 15:
		if tracked[6].find("'") != -1:
			genre = tracked[6].split("'")[1]
			list =local_knowledge_load(tracked[6].split("'")[1])
		else:
			genre = tracked[6]
			list =local_knowledge_load(tracked[6])
		
	if list.find(str(track)+",") == -1:
		file.open("user://database/genres/"+genre+".dat", File.WRITE)
		file.store_string(list+", \n"+str(track))
	file.close()

func create_playlist(name):
	print(name)
	var file = File.new()
	if !file.file_exists("user://playlists/"+name+".dat"):
		file.open("user://playlists/"+name+".dat",File.WRITE)
		file.close()
		return(true)
	else:
		return(false)
		
func find_track(ogg):
	var num = -1
	for t in Thicket.tracks:
		num = num+1
		if t:
			if t["ogg"] == ogg:
				break
				
	return num
	
func check_cache(type):
	var file = File.new()
	if file.file_exists("user://database/"+type+".dat"):
		return 1
	else:
		return 0
		
func load_cache(type):
	match type:
		"artists":
			artists = local_knowledge_load(type)
		"new_artists":
			new_artists = local_knowledge_load(type)
		"new_tracks":
			new_tracks = local_knowledge_load(type)
		"tracks":
			tracks = local_knowledge_load(type)
		"genres":
			genres = local_knowledge_load(type)
		"connections":
			connections_list = local_knowledge_load(type)
			
func create_developer(cName,pCon,email,steemaccount,about):
	var account = '"devName":"'+cName+'","contactName":"'+pCon+'","contactEmail":"'+email+'","steem":"'+steemaccount+'"'
	var created = OpenSeed.get_from_socket('{"act":"create_developer","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'",'+account+'}')
	var datastring = '"theid":"'+created+'","data1":"'+cName+\
	'","data2":"'+pCon+'","data3":"'+email+'","data4":"'+steemaccount+'","data5":{"about":"'+about+'}'
	var response = OpenSeed.get_from_socket('{"act":"create_profile","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'",'+datastring+',"type":2}')
	#print(datastring)
	dev_profile = datastring
	return created
	
func _on_new_tracks(data):
	load_cache("tracks")
	print("Before New Tracks "+str(len(tracks)))
	var ntracks = data.split("}, ")
	new_tracks = []
	if data:
		for track in ntracks:
			if track[0] == "[":
				track = track.trim_prefix("[")
			var parsed_track = parse_json(track+"}")
			new_tracks.append(parsed_track)
		for test in new_tracks:
			var found = false
			for in_library in tracks:
				if in_library and in_library["title"] == test["title"]:
					found = true
					break
			if !found:
				#print("New Track "+test["title"])
				tracks.append(test)
		
		print("After New Tracks "+str(len(tracks)))
		#store("tracks")

	emit_signal("new_tracks_ready")

func ipfs_upload(file):
	var the_hash = []
	OS.execute(OpenSeed.ipfs,["add",file],true,the_hash)
	
	return str(the_hash[0]).split(" ")[1]

func application_list():
	if OS.get_name() == "X11":
		var dir = Directory.new()
		for place in ["/usr/share/applications","user://../../../applications"]:
			if dir.dir_exists(place):
				dir.open(place)
				dir.list_dir_begin()
				var file_name = dir.get_next()
				while (file_name != ""):
					if !dir.current_is_dir():
						var name = file_name
						for ns in ["org.","net.","io.","com."]:
							if file_name.substr(0,4).find(ns) != -1:
								#print(file_name)
								name = file_name.split(".")[2]
								break	
						applications.append(name+"::"+place+"/"+file_name)
					#else:
					#	print(file_name)
					file_name = dir.get_next()
		applications.sort()
	#print(applications)
	pass
	
func favorite_app_list():
	var file = File.new()
	if OS.get_name() == "X11":
		if file.exists("user://database/fav_apps.dat"):
			favorite_apps = local_knowledge_load("fav_apps")
			
	pass
