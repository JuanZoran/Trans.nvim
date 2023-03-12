return function()
    local Trans = require('Trans')
    -- INFO :Check ultimate.db exists
    local dir = Trans.conf.dir
    local path = dir .. '/ultimate.db'

    if vim.fn.filereadable(path) == 1 then
        vim.notify('Database already exists', vim.log.WARN)
        return
    else
        vim.notify('Trying to download database', vim.log.INFO)
    end


    -- INFO :Download ultimate.db
    local uri = 'https://github.com/skywind3000/ECDICT-ultimate/releases/download/1.0.0/ecdict-ultimate-sqlite.zip'
    local loc = dir .. '/ultimate.zip'
    local handle = function(output)
        if output.exit == 0 and vim.fn.filereadable(loc) then
            if vim.fn.executable('unzip') == 0 then
                vim.notify('unzip not found, Please unzip ' .. loc .. 'manually', vim.log.ERROR)
                return
            end

            local cmd = string.format('unzip %s -d %s', path, dir)
            local status = os.execute(cmd)
            os.remove(path)
            if status == 0 then
                vim.notify('Download database successfully', vim.log.INFO)
                return
            end
        end

        local debug_message = 'Download database failed:' .. vim.inspect(output)
        vim.notify(debug_message, vim.log.ERROR)
    end


    Trans.wrapper.curl.get(uri, {
        output = loc,
        callback = handle,
    })

    -- INFO : Install tts dependencies
    if vim.fn.has('linux') == 0 and vim.fn.has('mac') == 0 then
        os.execute('cd ./tts/ && npm install')
    end
end
