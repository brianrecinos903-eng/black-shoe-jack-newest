extends Area2D

enum Role{SENDER, RECIEVER}

const MARGIN: float = 700
const EXIT_MARGIN: float = 30

@export var cooldown_timer: Timer
@export var role: Role #Sender is from main level reciever is from hidden room that is despawned
@export var room: String #The path to scene of your choosing to spawn
@export var exit_dir := Vector2.RIGHT #The side of the door you want player to spawn on

var partner
var spawned_room

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or !cooldown_timer.is_stopped():
		return

	match role:
		Role.SENDER:
			var dest = load(room).instantiate()
			dest.position = Vector2(0, _get_world_bottom(get_tree().current_scene) + MARGIN)
			spawned_room = dest
			partner = dest.hidden_door
			partner.partner = self
			get_tree().root.add_child.call_deferred(dest)
			_send.call_deferred(body, partner)
			_send.call_deferred(body, partner)
			
		Role.RECIEVER:
			var back = partner
			back.spawned_room.queue_free()
			back.spawned_room = null
			_send(body, back)

func _send(body: Node2D, target: Area2D) -> void:
	body.global_position = target.global_position + EXIT_MARGIN * target.exit_dir
	target.cooldown_timer.start()


func _get_world_bottom(root: Node) -> float:
	var bottom := -INF
	for layer in root.find_children("*", "TileMapLayer", true, false):
		var rect = layer.get_used_rect()
		if rect.size == Vector2i.ZERO:
			continue
		var local_y = layer.map_to_local(Vector2i(rect.position.x, rect.end.y)).y
		bottom = maxf(bottom, layer.to_global(Vector2(0, local_y)).y)
	return bottom
			
