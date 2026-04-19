# Vehicle Image Creator

Automatically spawns vehicles, takes screenshots, uploads them to **imgBB** and saves the URLs to `.txt` files and `image_urls.json`.

## Dependencies

- [`screenshot-basic`](https://github.com/citizenfx/screenshot-basic) — must be running on your server

## Setup

### 1. Get a free imgBB API key
1. Go to **https://api.imgbb.com/**
2. Sign up / log in
3. Click **"Get API key"**
4. Copy your key

### 2. Add your API key
Open `server.lua` and replace `YOUR_IMGBB_API_KEY` on line 12:
```lua
local IMGBB_API_KEY = 'YOUR_IMGBB_API_KEY'
```

### 3. Add to your server resources
Make sure both `screenshot-basic` and `vehicle_image_creator` are started in your `server.cfg`:
```
ensure screenshot-basic
ensure vehicle_image_creator
```

## Usage

| Command | Description |
|---|---|
| `/capture_vehicles` | Capture all vehicles in all categories |
| `/capture_vehicles compacts` | Capture only the `compacts` category |
| `/setupcam` | Toggle the scripted camera (for testing position) |

## Output

After running `/capture_vehicles`, two files are saved inside the resource folder:

- **`<category>.txt`** — one line per vehicle: `model = https://i.ibb.co/...`
- **`image_urls.json`** — all entries in JSON format

## Configuration

All config is at the top of `client.lua`:

| Variable | Description |
|---|---|
| `weather` | Weather type during capture (default: `EXTRASUNNY`) |
| `hour` | In-game hour during capture (default: `10`) |
| `cam_pos` | Camera world position |
| `cam_rot` | Camera rotation |
| `cam_fov` | Camera field of view |
| `z_modifier` | Extra Z height offset for camera |
| `vehicle_spawn` | Where vehicles are spawned (x, y, z, heading) |

## Adding Vehicles

Edit the `vehicles` table in `client.lua`. Each entry has a `category` and a list of `models`:
```lua
{ category = 'sports', models = { 'adder', 'bullet', 'cheetah' } }
```
