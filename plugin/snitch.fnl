(local call vim.fn)
(local opt vim.opt)
(local w vim.w)

(fn highlight-lines-excess []
	(when (not= w.lines_excess_match_id nil)
		(pcall #(call.matchdelete w.lines_excess_match_id)))
	(local buftype (opt.buftype:get))
	(when (or (= buftype "") (= buftype :acwrite))
		(local textwidth (opt.textwidth:get))
		(when (> textwidth 0)
			(local regex (string.format "\\%%>%iv.\\+" textwidth))
			(set w.lines_excess_match_id (call.matchadd :ColorColumn regex -1)))))

(local trailing-whitespace-regex (string.format
	"[%s]\\+\\%%#\\@<!$"
	(call.join [
		; White_Space=yes
		:\u0009 ; tab
		:\u0020 ; space
		:\u00a0 ; no-break space
		:\u1680 ; ogham space mark
		:\u2000 ; en quad
		:\u2001 ; em quad
		:\u2002 ; en space
		:\u2003 ; em space
		:\u2004 ; three-per-em space
		:\u2005 ; four-per-em space
		:\u2006 ; six-per-em space
		:\u2007 ; figure space
		:\u2008 ; punctuation space
		:\u2009 ; thin space
		:\u200a ; hair space
		:\u202f ; narrow no-break space
		:\u205f ; medium mathematical space
		:\u3000 ; ideographic space
		; White_Space=no
		:\u180e ; mongolian vowel separator
		:\u200b ; zero width space
		:\u200c ; zero width non-joiner
		:\u200d ; zero width joiner
		:\u2060 ; word joiner
		:\ufeff] ""))) ; zero width non-breaking space

(fn highlight-trailing-whitespace []
	(when (not= w.trailing_whitespace_match_id nil)
		(pcall #(call.matchdelete w.trailing_whitespace_match_id)))
	(local buftype (opt.buftype:get))
	(when (or (= buftype "") (= buftype :acwrite))
		(set w.trailing_whitespace_match_id
			(call.matchadd :ColorColumn trailing-whitespace-regex))))

(local spaces-indentation "^\\ \\ *")
(local tabs-indentation "^\\t\\t*")
(fn highlight-wrong-indentation []
	(when (not= w.wrong_indentation_match_id nil)
		(pcall #(call.matchdelete w.wrong_indentation_match_id)))
	(local buftype (opt.buftype:get))
	(when (or (= buftype "") (= buftype :acwrite))
		(local wrong-indentation-regex
			(if (opt.expandtab:get) tabs-indentation
				(if (or (= (opt.softtabstop:get) 0) (= (opt.softtabstop:get) (opt.tabstop:get)))
					(.. spaces-indentation "\\|" tabs-indentation "\\zs\\ \\+")
					spaces-indentation)))
		(set w.wrong_indentation_match_id
			(call.matchadd :ColorColumn wrong-indentation-regex))))

(global Snitch {})
(set Snitch.highlight_lines_excess highlight-lines-excess)
(set Snitch.highlight_trailing_whitespace highlight-trailing-whitespace)
(set Snitch.highlight_wrong_indentation highlight-wrong-indentation)

(local cmd vim.api.nvim_command)
(cmd "augroup SnitchSetup")
(cmd "autocmd!")
(cmd "autocmd BufEnter,BufRead * lua Snitch.highlight_lines_excess() Snitch.highlight_trailing_whitespace() Snitch.highlight_wrong_indentation()")
; OptionSet trigger a sandbox error when a modeline is used so silent! is neccessary here ☹️
(cmd "autocmd OptionSet * silent! lua Snitch.highlight_lines_excess() Snitch.highlight_wrong_indentation()")
(cmd "augroup END")
