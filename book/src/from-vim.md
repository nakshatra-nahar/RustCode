# Migrating from Vim

rustcode's editing model is strongly inspired from Vim and Kakoune, and a notable
difference from Vim (and the most striking similarity to Kakoune) is that rustcode
follows the `selection → action` model. This means that whatever you are
going to act on (a word, a paragraph, a line, etc.) is selected first and the
action itself (delete, change, yank, etc.) comes second. A cursor is simply a
single width selection.

See also Kakoune's [Migrating from Vim](https://github.com/mawww/kakoune/wiki/Migrating-from-Vim) and rustcode's [Migrating from Vim](https://github.com/rustcode-editor/rustcode/wiki/Migrating-from-Vim).

> TODO: Mention textobjects, surround, registers
