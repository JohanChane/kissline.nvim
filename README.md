# kissline.nvim

## Why kissline

Inspired by [suckless](https://suckless.org/), I thought writing my own `tabline` and `statusline` would be a good choice. The reason is that whenever I install tabline and statusline plugins, I like to configure them the way I want. This takes quite a bit of time. Additionally, I prefer minimalist things, so I decided to write my own tabline and statusline. This way, I can add the features I want and know exactly what’s going on internally.

If I made it highly configurable, I think it would make the code complex. Moreover, everyone’s configurations are different, and since the code isn’t extensive, you can directly modify it.

## Target Audience

- Can program using Lua.
- Those familiar with neovim’s configuration and can read its documentation

## Features

### Statusline

### Tabline

### Bufline

Works similarly to tabline, with features like:

- Select tab: like `<N>gt`, tablast
- Move tab: like `tabmove`
- Close tabs
  - delete other buffers
  - delete left buffers 
  - delete right buffers
- Go to the last tab: like `g<Tab>`
- New buftabs open to the right of the current buftab.
- Delete the current buffer automatically selects the left tab.

*For specifics, refer to the key bindings in `init.lua` or check the source code.*

## Installation

I recommend using it as a local plugin so it can be easily modified. Many plugin managers support installing local plugins.

Steps to install:

1. Clone it or fork-clone it.
2. Use a plugin manager to install. For example, with `lazy.nvim`:

    ```lua
    {
      dir = "~/.config/nvim/lua/kissline.nvim",         -- Replace with your cloned kissline directory
      config = function()
        require("kissline").setup({
          statusline = {
            enable = true,
          },
          tabline = {
            enable = true,
          },
          bufline = {
            enable = false,
            abbr_bdelete = false,    -- cnoreabbrev the `bd/bdel/bdelete` command.
                                     -- For controlling the buffer display after deleting a buffer.
          },
        })
      end
    },
    ```

## Directory Structure Explanation

```
.
├── LICENSE
├── lua
│   └── kissline
│       ├── bufline.lua
│       ├── common.lua              # Common items used by various components
│       ├── init.lua                # Plugin loading tasks, e.g., setup, configuration, key bindings, etc.
│       ├── statusline.lua
│       └── tabline.lua
└── README.md
```

## Examples (forks)

*To provide more reference examples for others, you can add your configuration here.*

### [JohanChane/kissline.nvim](https://github.com/JohanChane/kissline.nvim)

deus theme

![statusline](https://github.com/JohanChane/kissline.nvim/assets/26107760/4a3984da-9d63-486c-bcac-94a8a0f66de3)

![tabline](https://github.com/JohanChane/kissline.nvim/assets/26107760/ca563c2c-397f-4574-b723-6edff0139734)

### [JohanChane/mykissline.nvim](https://github.com/JohanChane/mykissline.nvim)

The `kissline.nvim` I am using.
