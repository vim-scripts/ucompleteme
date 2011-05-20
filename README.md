Overview
--------

`ucompleteme` is a Vim plugin for insert-mode completion.  It combines the
results of omni-completion with keywords in the current file.

The thing is, omni-complete works well, but insert mode completion works well
too, and I don't want to think about what kind of completion to use, I just
want Vim to complete the word I'm typing when I press `<tab>`.  The nice thing
about `ucompleteme` is it does what you would probably want anyway -- it shows
you omni-completeion results followed by the closest matches to your cursor.


Usage
-----

When you are typing a word and you press the tab key, `ucompleteme` will fill
the pop-up menu with the results of omni-completion.  After that it will search
line-by-line progressively further from your cursor for keywords that match as
well.  This is similar to standard insert-mode completion, except it is
searching both forward and backward.


Installation
------------

Put the "ucompleteme.vim" file in your [Vim Runtimepath][1]'s autoload
direcory:

 - On Linux/Mac OS X: `~/.vim/autoload`

 - On Windows: `$HOME/vimfiles/autoload`

If you're using a Vim package manager like [Tim Pope][3]'s [pathogen][4], then
you should be able to just clone this repository into the "bundles" directory.

Finally, add the following to your [.vimrc][2]:

	call ucompleteme#Setup()


[1]: http://vimdoc.sourceforge.net/htmldoc/options.html#'runtimepath' "Vim Runtimepath"
[2]: http://vimdoc.sourceforge.net/htmldoc/starting.html#.vimrc ".vimrc"
[3]: http://tpo.pe/ "Tim Pope"
[4]: http://www.vim.org/scripts/script.php?script_id=2332 "pathogen"
