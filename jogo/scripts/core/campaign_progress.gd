extends RefCounted
## Progresso local da campanha; coleta, conclusão e ritual são conquistas distintas.
## O caminho pode ser substituído por uma fixture externa, sem tocar no save do jogador.
static func tree() -> SceneTree:return Engine.get_main_loop() as SceneTree
static func path() -> String:return String(tree().get_meta("campaign_profile_path","user://friendship_campaign_v1.json"))
static func read() -> Dictionary:
	if tree().get_meta("campaign_cache_path","")==path() and tree().has_meta("campaign_cache"):return tree().get_meta("campaign_cache").duplicate(true)
	var data: Dictionary={"version":1,"completed":[],"crystals":[],"restored":false}
	if FileAccess.file_exists(path()):
		var parsed=JSON.parse_string(FileAccess.get_file_as_string(path()))
		if parsed is Dictionary:
			for key in ["completed","crystals"]:
				if parsed.get(key) is Array:
					for n in parsed[key]:
						if n is float or n is int:
							var number:=int(n)
							if number>=1 and number<=6 and not number in data[key]:data[key].append(number)
			data.restored=parsed.get("restored",false)==true and data.completed.size()==6
	tree().set_meta("campaign_cache_path",path());tree().set_meta("campaign_cache",data.duplicate(true))
	return data
## Grava em arquivo temporário e troca atomicamente; mantém a versão anterior se falhar.
static func write(data: Dictionary) -> bool:
	var file:=FileAccess.open(path()+".tmp",FileAccess.WRITE)
	if file==null:push_error("Não foi possível gravar o progresso da aventura.");return false
	file.store_string(JSON.stringify(data));file.close()
	var error:=DirAccess.rename_absolute(path()+".tmp",path())
	if error!=OK:push_error("Não foi possível finalizar a gravação do progresso.")
	if error==OK:tree().set_meta("campaign_cache_path",path());tree().set_meta("campaign_cache",data.duplicate(true))
	return error==OK
static func collect(number: int) -> void:
	var data:=read()
	if not number in data.crystals:data.crystals.append(number);write(data)
static func complete(number: int) -> void:
	var data:=read()
	if number in data.completed and number in data.crystals:return
	if not number in data.completed:data.completed.append(number)
	if not number in data.crystals:data.crystals.append(number)
	write(data)
## Só a sequência contínua libera fases: concluir F6 pelo editor não libera a campanha.
static func unlocked(number: int) -> bool:
	var completed: Array=read().completed
	for n in range(1,number):
		if not n in completed:return false
	return number>=1 and number<=6
static func restore_world() -> bool:
	var data:=read()
	if data.completed.size()!=6 or data.crystals.size()!=6:return false
	data.restored=true;return write(data)
static func reset() -> void:
	write({"version":1,"completed":[],"crystals":[],"restored":false})
	tree().set_meta("friendship_crystals",[])
