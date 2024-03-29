{ pkgs }:
let
  angular-ls = (import ../../packages/node-packages {
    inherit pkgs;
    nodejs = pkgs.nodejs_18;
  })."@angular/language-server";
  darkman = pkgs.vimUtils.buildVimPlugin {
    name = "darkman";
    src = pkgs.buildGoModule rec {
      pname = "darkman.nvim";
      version = "0.0.1";
      vendorHash = "sha256-HpyKzvKVN9hVRxxca4sdWRo91H32Ha9gxitr7Qg5MY8=";
      src = pkgs.fetchFromGitHub {
        owner = "4e554c4c";
        repo = "darkman.nvim";
        rev = "150aa63a13837c44abd87ff20d3a806321a17b2d";
        sha256 = "sha256-ssEYdM460I1rufjgh63CEkLi4K+bEWbwku/6gQbytno=";
      };
      postInstall = ''
        cp -r lua $out
      '';
    };
  };
  lualine-so-fancy = pkgs.vimUtils.buildVimPlugin {
    name = "lualine-so-fancy";
    version = "2128450";
    src = pkgs.fetchFromGitHub {
      owner = "meuter";
      repo = "lualine-so-fancy.nvim";
      rev = "21284504fed2776668fdea8743a528774de5d2e1";
      hash = "sha256-JMz3Dv3poGoYQU+iq/jtgyHECZLx+6mLCvqUex/a0SY=";
    };
  };
in {
  enable = true;
  defaultEditor = true;

  options = {
    number = true;
    relativenumber = true;

    tabstop = 2;
    softtabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    smartindent = true;
    signcolumn = "yes";

    undodir = { __raw = "os.getenv('HOME') .. '/.config/nvim/undodir'"; };
    undofile = true;

    scrolloff = 12;

    termguicolors = true;

    hlsearch = false;
    incsearch = true;

    updatetime = 50;

    fillchars.eob = " ";
  };

  keymaps = import ./keymaps.nix;

  globals = {
    minimap_width = 10;
    minimap_auto_start = 1;
    minimap_auto_start_win_enter = 1;
    minimap_close_buftypes = [ "nofile" ];
    minimap_block_filetypes = [ "NvimTree" ];

    mapleader = ";";

    mergetool_layout = "mr";
    mergetool_prefer_revision = "local";

    neovide_transparency = 0.8;
    neovide_padding_top = 10;
    neovide_padding_bottom = 10;
    neovide_padding_left = 10;
    neovide_padding_right = 10;
    neovide_floating_blur_amount_x = 10;
    neovide_floating_blur_amount_y = 10;
    neovide_floating_shadow = false;
    neovide_cursor_vfx_mode = "pixiedust";
  };

  clipboard = {
    register = "unnamedplus";
    providers.wl-copy.enable = true;
  };

  extraConfigVim = ''
    if !exists("g:neovide")
      hi Normal guibg=NONE ctermbg=NONE
    endif
    set noshowmode
  '';

  extraConfigLua = builtins.readFile ./extra-config.lua;

  colorschemes.catppuccin = {
    enable = true;
    terminalColors = true;
    transparentBackground = true;
    background = {
      dark = "frappe";
      light = "latte";
    };
    integrations.native_lsp.underlines = {
      errors = [ "undercurl" ];
      warnings = [ "undercurl" ];
    };
    customHighlights = builtins.readFile ./custom-highlights.lua;
  };

  plugins = {
    lualine = {
      enable = true;
      theme = "catppuccin";
      globalstatus = true;
      sectionSeparators = {
        left = "";
        right = "";
      };
      componentSeparators = {
        left = "┊";
        right = "┊";
      };
      sections = {
        lualine_a = [{
          name = "mode";
          separator = {
            right = "";
            left = "";
          };
          icon = "";
        }];
        lualine_x = [
          { name = "fancy_lsp_servers"; }
          {
            name = "filetype";
            extraConfig = { icon_only = true; };
            padding = {
              left = 1;
              right = 2;
            };
          }
        ];
        lualine_z = [{
          name = "location";
          separator = {
            right = "";
            left = "";
          };
        }];
      };
    };
    auto-save = {
      enable = true;
      triggerEvents = [ "FocusLost" "BufLeave" ];
    };
    indent-blankline = {
      enable = true;
      indent.char = "▏";
      scope.showStart = false;
    };
    illuminate.enable = true;
    nvim-autopairs.enable = true;
    nvim-colorizer.enable = true;
    neo-tree = {
      enable = true;
      filesystem.filteredItems.visible = true;
      eventHandlers = {
        file_opened = ''
          function()
            require('neo-tree').close_all()
          end
        '';
      };
    };
    undotree.enable = true;
    notify = {
      enable = true;
      backgroundColour = "#000000";
    };
    toggleterm = {
      enable = true;
      openMapping = "<leader>t";
      direction = "vertical";
      size = 60;
    };
    luasnip.enable = true;
    ts-autotag.enable = true;
    leap.enable = true;
    harpoon = {
      enable = true;
      enableTelescope = true;
      keymaps = {
        addFile = "hm";
        navNext = "hn";
        navPrev = "hp";
      };
    };

    telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = "git_files";
        "<leader>fa" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>fb" = "buffers";

        "<leader>sr" = "lsp_references";
        "<leader>sd" = "lsp_definitions";
        "<leader>si" = "lsp_implementations";
        "<leader>ss" = "lsp_document_symbols";
        "<leader>sw" = "lsp_workspace_symbols";
        "<leader>st" = "lsp_type_definitions";
        "<leader>sh" = "diagnostics";
      };
    };

    trouble = {
      enable = true;
      settings.use_diagnostic_signs = true;
    };

    treesitter = {
      enable = true;
      indent = true;
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
      nixvimInjections = true;
    };

    conform-nvim = {
      enable = true;
      formattersByFt = {
        lua = [ "stylua" ];
        javascript = [ "prettier" ];
        markdown = [ "prettier" ];
        typescript = [ "prettier" ];
        json = [ "prettier" ];
        yaml = [ "prettier" ];
        html = [ "prettier" ];
        angular = [ "prettier" ];
        css = [ "prettier" ];
        scss = [ "prettier" ];
        less = [ "prettier" ];
        svelte = [ "prettier" ];
        rust = [ "rustfmt" ];
        bash = [ "shfmt" ];
        nix = [ "nixfmt" ];
      };
      formatOnSave = {
        timeoutMs = 500;
        lspFallback = true;
      };
    };

    lint = {
      enable = true;
      lintersByFt = {
        javascript = [ "eslint" ];
        typescript = [ "eslint" ];
        css = [ "stylelint" ];
        scss = [ "stylelint" ];
        less = [ "stylelint" ];
        bash = [ "shellcheck" ];
      };
      autoCmd.event = "TextChanged";
    };

    lsp = {
      enable = true;
      keymaps = { diagnostic = { }; };
      enabledServers = [{
        name = "angularls";
        extraOptions = {
          cmd = [
            "ngserver"
            "--stdio"
            "--tsProbeLocations"
            ""
            "--ngProbeLocations"
            ""
          ];
          on_new_config = {
            __raw = ''
              function(new_config, new_root_dir)
                new_config.cmd = {
                  new_root_dir .. "/node_modules/@angular/language-server/bin/ngserver",
                  "--stdio",
                  "--tsProbeLocations",
                  new_root_dir .. "/node_modules",
                  "--ngProbeLocations",
                  new_root_dir .. "/node_modules",
                }
              end
            '';
          };
          filetypes = [
            "typescript"
            "html"
            "typescriptreact"
            "typescript.tsx"
            "angular"
            "html.angular"
          ];
          on_attach = {
            __raw = ''
              function(client, bufnr)
                if vim.bo[bufnr].filetype == "html" then
                  vim.bo[bufnr].filetype = "angular"
                end
              end
            '';
          };
        };
      }];
      servers = {
        html.enable = true;
        cssls.enable = true;
        svelte.enable = true;
        tsserver.enable = true;

        yamlls.enable = true;
        jsonls.enable = true;
        taplo.enable = true;

        rust-analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        pylsp.enable = true;

        clangd = {
          enable = true;
          cmd = [ "clangd" "--offset-encoding=utf-16" ];
        };

        nixd.enable = true;
        lua-ls.enable = true;
        bashls.enable = true;
      };
    };

    lspkind = {
      enable = true;
      mode = "symbol_text";
      cmp = {
        after = ''
          function(entry, vim_item, kind)
            if entry.source.name == "npm" then
              kind.kind = ""
              kind.kind_hl_group = "CmpItemKindNpm"
            end
            kind.kind = kind.kind .. " "
            return kind
          end
        '';
      };
      symbolMap = { Copilot = ""; };
    };
    cmp = {
      enable = true;
      settings = {
        mapping = {
          "<C-n>" =
            "cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Select})";
          "<C-p>" =
            "cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Select})";
          "<C-Space>" = "cmp.mapping.confirm({select = true})";
          "<C-Enter>" = "cmp.mapping.complete()";
        };
        sources = [
          { name = "copilot"; }
          { name = "path"; }
          { name = "luasnip"; }
          {
            name = "npm";
            keywordLength = 4;
            priority = 10;
          }
          { name = "nvim_lsp"; }
          { name = "nvim_lsp_signature_help"; }
          { name = "nvim_lsp_document_symbol"; }
        ];
        formatting.fields = [ "abbr" "kind" ];
        snippet.expand =
          "function(args) require('luasnip').lsp_expand(args.body) end";
        window = {
          completion.border = "rounded";
          documentation.border = "rounded";
        };
        experimental.ghost_text = true;
      };
    };

    which-key = { enable = true; };

    copilot-lua = {
      panel.enabled = false;
      suggestion.enabled = false;
    };

    openscad = {
      enable = true;
      fuzzyFinder = "fzf";
    };

    nix.enable = true;
  };

  extraPackages = [
    angular-ls
    pkgs.nodePackages.typescript-language-server
    pkgs.nodePackages.stylelint
    pkgs.nodePackages.prettier
    pkgs.jq
    pkgs.html-tidy
    pkgs.nixfmt
    pkgs.stylua
    pkgs.shfmt
    pkgs.fzf
  ];
  extraPlugins = with pkgs.vimPlugins; [
    vim-mergetool
    lualine-so-fancy
    darkman
    rest-nvim
    plenary-nvim
    actions-preview-nvim
  ];
}
