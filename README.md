# kissline.nvim

## Why kissline

I prefer simple tablines and statuslines. I have been using [lightline.vim](https://github.com/itchyny/lightline.vim). One day, I thought I could configure a plugin that meets my requirements without using an plugin. So, I created this project. The configuration is simple and straightforward but hardly customizable. Since it is for my personal use, I believe making it customizable would make it complex. If you think you only need minor modifications to make it suit your needs, you can fork this project and modify it accordingly.

## Installation

1. Download [kissline.lua](./lua/kissline.lua) and load the configuration (preferably load it last). e.g. `require("xxx.kissline")`.

Or

1. Fork this project, modify it and then use a plugin manager to install it.

    e.g. Lazy.nvim:

    ```lua
      {
        "<your name>/kissline.nvim",
        config = function()
          require("kissline")
        end,
      },
    ```

## Examples (forks)

*To provide more reference examples for others, you can add your configuration here.*

### [JohanChane/kissline.nvim](https://github.com/JohanChane/kissline.nvim)

deus theme

![statusline](https://github.com/JohanChane/kissline.nvim/assets/26107760/4a3984da-9d63-486c-bcac-94a8a0f66de3)

![tabline](https://github.com/JohanChane/kissline.nvim/assets/26107760/ca563c2c-397f-4574-b723-6edff0139734)

### [JohanChane/mykissline.nvim](https://github.com/JohanChane/mykissline.nvim)

the `kissline.nvim` I am using.
