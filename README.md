# kissline.nvim

## Why kissline

Inspired by [suckless](https://suckless.org/), I thought writing my own `tabline/bufline` and `statusline` would be a good choice. The reason is that whenever I install tabline and statusline plugins, I like to configure them the way I want. I need to spend some time reading the documentation. Additionally, I prefer minimalist solutions, so I decided to write my own tabline and statusline. This way, I can add the features I want and know exactly what’s going on internally.

Most people typically modify the theme, change the format or position of some status information, or add some extra information. These are relatively easy to do by directly modifying the corresponding code.

Compared to the above, I think functionality and performance are more important. Below, I summarize the issues I encountered with the plugins I used:
-   In `tabline` mode:
    -   When there are many tabs, even if you select one, it might not display correctly. (Only some minimalist plugins have this issue)
-   In `bufline` mode (most plugins don't implement this functionality):
    -   When you delete the current buffer, it switches to an "unexpected" tab, rather than switching to the tab on the left or right like a browser would.
    -   When you add a new buffer, it appears at the last tab, instead of opening to the right of the current tab like a browser.
    -   There is no functionality to close tabs on the left or right.
    -   There is no functionality to move tabs.
    -   There is no functionality to jump to the previous tab. Although this is not a commonly used feature, it can be quite useful at times.

All of the above features are implemented in `kissline`.

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
- Close tabs: delete left/right/other buffers
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
│   ├── kissline
│   │   ├── bl_sim.lua              # buffe line simulator used to simulate the behavior of the buffer line.
│   │   ├── bufline.lua
│   │   ├── common.lua              # Common items used by various components
│   │   ├── init.lua                # Plugin loading tasks, e.g., setup, configuration, key bindings, etc.
│   │   ├── statusline.lua
│   │   └── tabline.lua
│   └── kissline_test
│       └── bl_sim.lua              # For testing buffer line simulator.
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
