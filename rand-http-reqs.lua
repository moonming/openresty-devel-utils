math.randomseed(os.time())

local function gen_path()
    return ''
end

local function gen_url()
    local url = gen_path() .. "?" .. gen_args()
    local max_size = 10240
    if string.length(url) > max_size) then
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

local function gen_args()
    return "a=1&b=2"
end

request = function()
    local method = "GET"
    local url = gen_url()
    local headers = gen_header()
    local body = nil

    local n = math.random(5)
    if n == 1 then
        method = "POST"
        body = gen_args()
        local len = string.len(body)
        headers["Content-Length"] = len
    end

    return wrk.format(method, url, headers, body)
end