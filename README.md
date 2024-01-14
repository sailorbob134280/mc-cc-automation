# CC Automation Shenanigans

This is a dumping ground for automation things.

## Installation

Installing this repo inside a computer is best done using [gitget](https://www.computercraft.info/forums2/index.php?/topic/17387-gitget-version-2-release/). Simply run the following to clone the repo:

```
pastebin get W5ZkVYSi gitget
gitget sailorbob134280 mc-cc-automation <branch> apps
```

Note that the `api/` directory will be empty, as it is not required to function.

## Development - Getting Started

This repo uses submodules. Clone the repo with the `--recurse-submodules` flag. Note that the `yue` addon in `LLS-Addons` may fail. Idk what it is or why, but CC-Tweaks gets added, so that should be fine.

### Code Completion

This is the entire reason we're doing this. Install a Lua language server in your editor.

#### NeoVim

Adapted from [here](https://tomodachi94.github.io/blog/computercraft-neovim/). With Mason installed, run `:MasonInstall lua-language-server` or add `lua-language-server` to your plugins.

#### VS Code

You're on your own bub. There's prob an extension, idk.
