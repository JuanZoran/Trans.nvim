local sqlite = require("sqlite")
local conf = require('Trans').conf

local path = conf.db_path

local db = sqlite.new(conf.db_path)
