--- imgBB API key - get one free at https://api.imgbb.com/
local IMGBB_API_KEY = 'YOUR_IMGBB_API_KEY'
local image_urls_file = 'image_urls.json'
local image_urls = {}

local function save_image_urls()
    local status, result = pcall(json.encode, image_urls, { indent = true })
    if status then
        SaveResourceFile(GetCurrentResourceName(), image_urls_file, result, -1)
    else
        print('Failed to encode image URLs: ' .. result)
    end
end

local function append_to_txt(category, model, image_url)
    local txt_file = string.format('%s.txt', category)
    local existing = LoadResourceFile(GetCurrentResourceName(), txt_file) or ''
    local line = string.format('%s = %s\n', model, image_url)
    SaveResourceFile(GetCurrentResourceName(), txt_file, existing .. line, -1)
end

local function save_image(image_url, category, model)
    table.insert(image_urls, { category = category, url = image_url, model = model })
    save_image_urls()
    append_to_txt(category, model, image_url)
    print('[vehicle_image_creator] Saved: ' .. model .. ' -> ' .. image_url)
end

local function upload_to_imgbb(base64data, category, model)
    local b64 = base64data:gsub('+', '%%2B'):gsub('/', '%%2F'):gsub('=', '%%3D')
    local url = string.format('https://api.imgbb.com/1/upload?key=%s', IMGBB_API_KEY)
    local body = string.format('image=%s&name=%s', b64, model)
    PerformHttpRequest(url, function(status, response)
        if status == 200 then
            local resp = json.decode(response)
            if resp and resp.success and resp.data and resp.data.url then
                save_image(resp.data.url, category, model)
            else
                print('[vehicle_image_creator] imgBB bad response for: ' .. model .. ' | ' .. tostring(response))
            end
        else
            print('[vehicle_image_creator] imgBB HTTP error ' .. tostring(status) .. ' for: ' .. model .. ' | ' .. tostring(response))
        end
    end, 'POST', body, { ['Content-Type'] = 'application/x-www-form-urlencoded' })
end

SetHttpHandler(function(req, res)
    if req.method == 'POST' and req.path:find('/upload') then
        local category = req.path:match('/upload/([^/]+)/') or 'unknown'
        local model = req.path:match('/upload/[^/]+/([^/]+)') or 'unknown'
        req.setDataHandler(function(body)
            -- Extract image bytes from multipart body (skip headers until double CRLF, trim trailing boundary)
            local imageData = body:match('\r\n\r\n(.+)\r\n%-%-') or body:match('\r\n\r\n(.+)$') or body
            local b64 = base64Encode(imageData)
            upload_to_imgbb(b64, category, model)
            res.writeHead(200, { ['Content-Type'] = 'application/json' })
            res.send('{"status":"ok"}')
        end)
    else
        res.writeHead(404)
        res.send('not found')
    end
end)

function base64Encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r, b64 = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b64 % 2 ^ i - b64 % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
        return b:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

RegisterNetEvent('vehicle_image_creator:upload_image')
AddEventHandler('vehicle_image_creator:upload_image', function(base64data, category, model)
    upload_to_imgbb(base64data, category, model)
end)

RegisterNetEvent('vehicle_image_creator:save_image_url')
AddEventHandler('vehicle_image_creator:save_image_url', function(image_url, category, model)
    save_image(image_url, category, model)
end)
