extends Node2D

const TILES = {
	"Deep": 0,
	"Shallow": 1,
	"Sand": 2,
	"Grass": 3,
	"Forest": 4,
	"Mountain": 5,
}
const TILES_LEVEL = {
	"Shallow": 20,
	"Sand": 30,
	"Grass": 40,
	"Forest": 50,
	"Mountain": 90
}
#var screen_size := OS.window_size;
var octaves := 9; #fractal (increase)
var period := 140; #zoom in (increase)
var lacunarity := 2; #smothness (increase)
var persistence := 0.5; #how consistent next sample in relation to the last (increase)
var tile_size := 16;
onready var tilemap := $TileMap;
onready var player := $YSort/Player;
onready var tileset : TileSet = $TileMap.tile_set;
var fog_width = 100;
var fog_height = 100;
var noise;
var map_size = 4000;

func _ready() -> void:
	randomize();
	noise = OpenSimplexNoise.new();
	noise.seed = randi();
	noise.octaves = octaves;
	noise.period = period;
	noise.lacunarity = lacunarity;
	noise.persistence = persistence;
	generate();
	move_player();

#move player to a Shallow tile in case player gets stuck on Mountain
func move_player() -> void:
	for tile in tilemap.get_used_cells():
		if tilemap.get_cellv(tile) == tileset.find_tile_by_name(String(TILES.Shallow)):
			player.position.x = tilemap.map_to_world(tile).x;
			player.position.y = tilemap.map_to_world(tile).y;
			return;
	
func _physics_process(delta) -> void:
	var x_pos = player.position.x;
	var y_pos = player.position.y;
	x_pos = clamp(x_pos, -map_size/2, map_size/2);
	y_pos = clamp(y_pos, -map_size/2, map_size/2);
	player.position.x = x_pos;
	player.position.y = y_pos;
	
func _process(delta) -> void:
	generate();
	
func get_player_map_position() -> Vector2:
	var position: Vector2;
	position.x = tilemap.world_to_map(player.position).x; 
	position.y = tilemap.world_to_map(player.position).y;
	return position;
	
func generate() -> void:
	var player_map_position = get_player_map_position(); #player position in tile cell
	var cell_cap = map_size / tile_size / 2; #map size in tile cell
		
	player_map_position.x -= fog_width/2;
	var x_pos = player_map_position.x;
	player_map_position.y -= fog_height/2;
	var y_pos = player_map_position.y;
	
	for x in range(0, fog_width, 1):
		if cell_cap + 2 <= abs(x_pos + x):
			continue;
		for y in range(0, fog_height, 1):
			if cell_cap + 2 <= abs(y_pos + y):
				continue;
			var rand = abs(noise.get_noise_2d(x_pos + float(x), y_pos + float(y)))*255;
			tilemap.set_cell(x_pos + x, y_pos + y, _get_tile_index(rand));

func _get_tile_index(sample):
	if sample < TILES_LEVEL.Shallow:
		return TILES.Deep
	if sample > TILES_LEVEL.Mountain:
		return TILES.Mountain
	if sample > TILES_LEVEL.Forest:
		return TILES.Forest
	if sample > TILES_LEVEL.Grass:
		return TILES.Grass
	if sample > TILES_LEVEL.Sand:
		return TILES.Sand
	if sample > TILES_LEVEL.Shallow:
		return TILES.Shallow
	
	
	
	
