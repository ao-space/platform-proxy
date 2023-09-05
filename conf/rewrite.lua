local function Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex, true)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

local redis = require "resty.redis"
local cjson = require "cjson"
local red = redis:new()

-- local host = ngx.var.http_host
local host = string.lower(ngx.var.http_host)

red:set_timeouts(1000, 1000, 1000) -- 1 sec

-- or connect to a unix domain socket file listened
-- by a redis server:
--     local ok, err = red:connect("unix:/path/to/redis.sock")

local ok, err = red:connect(ngx.var.redis_addr, tonumber(ngx.var.redis_port))
if not ok then
    ngx.log(ngx.INFO, " host: ", host, ", ngx.var.redis_addr: ", ngx.var.redis_addr, ", ngx.var.redis_port: ", ngx.var.redis_port, ", msg: failed to connect redis. err: ", err, ", request-id: ", ngx.var.http_request_id)
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say("failed to connect(redis): ", err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    return
end

local res, err = red:auth(ngx.var.redis_password)
if not res then
    ngx.log(ngx.INFO, " host: ", host, ", ngx.var.redis_addr: ", ngx.var.redis_addr, ", ngx.var.redis_port: ", ngx.var.redis_port, ", msg: failed to redis auth. err:", err,  ", request-id: ", ngx.var.http_request_id)
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say("failed to authenticate(redis): ", err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    return
end


local  hostarr = Split(host, ":")
host = hostarr[1]


local domainarr = Split(host, ".")
local firstsecarr = Split(domainarr[1], "-")
local subdomain = firstsecarr[#firstsecarr]

ngx.log(ngx.INFO, "ngx.var.http_host: ", ngx.var.http_host,  ", host: ", host, ", subdomain:", subdomain, ", request-id: ", ngx.var.http_request_id)

local res, err = red:get(string.format("GTR:%s", subdomain))
if not res then
    ngx.log(ngx.INFO, " subdomain: ", subdomain, ", msg:failed to get gt route from redis.  err: ", err,  ", request-id: ", ngx.var.http_request_id)
    ngx.status = 461
    ngx.say("failed to get  gt route from redis.  err: ", err)
    ngx.exit(461) -- user domain not found
    return
end
if res == ngx.null then
    ngx.log(ngx.INFO, " host: ", host, ", msg:failed to get  gt route from redis. err: ", err,  ", request-id: ", ngx.var.http_request_id)
    ngx.status = 461
    ngx.say("failed to get  gt route from redis. err: ", err)
    ngx.exit(461) -- user domain not found
    return
end
ngx.log(ngx.INFO, "route:", res,  ", request-id: ", ngx.var.http_request_id)

local route = cjson.decode(res)

if route.gtSvrNode ~= nil then
    ngx.var.target = route.gtSvrNode .. ":80"
end

if route.gtCliId ~= nil then
    ngx.var.clientid = route.gtCliId
end

local redirectdomain = ""
if route.redirectDomain ~= nil then
    redirectdomain = route.redirectDomain
end

ngx.log(ngx.INFO, " upstream host info| ngx.var.target: ", ngx.var.target, ", ngx.var.clientid: ", ngx.var.clientid,  ", request-id: ", ngx.var.http_request_id)


if redirectdomain ~= "" then
    if route.redirectDomainStatus == 1 then -- 正常重定向
        local url = "https://" .. redirectdomain .. ngx.var.request_uri
        ngx.log(ngx.INFO, " host: ", host, ", rewrite domain: ", redirectdomain, ", url: ", url,  ", request-id: ", ngx.var.http_request_id)
        return ngx.redirect(url, 307)

    else 
        if route.redirectDomainStatus == 2 then  -- 重定向过期
            ngx.log(ngx.INFO, " host: ", host, ", rewrite domain: ", redirectdomain, ", msg: timeout",  ", request-id: ", ngx.var.http_request_id)
            ngx.status = 460
            ngx.say("domain rewrite timeout.")
            ngx.exit(460) -- 
            return
        else
            ngx.log(ngx.INFO, " host: ", host, ", route.redirectDomainStatus: ", route.redirectDomainStatus,  ", msg: redirectDomainStatus invalid",  ", request-id: ", ngx.var.http_request_id)
            ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
            ngx.say("redirectDomainStatus invalid")
            ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
            return
        end
    end
end

