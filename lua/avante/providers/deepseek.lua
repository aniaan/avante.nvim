local Utils = require("avante.utils")
local Config = require("avante.config")
local P = require("avante.providers")
local O = require("avante.providers").openai

---@class AvanteProviderFunctor
local M = {}

M.API_KEY = "DEEPSEEK_API_KEY"

M.has = function()
  return os.getenv(M.API_KEY) and true or false
end

M.parse_message = O.parse_message
M.parse_response = O.parse_response

M.parse_curl_args = function(provider, code_opts)
  local base, body_opts = P.parse_config(provider)

  local headers = {
    ["Content-Type"] = "application/json",
  }
  if not P.env.is_local("deepseek") then
    headers["Authorization"] = "Bearer " .. os.getenv(M.API_KEY)
  end

  return {
    url = Utils.trim(base.endpoint, { suffix = "/" }) .. "/chat/completions",
    proxy = base.proxy,
    insecure = base.allow_insecure,
    headers = headers,
    body = vim.tbl_deep_extend("force", {
      model = base.model,
      messages = M.parse_message(code_opts),
      stream = true,
    }, body_opts),
  }
end

return M
