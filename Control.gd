extends Control

var master_bus = AudioServer.get_bus_index("Master")

@onready var progress_bar = $Panel/ProgressBar
@onready var file_dialogue = $Panel/FileDialog
@onready var current_filetext = $Panel/Label2
@onready var audio_stream_player: AudioStreamPlayer = $Panel/AudioStreamPlayer
@onready var play_button = $Panel/Button2
@onready var track_list = $Tracklist
@onready var animation_player = $Tracklist/AnimationPlayer
@onready var open_tracklist_button = $Tracklist/OpenTracklist
@onready var volume_slider = $Panel/HSlider
@onready var vbox_container = $Tracklist/ScrollContainer/VBoxContainer
@onready var example_track = $ExampleTrack

func play_track(path):
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	var buffer = file.get_file_as_bytes(path)
	
	var mp3 = AudioStreamMP3.new()
	mp3.data = buffer
	file.close()

	audio_stream_player.stream = mp3
	current_filetext.text = path

func _on_button_pressed():
	file_dialogue.popup_centered(Vector2i(600,400))
	#file_dialogue.set_filters(PackedStringArray(["*.wav ; Wav Audio","*.mp3 ; Mpeg Audio"]))

func add_to_tracklist(file_name, path):
	var track: LinkButton = example_track.duplicate()
	track.text = file_name
	track.set_meta("path", path)
	track.connect("pressed", self.when_track_pressed.bind(track))
	track.show()
	
	vbox_container.add_child(track)

func create_tracklist_for_directory(directory_path):
	var directory = DirAccess.open(directory_path)
	var files = directory.get_files()
	
	for file_path in files:
		if file_path.ends_with(".mp3"):
			var full_path = directory_path + "/" + file_path
			add_to_tracklist(file_path, full_path)

func when_track_pressed(track:LinkButton):
	var path: String = track.get_meta("path")
	play_track(path)

func _on_file_dialog_dir_selected(dir): create_tracklist_for_directory(dir)

var playback_time: float = 0.0

func _process(delta):
	if audio_stream_player.playing:
		playback_time = audio_stream_player.get_playback_position()
		
	if audio_stream_player.stream != null:
		progress_bar.value = playback_time * progress_bar.max_value / audio_stream_player.stream.get_length()
	
	opening = animation_player.is_playing()
	open_tracklist_button.disabled = opening

func _on_button_2_pressed():	
	audio_stream_player.play(playback_time)

func _on_button_3_pressed():
	audio_stream_player.stop()

func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)
	AudioServer.set_bus_mute(master_bus, value == volume_slider.min_value)

var opened: bool = false
var opening: bool = false

func open_tracklist(): animation_player.play("slidein")
func close_tracklist(): animation_player.play("slideout")

func _ready(): 
	animation_player.play("reset")
	opened = true

func _on_open_tracklist_pressed():
	# cancel if already opening or closing
	if opening: return
	
	if opened: open_tracklist() 
	else: close_tracklist()
	opened = not opened
