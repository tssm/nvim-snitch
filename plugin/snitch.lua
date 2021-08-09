local _2afile_2a = "plugin/snitch.fnl"
local call = vim.fn
local opt = vim.opt
local w = vim.w
local function highlight_lines_excess()
  if (w.lines_excess_match_id ~= nil) then
    local function _1_()
      return call.matchdelete(w.lines_excess_match_id)
    end
    pcall(_1_)
  end
  local buftype = (opt.buftype):get()
  if ((buftype == "") or (buftype == "acwrite")) then
    local textwidth = (opt.textwidth):get()
    if (textwidth > 0) then
      local regex = string.format("\\%%>%iv.\\+", textwidth)
      w.lines_excess_match_id = call.matchadd("ColorColumn", regex, -1)
      return nil
    end
  end
end
local trailing_whitespace_regex = string.format("[%s]\\+\\%%#\\@<!$", call.join({"\\u0009", "\\u0020", "\\u00a0", "\\u1680", "\\u2000", "\\u2001", "\\u2002", "\\u2003", "\\u2004", "\\u2005", "\\u2006", "\\u2007", "\\u2008", "\\u2009", "\\u200a", "\\u202f", "\\u205f", "\\u3000", "\\u180e", "\\u200b", "\\u200c", "\\u200d", "\\u2060", "\\ufeff"}, ""))
local function highlight_trailing_whitespace()
  if (w.trailing_whitespace_match_id ~= nil) then
    local function _1_()
      return call.matchdelete(w.trailing_whitespace_match_id)
    end
    pcall(_1_)
  end
  local buftype = (opt.buftype):get()
  if ((buftype == "") or (buftype == "acwrite")) then
    w.trailing_whitespace_match_id = call.matchadd("ColorColumn", trailing_whitespace_regex)
    return nil
  end
end
local spaces_indentation = "^\\ \\ *"
local tabs_indentation = "^\\t\\t*"
local function highlight_wrong_indentation()
  if (w.wrong_indentation_match_id ~= nil) then
    local function _1_()
      return call.matchdelete(w.wrong_indentation_match_id)
    end
    pcall(_1_)
  end
  local buftype = (opt.buftype):get()
  if ((buftype == "") or (buftype == "acwrite")) then
    local wrong_indentation_regex
    if (opt.expandtab):get() then
      wrong_indentation_regex = tabs_indentation
    else
      if (((opt.softtabstop):get() == 0) or ((opt.softtabstop):get() == (opt.tabstop):get())) then
        wrong_indentation_regex = (spaces_indentation .. "\\|" .. tabs_indentation .. "\\zs\\ \\+")
      else
        wrong_indentation_regex = spaces_indentation
      end
    end
    w.wrong_indentation_match_id = call.matchadd("ColorColumn", wrong_indentation_regex)
    return nil
  end
end
Snitch = {}
Snitch.highlight_lines_excess = highlight_lines_excess
Snitch.highlight_trailing_whitespace = highlight_trailing_whitespace
Snitch.highlight_wrong_indentation = highlight_wrong_indentation
local cmd = vim.api.nvim_command
cmd("augroup SnitchSetup")
cmd("autocmd!")
cmd("autocmd BufEnter,BufRead * lua Snitch.highlight_lines_excess() Snitch.highlight_trailing_whitespace() Snitch.highlight_wrong_indentation()")
cmd("autocmd OptionSet * silent! lua Snitch.highlight_lines_excess() Snitch.highlight_wrong_indentation()")
return cmd("augroup END")