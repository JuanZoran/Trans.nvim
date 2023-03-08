local function read_json()
  local path = vim.fn.expand("$HOME/.config/Trans.json")
  local file = io.open(path, "r")
  if file then
    local content = file:read("*a")
    file:close()
    local data = vim.json.decode(content)
    print(data.api_key, data.api_id)
  else
    print("File not found: " .. path)
  end
end
