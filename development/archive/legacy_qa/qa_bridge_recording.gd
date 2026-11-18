extends "res://tests/qa_bridge_matrix.gd"
## Recorded isolated approach demonstrations; these do not claim a full playthrough.
func run() -> void:
	root.size=viewport_size
	record_interval=6
	for cake_mode in [false,true]:
		for offset in ([-64,16] if not cake_mode else [-32,10]):
			await fixture(cake_mode,1,offset)
			await frames(18)
			Input.action_press(action(owner,"ability"))
			await until(func():return active(),240)
			await frames(36)
			Input.action_release(action(owner,"ability"))
			await until(func():return anchor.state==0,240)
			await frames(15)
			check("recorded approach, formation and release restore controls",restored())
	await finish("Bridge recording")
