local call = vim.fn
local opt = vim.opt
local w = vim.w
local function execute_if_writable_buffer(procedure)
  local buftype = opt.buftype:get()
  if ((buftype == "") or (buftype == "acwrite")) then
    return procedure()
  else
    return nil
  end
end
local function highlight_lines_excess()
  if not vim.b.Snitch_disable_lines_excess then
    if (w.lines_excess_match_id ~= nil) then
      local function _2_()
        return call.matchdelete(w.lines_excess_match_id)
      end
      pcall(_2_)
    else
    end
    local function _4_()
      local textwidth = opt.textwidth:get()
      if (textwidth > 0) then
        local regex = string.format("\\%%>%iv.\\+", textwidth)
        w.lines_excess_match_id = call.matchadd("ColorColumn", regex, -1)
        return nil
      else
        return nil
      end
    end
    return execute_if_writable_buffer(_4_)
  else
    return nil
  end
end
local trailing_whitespace_regex = string.format("[%s]\\+\\%%#\\@<!$", call.join({"\\u0009", "\\u0020", "\\u00a0", "\\u1680", "\\u2000", "\\u2001", "\\u2002", "\\u2003", "\\u2004", "\\u2005", "\\u2006", "\\u2007", "\\u2008", "\\u2009", "\\u200a", "\\u202f", "\\u205f", "\\u3000", "\\u180e", "\\u200b", "\\u200c", "\\u200d", "\\u2060", "\\ufeff"}, ""))
local function highlight_trailing_whitespace()
  if not vim.b.Snitch_disable_trailing_whitespace then
    if (w.trailing_whitespace_match_id ~= nil) then
      local function _7_()
        return call.matchdelete(w.trailing_whitespace_match_id)
      end
      pcall(_7_)
    else
    end
    local function _9_()
      w.trailing_whitespace_match_id = call.matchadd("ColorColumn", trailing_whitespace_regex)
      return nil
    end
    return execute_if_writable_buffer(_9_)
  else
    return nil
  end
end
local spaces_indentation = "^\\ \\ *"
local tabs_indentation = "^\\t\\t*"
local function highlight_wrong_indentation()
  if not vim.b.Snitch_disable_wrong_indentation then
    if (w.wrong_indentation_match_id ~= nil) then
      local function _11_()
        return call.matchdelete(w.wrong_indentation_match_id)
      end
      pcall(_11_)
    else
    end
    local function _13_()
      local wrong_indentation_regex
      if opt.expandtab:get() then
        wrong_indentation_regex = tabs_indentation
      else
        if ((opt.softtabstop:get() == 0) or (opt.softtabstop:get() == opt.tabstop:get())) then
          wrong_indentation_regex = (spaces_indentation .. "\\|" .. tabs_indentation .. "\\zs\\ \\+")
        else
          wrong_indentation_regex = spaces_indentation
        end
      end
      w.wrong_indentation_match_id = call.matchadd("ColorColumn", wrong_indentation_regex)
      return nil
    end
    return execute_if_writable_buffer(_13_)
  else
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
cmd("autocmd BufEnter,BufRead,TermOpen * lua Snitch.highlight_lines_excess() Snitch.highlight_trailing_whitespace() Snitch.highlight_wrong_indentation()")
cmd("autocmd OptionSet * silent! lua Snitch.highlight_lines_excess() Snitch.highlight_wrong_indentation()")
return cmd("augroup END")
