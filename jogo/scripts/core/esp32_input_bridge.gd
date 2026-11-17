extends Node
## Ponte local: recebe máscaras dos controles ESP32 e aciona o InputMap existente.
## Não altera movimento, física, estados de puzzles ou habilidades de personagens.
const PORT := 42033
const TIMEOUT_SECONDS := 0.35
const ACTIONS := ["left", "right", "jump", "interact", "ability"]
const FULL_MASK := 31
var _udp := PacketPeerUDP.new()
var _mask := {1: 0, 2: 0}
var _last_seen := {1: -100.0, 2: -100.0}
var _clock := 0.0

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    var err := _udp.bind(PORT, "127.0.0.1")
    if err != OK:
        push_warning("ESP32: porta UDP %d indisponível (%d)." % [PORT, err])
        set_process(false)

func _process(delta: float) -> void:
    _clock += delta
    var count := mini(_udp.get_available_packet_count(), 128)
    for i in count:
        var message := _udp.get_packet().get_string_from_utf8().strip_edges()
        var values := message.split(",")
        if values.size() != 3 or values[0] != "AT1":
            continue
        if not values[1].is_valid_int() or not values[2].is_valid_int():
            continue
        var player := int(values[1])
        var mask := int(values[2])
        if player not in [1, 2] or mask < 0 or mask > FULL_MASK:
            continue
        _last_seen[player] = _clock
        _set_mask(player, mask)
    for player in [1, 2]:
        if _mask[player] != 0 and _clock - _last_seen[player] > TIMEOUT_SECONDS:
            _set_mask(player, 0)

func _set_mask(player: int, new_mask: int) -> void:
    var old_mask: int = _mask[player]
    if new_mask == old_mask:
        return
    _mask[player] = new_mask
    for i in ACTIONS.size():
        var bit := 1 << i
        if bool(old_mask & bit) == bool(new_mask & bit):
            continue
        var action := StringName("p%d_%s" % [player, ACTIONS[i]])
        if new_mask & bit:
            Input.action_press(action)
        else:
            Input.action_release(action)

func _exit_tree() -> void:
    for player in [1, 2]:
        _set_mask(player, 0)
    _udp.close()
