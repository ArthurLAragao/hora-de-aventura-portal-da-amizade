@tool
extends RefCounted
## Texturas nativas preparadas offline; o jogo não recorta ou redimensiona imagens.
const FILES = {
	"forest:128": "res://Assets/02_Environments/runtime_prepared/forest_128.png",
	"forest:96": "res://Assets/02_Environments/runtime_prepared/forest_96.png",
	"fringe:128": "res://Assets/02_Environments/runtime_prepared/fringe_128.png",
	"rock:64": "res://Assets/02_Environments/runtime_prepared/rock_64.png",
	"portal:128": "res://Assets/02_Environments/runtime_prepared/portal_128.png",
	"portal:176": "res://Assets/02_Environments/runtime_prepared/portal_176.png",
	"portal:192": "res://Assets/02_Environments/runtime_prepared/portal_192.png",
	"portal:256": "res://Assets/02_Environments/runtime_prepared/portal_256.png",
	"portal:64": "res://Assets/02_Environments/runtime_prepared/portal_64.png"
}

## Carrega uma variante nativa já preparada; falha explicitamente se o tamanho não estiver no catálogo.
static func texture(kind: String,width: int) -> Texture2D:
	var key:=kind+":"+str(width)
	assert(FILES.has(key),"Variante pixel não preparada: "+key)
	# ResourceLoader reutiliza recursos vivos; nenhum cache estático retém texturas de fases encerradas.
	return load(FILES[key]) as Texture2D
