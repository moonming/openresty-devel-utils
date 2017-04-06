math.randomseed(os.time())

local math_random = math.random
local table_concat = table.concat

-- uri_charset
local uri_charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._~:/@!,;=+*-"
local uri_charset_length = string.len(uri_charset)
local uri_random_charset = {}

for i = 1, uri_charset_length do
    uri_random_charset[i] = string.sub(uri_charset, i, i)
end

-- header_key_charset
local key_charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
local key_charset_length = string.len(key_charset)
local key_random_charset = {}

for i = 1, key_charset_length do
    key_random_charset[i] = string.sub(key_charset, i, i)
end

-- header_value_charset
local value_charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ !~^@#/.;:+=*?<>"
local value_charset_length = string.len(value_charset)
local value_random_charset = {}

for i = 1, value_charset_length do
    value_random_charset[i] = string.sub(value_charset, i, i)
end

-- load ua
local ua = {}
local pwd = os.getenv("PWD") .. "/"
local ua_file = io.open(pwd .. "ua.txt")
local ua_count = 0
while true do
    local line = ua_file:read()
    if line == nil then
        break
    end
    if line ~= '' then
        ua_count = ua_count + 1
        table.insert(ua, line)
    end
end

local function gen_uri_comp()
    local value = {}
    local len = math_random(20) -- between 1 and 20

    for i = 1, len do
        if math_random(3) == 1 then
            local c = math_random(255)
            c = string.format("%.02x", c)
            if math_random(2) == 1 then -- 50% upper
                value[i] = '%' .. string.upper(c)
            else
                value[i] = '%' .. string.lower(c)
            end
        else
            value[i] = uri_random_charset[math_random(uri_charset_length)]
        end
    end

    return table_concat(value, "")
end

local function gen_args()
    local n = math_random(30)
    local args = {}

    for i = 1, n do
        local key = gen_uri_comp()
        local value = gen_uri_comp()
        args[i] = key .. "=" .. value
    end

    return table_concat(args, "&")
end

local function gen_path()
    local n = math_random(20)
    local comp = {}

    for i = 1, n do
        comp[i] = gen_uri_comp()
    end

    local url = table_concat(comp, "/")
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
    return ua[math_random(ua_count)]
end

local function gen_header()
    local headers = {}
    local n = math_random(50)

    for i = 1, n do
        local len = math_random(20)
        local key = {}
        for j = 1, len do
            key[j] = key_random_charset[math_random(key_charset_length)]
        end

        len = math_random(50)
        local value = {}
        for k = 1, len do
            value[k] = value_random_charset[math_random(value_charset_length)]
        end

        headers[table_concat(key, '')] = table_concat(value, '')
    end

    headers['User-Agent'] = gen_ua()
    headers['Connection'] = 'Keep-Alive'

    return headers
end

function request()
    local method = "GET"
    local url = gen_url()
    local headers = gen_header()
    local body = nil

    local n = math_random(5)
    if n == 1 then -- 20% are POST requests
        method = "POST"
        body = gen_args()
        local len = string.len(body)
        headers["Content-Length"] = len
    end

    return wrk.format(method, url, headers, body)
end