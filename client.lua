local vehicles = {
    { 
        category = 'compacts', 
        models = {
            'rebel2', 'riata', 'sandking', 'sandking2', 'trophytruck',
            'trophytruck2',
 
            -- SEDANS
            'asea', 'asterope', 'cog55', 'cogcabrio', 'emperor', 'fugitive', 'glendale', 'ingot',
            'intruder', 'premier', 'primo', 'primo2', 'schafter2', 'stafford', 'stratum', 'stretch',
            'superd', 'surge', 'tailgater', 'warrener', 'washington',
 
            -- SPORTS CLASSICS
            'casco', 'cheetah2', 'coquette2', 'dynasty', 'fagaloa', 'feltzer3', 'gt500', 'hotring',
            'infernus2', 'jb7002', 'manana', 'manana2', 'mamba', 'monroe', 'nebula', 'peyote3',
            'pigalle', 'rapidgt', 'rapidgt2', 'retinue', 'stinger', 'stingergt', 'stromberg', 'swinger',
            'turismo2', 'viseris',
 
            -- SUPER
            'adder', 'autarch', 'bullet', 'cheetah', 'cyclone', 'deveste', 'emerus', 'entityxf',
            'entity2', 'entity3', 'krieger', 'le7b', 'nero', 'nero2', 'osiris', 'prototipo', 'reaper',
            'sc1', 't20', 'tempesta', 'tigon', 'tyrant', 'vacca', 'vagner', 'visione', 'voltic',
            'xa21', 'zentorno', 'zorrusso',
 
            -- SUVs
            'baller', 'baller2', 'baller3', 'cavalcade', 'cavalcade2', 'fq2', 'granger', 'gresley',
            'habanero', 'huntley', 'landstalker', 'landstalker2', 'patriot', 'patriot2', 'radi',
            'rocoto', 'seminole', 'seminole2', 'toros', 'xls',
 
            -- VANS
            'bison', 'burrito', 'gburrito', 'minivan', 'minivan2', 'paradise', 'rumpo', 'rumpo3',
            'surfer', 'surfer2', 'youga', 'youga2', 'youga3',
 
            -- ADDON MODELS
            'gbadmiral', 'gbarcherpro2', 'gbargento2f', 'gbargento7f', 'gbargento7fs', 'gbbanshees',
            'gbbisonhf', 'gbbisonstx', 'gbbriosof', 'gbcheetahs', 'gbclubxr', 'gbcometcl', 'gbcometclf',
            'gbcomets2r', 'gbcomets2rc', 'gbcyphergts', 'gbdominatorgsx', 'gbechelon', 'gbechelons',
            'gbelegyrh2', 'gbemerussb1', 'gbeon', 'gberotiq', 'gbesurfer', 'gbgresleystx', 'gbhades',
            'gbharmann', 'gbhedra', 'gbhedrakombi', 'gbhurricane', 'gbimpaler', 'gbimpalerdlx', 'gbirisz',
            'gbissimetro', 'gbkomodagt', 'gblod4', 'gbmilano', 'gbmochi', 'gbmogulrs', 'gbmojave',
            'gbmugello', 'gbneonct', 'gbnexusrr', 'gbprospero', 'gbraidillon', 'gbretinueloz', 'gbromulus',
            'gbronin', 'gbrumina', 'gbsapphire', 'gbschlagenr', 'gbschlagensp', 'gbschrauber',
            'gbschwartzers', 'gbscoutgsx', 'gbsentinelgts', 'gbsidewinder', 'gbsolace', 'gbsolacev',
            'gbstanierle', 'gbstarlight', 'gbsteedcrew', 'gbsteedvan', 'gbsultanrsx', 'gbtahomagt',
            'gbtaxiargento7f', 'gbtempestafs', 'gbtenfr', 'gbtr3s', 'gbturismogt', 'gbturismogts',
            'gbvigerorat', 'gbvivant', 'gbvivantgrb', 'gbvoyagerb', 'gbvoyagerb2', 'gbzeitgeist',
        }
    }
}

--- Environment
local weather = 'EXTRASUNNY' -- Weather type whilst spawning vehicles
local hour = 10 -- Game time hour whist spawning vehicles

--- Track cam
local cam_active = false
local cam = nil

--- Cam positioning
-- Modify these values to move the cam position, change rotation, fov or z height
local cam_pos = vec3(901.51, -55.84, 77.76) -- Cam position
local cam_rot = vector3(-0.0, 0.0, -382.0) -- Cam rotation
local cam_fov = 35.0 -- Field of view
local z_modifier = 1.0 -- Increase z height of cam

--- Vehicle spawn location
local vehicle_spawn = vec4(903.83, -50.19, 77.35, 103.17)

--- Sets current weather and time to values
local function set_weather_and_time()
    while true do
        SetWeatherTypePersist(weather)
        SetWeatherTypeNowPersist(weather)
        SetWeatherTypeNow(weather)
        SetOverrideWeather(weather)
        NetworkOverrideClockTime(hour, 0, 0)
        Wait(5000)
    end
end

--- Toggle cam
local function setup_camera(enable)
    if enable then
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        local cam_pos = cam_pos
        local cam_rot = cam_rot
        SetCamCoord(cam, cam_pos.x, cam_pos.y, cam_pos.z + z_modifier)
        SetCamRot(cam, cam_rot.x, cam_rot.y, cam_rot.z, 2)
        SetCamActive(cam, true)
        SetCamFov(cam, cam_fov)
        RenderScriptCams(true, false, 0, true, true)
        cam_active = true
    else
        if cam_active then
            RenderScriptCams(false, false, 0, true, true)
            DestroyCam(cam, false)
            cam_active = false
        end
    end
end

--- Spawn vehicles
local function spawn_vehicle(model_name)
    local model = GetHashKey(model_name)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end
    local pos = vehicle_spawn
    local vehicle = CreateVehicle(model, pos.x, pos.y, pos.z, pos.w, true, false)
    return vehicle
end

--- Takes screenshot through screenshot-basic, uploads binary to local FiveM HTTP server
local function take_screenshot_and_send(model, category)
    local serverUrl = string.format('http://localhost:30120/%s/upload/%s/%s', GetCurrentResourceName(), category, model)
    exports['screenshot-basic']:requestScreenshotUpload(serverUrl, 'file', function(data)
        local resp = json.decode(data)
        if not resp or resp.status ~= 'ok' then
            print('[vehicle_image_creator] Upload failed for: ' .. model .. ' | ' .. tostring(data))
        end
    end)
end

--- Setup cam, spawn vehicle and screenshot
local function capture_vehicles(enable_camera, specific_category)
    setup_camera(enable_camera)
    for _, category_data in ipairs(vehicles) do
        if specific_category == nil or specific_category == category_data.category then
            local category = category_data.category
            for _, model in ipairs(category_data.models) do
                local vehicle = spawn_vehicle(model)
                Wait(2000)
                take_screenshot_and_send(model, category)
                Wait(5000)
                DeleteVehicle(vehicle)
            end
        end
    end
    setup_camera(false)
end

--- Start the capturing process
-- @usage /capture_vehicles compacts
RegisterCommand('capture_vehicles', function(source, args)
    local enable_camera = true
    local specific_category = args[1] or nil
    capture_vehicles(enable_camera, specific_category)
end, false)

--- Toggle cam
-- Used for testing cam positions before starting capture
RegisterCommand('setupcam', function()
    setup_camera(not cam_active)
end, false)

--- Weather & time thread
CreateThread(set_weather_and_time)