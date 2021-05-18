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
func get_tile_index(sample):
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

#map settings
var first_generate = true;
var octaves := 9; #fractal (increase)
var period := 140; #zoom in (increase)
var lacunarity := 2; #smothness (increase)
var persistence := 0.5; #how consistent next sample in relation to the last (increase)
onready var tile_size : int = $TileMap.cell_size.x;
onready var tilemap := $TileMap;
onready var player := $YSort/Player;
onready var tileset : TileSet = $TileMap.tile_set;
var fog_width = 40; #fog width in tile cell
var fog_height = 40; #fog height in tile cell
var noise;
var map_size = 4000; #map size in pixel

const tree_path = "res://src/Objects/Tree.tscn";
var tree = preload (tree_path);
var tree_list : Array;
var tree_amount_min = 100; #max amount of trees generated procedurally
var tree_amount_max = 300;
var rng = RandomNumberGenerator.new();
var tree_chance = 0.05;
var tree_range := Vector2(45, 80);
var tree_spawn_rate := 30;

onready var tree_spawn_timer := $TreeSpawnTimer;

func _ready() -> void:
	randomize();
	noise = OpenSimplexNoise.new();
	noise.seed = randi();
	noise.octaves = octaves;
	noise.period = period;
	noise.lacunarity = lacunarity;
	noise.persistence = persistence;
	generate_map();
	relocate_player();
	generate_tree();
	first_generate = false;
	
	tree_spawn_timer.set_wait_time(tree_spawn_rate);
	tree_spawn_timer.set_one_shot(false);
	tree_spawn_timer.connect("timeout", self, "grow_tree");
	tree_spawn_timer.start();
	
#move player to a Shallow tile in case player gets stuck on Mountain
func relocate_player() -> void:
	var player_map_position = get_map_position(player.position);
	if tilemap.get_cellv(player_map_position) != tileset.find_tile_by_name(String(TILES.Mountain)):
		return;
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
	#spawn_procedural_tree();
	
func _process(delta) -> void:
	generate_map();
	clear_dead_tree();
	
func get_map_position(position: Vector2) -> Vector2:
	var map_position: Vector2;
	map_position.x = tilemap.world_to_map(position).x; 
	map_position.y = tilemap.world_to_map(position).y;
	return map_position;
	
func generate_map() -> void:
	if player.direction == Vector2.ZERO and not first_generate:
		return;
	var player_map_position = get_map_position(player.position); #player position in tile cell
	var cell_cap = map_size / tile_size; #map size in tile cell
	player_map_position.x -= fog_width/2;
	var x_pos = player_map_position.x;
	player_map_position.y -= fog_height/2;
	var y_pos = player_map_position.y;
	
	for x in range(0, fog_width, 1):
		if cell_cap / 2 + 2 <= abs(x_pos + x):
			continue;
		for y in range(0, fog_height, 1):
			if cell_cap / 2 + 2 <= abs(y_pos + y):
				continue;
			if tilemap.get_cell(x_pos + x, y_pos + y) == tilemap.INVALID_CELL:
				var rand = abs(noise.get_noise_2d(x_pos + x, y_pos + y))*255;
				tilemap.set_cell(x_pos + x, y_pos + y, get_tile_index(rand));

func generate_tree():
	for x in range(-map_size / tile_size / 2, map_size / tile_size / 2, 1):
		for y in range(-map_size / tile_size / 2, map_size / tile_size / 2, 1):
			var rand = abs(noise.get_noise_2d(x, y))*255;
			if rand > tree_range.x and rand < tree_range.y:
				rng.randomize();
				rand = rng.randf_range(0.0, 1.0);
				if(rand < tree_chance):
					var t = tree.instance();
					$YSort.add_child(t);
					t.position.x = x * tile_size; 
					t.position.y = y * tile_size; 
					tree_list.append(t);
			
func grow_tree():
	if tree_list.size() > tree_amount_max:
		return;
	rng.randomize();
	var rand_x = rng.randi_range(- map_size / tile_size, map_size / tile_size);
	var rand_y = rng.randi_range(- map_size / tile_size, map_size / tile_size);
	if tilemap.get_cell(rand_x, rand_y) == tileset.find_tile_by_name(String(TILES.Grass)) \
	or tilemap.get_cell(rand_x, rand_y) == tileset.find_tile_by_name(String(TILES.Forest)):
		var t = tree.instance();
		$YSort.add_child(t);
		t.position.x = rand_x * tile_size; 
		t.position.y = rand_y * tile_size; 
		tree_list.append(t);

func clear_dead_tree():
	for tree in tree_list:
		if is_instance_valid(tree):
			tree_list.erase(tree);
