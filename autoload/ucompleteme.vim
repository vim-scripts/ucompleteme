function! ucompleteme#AddWordsFromLineToList(line, base, word_under_cursor)

	let l = []
	let full_word = a:base . a:word_under_cursor

	for w in split(a:line, '\W\+')

		" get just the end of the current word, so if the user typed
		" 'jso' and the word we're currently inspecting is
		" 'json_input', then we want to set the 'word' variable to
		" 'n_input' (just the end of json_input)
		let word = strpart(w, len(a:word_under_cursor), len(w))

		if len(word) > 0 && w =~ '^' . full_word . '.*$'
			call add(l, {'word': word, 'abbr': w})
			let s:all_items[word] = 1
		endif
	endfor

	return l

endfunction

function! ucompleteme#FindAround(base, word_under_cursor)
	let cur = line('.')
	let max = cur - 0
	let endl = line('$')
	if endl - cur > max | let max = endl | endif
	let dist = 0
	let l = []

	while dist < max
		if cur - dist >= 1
			let c = cur - dist
			call extend(l, ucompleteme#AddWordsFromLineToList(getline(c), a:base, a:word_under_cursor))
		endif

		if dist > 0 && endl >= cur + dist
			let c = cur + dist
			call extend(l, ucompleteme#AddWordsFromLineToList(getline(c), a:base, a:word_under_cursor))
		endif

		let dist += 1
	endwhile

	return l
endfunction

function! ucompleteme#GetCurWord()
	let line = getline('.')
	let idx = col('.') - 1
	let start = idx
	while idx > 0
		let idx -= 1
		let c = line[idx]
		if c =~ '\w'
			continue
		else
			let idx += 1
			break
		endif
	endwhile

	return strpart(line, idx, start - idx)
endfunction

function! ucompleteme#CompleteMe(findstart, base)
	if a:findstart == 1
		if len(&omnifunc) > 0
			let s:findstart = function(&omnifunc)(a:findstart, a:base)
			return s:findstart
		else
			let start = col('.') - 1
			let line = getline('.')
			while start >= 0 && line[start - 1] =~ '\W'
				let start -= 1
			endwhile
			let s:findstart = start
			echo 'returning findstart = ' . s:findstart
			return s:findstart
		endif
	else
		" these actually end up affecting the search...
		let old_ignorecase = &ignorecase | set noignorecase
		let old_smartcase = &smartcase | set nosmartcase

		if len(&omnifunc) > 0
			let omni_items = function(&omnifunc)(a:findstart, a:base)
			if len(omni_items) == 0 | let omni_items = [] | endif
		else
			let omni_items = []
		endif

		let s:all_items = {}
		for item in omni_items
			call complete_add(item)

			let new_key = substitute(item['word'], '[(.]$', '', '')
			if len(new_key) > 0
				if type(item) == type("")
					let s:all_items[new_key] = 1
				elseif type(item) == type({})
					let s:all_items[new_key] = 1
				endif
			endif
		endfor

		call complete_check()

		let word_under_cursor = ucompleteme#GetCurWord()

		if len(a:base . word_under_cursor) >= 1
			let s:all_items[a:base . word_under_cursor] = 1
			let l = ucompleteme#FindAround(a:base, word_under_cursor)
		else
			let l = []
		endif

		if old_ignorecase | set ignorecase | endif
		if old_smartcase | set smartcase | endif
		return l
	endif
endfunction

function! ucompleteme#MakeTabWorkWithMenu(direction)
	if pumvisible()
		if a:direction == 'up'
			return "\<C-P>"
		else
			return "\<C-N>"
		endif
	else
		if a:direction == 'down'
			return "\<C-X>\<C-U>"
		else
			return "\<S-TAB>"
		endif
	endif
endfunction

function! ucompleteme#EscClosesPopUpMenu()
	if pumvisible()
		pclose
		resize
		"return "\<C-E>"
		return "\<ESC>"
	else
		return "\<ESC>"
	endif
endfunction

function! ucompleteme#Setup()

	if ! exists('g:ucompleteme_map_tab')
		let g:ucompleteme_map_tab = 1
	endif

    "if the user enters a buffer or reads a buffer then we gotta set up
    "the comment delimiters for that new filetype
	autocmd BufEnter,BufRead * :call ucompleteme#SetupForNewBuffer(&filetype)

    "if the filetype of a buffer changes, force the script to reset the
    "delims for the buffer
	autocmd FileType * :call ucompleteme#SetupForNewBuffer(&filetype)

endfunction

function! ucompleteme#SetupForNewBuffer(f)
	setlocal completefunc=ucompleteme#CompleteMe

	if g:ucompleteme_map_tab
		inoremap <esc> <c-r>=ucompleteme#EscClosesPopUpMenu()<cr>
		inoremap <tab> <c-r>=ucompleteme#MakeTabWorkWithMenu('down')<cr>
		inoremap <s-tab> <c-r>=ucompleteme#MakeTabWorkWithMenu('up')<cr>
	endif
endfunction
