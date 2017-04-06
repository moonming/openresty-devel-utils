math.randomseed(os.time())

local charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._~:/@!,;=+*-"
local charset_length = string.len(charset)
local random_charset = {}

for i = 1, charset_length do
    random_charset[i] = string.sub(charset, i, i)
end

local function gen_uri_comp()
    local value = {}
    local len = math.random(20) -- between 1 and 20

    for i = 1, len do
        if math.random(3) == 1 then
            local c = math.random(255)
            c = string.format("%.02x", c)
            if math.random(2) == 1 then -- 50% upper
                value[i] = '%' .. string.upper(c)
            else
                value[i] = '%' .. string.lower(c)
            end
        else
            value[i] = random_charset[math.random(charset_length)]
        end
    end

    return table.concat(value, "")
end

local function gen_args()
    local n = math.random(30)
    local args = {}

    for i = 1, n do
        local key = gen_uri_comp()
        local value = gen_uri_comp()
        args[i] = key .. "=" .. value
    end

    return table.concat(args, "&")
end

local function gen_path()
    local n = math.random(20)
    local comp = {}

    for i = 1, n do
        comp[i] = gen_uri_comp()
    end

    local url = table.concat(comp, "/")
    return "/" .. url
end

local function gen_url()
    local url = gen_path() .. "?" .. gen_args()
    local max_size = 10240
    if string.len(url) > max_size then
        url = string.sub(url, 1, max_size - 1)
    end
    return url
end

local function gen_ua()
    return "Mozilla/5.0 (compatible; ABrowse 0.4; Syllable)"
end

local function gen_header()
    local headers = {}
    headers['Connection'] = 'Keep-Alive'
    headers['User-Agent'] = gen_ua()
    return headers
end

function request()
    local method = "GET"
    local url = gen_url()
    local headers = gen_header()
    local body = nil

    local n = math.random(5)
    if n == 1 then -- 20% are POST requests
        method = "POST"
        body = gen_args()
        local len = string.len(body)
        headers["Content-Length"] = len
    end

    return wrk.format(method, url, headers, body)
end