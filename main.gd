extends Control

const FileDisplay = preload("res://file_display.gd")

@onready var files_container: VBoxContainer = %FilesContainer

@onready var load_button: Button = %LoadButton
@onready var clear_button: Button = %ClearButton

@onready var file_dialog: FileDialog = %FileDialog


func _ready() -> void:
	clear_button.pressed.connect(func() -> void:
		files_container.get_children().map(func(a: Node) -> void: a.queue_free())
	)
	load_button.pressed.connect(func() -> void:
		file_dialog.show()
	)
	file_dialog.dir_selected.connect(_dir_selected)


func _dir_selected(dir_p: String) -> void:
	var dir := DirAccess.open(dir_p)
	if not dir:
		return
	dir.list_dir_begin()
	var fn := dir.get_next()
	while fn != "":
		if dir.current_is_dir():
			_dir_selected(dir_p + "/" + fn)
			fn = dir.get_next()
			continue

		if fn.get_extension() in FileDisplay.SUPPORTED_EXTENSIONS:
			var fd := FileDisplay.create(dir_p + "/" + fn)
			files_container.add_child(fd)

		fn = dir.get_next()
