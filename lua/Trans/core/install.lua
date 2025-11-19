---@class Trans
---@field install fun() Download database and tts dependencies

local uv = vim.loop
local progress_util = require 'Trans.core.progress_util'

local function get_file_size(path)
    if not uv or not uv.fs_stat then
        return 0
    end
    local stat = uv.fs_stat(path)
    return stat and stat.size or 0
end

local function fetch_total_size(uri, fn)
    local headers = fn.systemlist('curl -sI ' .. fn.shellescape(uri))
    for _, line in ipairs(headers) do
        local key, value = line:match('^%s*(.-):%s*(.+)$')
        if key and value and key:lower() == 'content-length' then
            return tonumber(value)
        end
    end
end

local function path_join(dir, name, sep)
    if not dir then return name end
    sep = sep or '/'
    if dir:sub(-1) == sep then
        return dir .. name
    end
    return dir .. sep .. name
end

return function()
    local Trans = require 'Trans'
    local fn = vim.fn
    local progress = require 'Trans.core.progress'

    -- INFO :Check ultimate.db exists
    local dir = Trans.conf.dir
    local offline_conf = Trans.conf.offline or {}
    local join = function(name)
        return path_join(dir, name, Trans.separator)
    end

    local path = join(offline_conf.filename or 'ultimate.db')
    local zip = join('ultimate.zip')

    if fn.isdirectory(dir) == 0 then
        fn.mkdir(dir, 'p')
    end

    if fn.filereadable(path) == 1 then
        vim.notify('Database already exists', vim.log.WARN)
        return
    end

    local continue = fn.filereadable(zip) == 1
    local uri = 'https://github.com/skywind3000/ECDICT-ultimate/releases/download/1.0.0/ecdict-ultimate-sqlite.zip'
    local total_size = fetch_total_size(uri, fn)
    local progress_ui = progress.new {
        message = continue and '继续下载词库...' or '开始下载词库...',
    }

    local function safe_update(raw_percent, message)
        local downloaded = get_file_size(zip)
        local percent = raw_percent
        if percent == nil and total_size and total_size > 0 then
            percent = progress_util.percent(downloaded, total_size)
        end
        local info = {
            percent = percent,
            message = message,
            downloaded = downloaded,
            total = total_size,
        }
        vim.schedule(function()
            progress_ui:update(info)
        end)
    end

    local function finish_progress(success, message)
        local downloaded = get_file_size(zip)
        local info = {
            percent = total_size and total_size > 0 and (success and 100 or 0) or nil,
            message = message,
            downloaded = downloaded,
            total = total_size,
        }
        vim.schedule(function()
            progress_ui:finish(success, info)
        end)
    end

    local function handle(output)
        if output.exit == 0 and fn.filereadable(zip) == 1 then
            safe_update(100, '下载完成，正在解压...')

            if fn.executable 'unzip' == 0 then
                local message = 'unzip not found, Please unzip ' .. zip .. ' manually'
                finish_progress(false, message)
                vim.notify(message, vim.log.ERROR)
                return
            end

            local cmd = string.format('unzip %s -d %s', zip, dir)
            local status = os.execute(cmd)
            os.remove(zip)

            if status == 0 then
                local message = '词库安装成功'
                local version_file = offline_conf.version_file or 'ultimate.version'
                local version_value = offline_conf.version
                if version_value then
                    fn.writefile({ version_value }, join(version_file))
                end
                finish_progress(true, message)
                vim.notify('Download database successfully', vim.log.INFO)
                return
            end
        end

        local debug_message = 'Download database failed:' .. vim.inspect(output)
        finish_progress(false, debug_message)
        vim.notify(debug_message, vim.log.ERROR)
    end

    local message = continue and 'Continue download database' or 'Begin to download database'
    vim.notify(message, vim.log.levels.INFO)

    Trans.curl.get(uri, {
        output = zip,
        callback = handle,
        extra = continue and { '-C', '-' } or nil,
        progress = function(percent)
            safe_update(percent, '下载中...')
        end,
    })

    -- INFO : Install tts dependencies
    if Trans.system == 'win' then
        os.execute 'cd ./tts && npm install'
    end
end
