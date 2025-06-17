extends PanelContainer

const FileDisplay = preload("res://file_display.gd")
const FILE_DISPLAY = preload("res://file_display.tscn")

const SUPPORTED_EXTENSIONS: PackedStringArray = ["ogg", "mp3", "wav"]

var filepath: String
var _audio: AudioStream = null
var _dragging := false

@onready var play_button: Button = %PlayButton
@onready var stop_button: Button = %StopButton
@onready var progress: HSlider = %Progress
@onready var label: Label = %Label
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer


static func create(path: String) -> FileDisplay:
	var pd := FILE_DISPLAY.instantiate()
	pd.filepath = path
	return pd


func _ready() -> void:
	play_button.pressed.connect(_play_pressed)
	stop_button.pressed.connect(audio_stream_player.stop)
	progress.drag_started.connect(func() -> void: _dragging = true)
	progress.drag_ended.connect(func(__: Variant) -> void: _dragging = false)
	progress.value_changed.connect(_playhead_position_changed)
	label.text = filepath


func _process(delta: float) -> void:
	if audio_stream_player.playing:
		if _dragging:
			return
		progress.set_value_no_signal((audio_stream_player.get_playback_position()
			+ AudioServer.get_time_since_last_mix())
			/ _audio.get_length())


func _play_pressed() -> void:
	if _setup_audio():
		audio_stream_player.play()


func _playhead_position_changed(to: float) -> void:
	if not is_instance_valid(_audio): return
	audio_stream_player.play(to * _audio.get_length())


func _setup_audio() -> bool:
	if _audio == null:
		# load from file
		var extension := filepath.get_extension()
		if extension.is_empty() or extension not in SUPPORTED_EXTENSIONS:
			return false

		var loader: Variant = {"ogg": AudioStreamOggVorbis, "mp3": AudioStreamMP3, "wav": AudioStreamWAV}.get(extension)
		if loader == null:
			return false
		_audio = loader.load_from_file(filepath)
		audio_stream_player.stream = _audio
	return true
