return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  event = "VeryLazy",
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "filename_first" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-y>"] = actions.select_default,
          },
        },
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            preview_width = 0.5,
            width = 0.8,
            height = 0.8,
            prompt_position = "top",
          },
        },
        sorting_strategy = "ascending",
      },
    })

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local make_entry = require("telescope.make_entry")

    local function search_everything()
      pickers.new({}, {
        prompt_title = "Search Everywhere",

        finder = finders.new_job(function(prompt)
            if prompt == "" then
              return {
                "sh",
                "-c",
                "rg --files | sed 's|^|FILE\t|'",
              }
            end

            local cmd = string.format([[
          (
            rg --files | rg -i '%s' | sed 's|^|FILE\t|'
            rg --vimgrep --smart-case '%s' 2>/dev/null
          )
          ]], prompt, prompt)

            return { "sh", "-c", cmd }
          end,

          function(line)
            if vim.startswith(line, "FILE\t") then
              local file = line:sub(6)
              return make_entry.gen_from_file()(file)
            else
              return make_entry.gen_from_vimgrep()(line)
            end
          end),

        previewer = conf.grep_previewer({}),
        sorter = conf.generic_sorter({}),
      }):find()
    end

    vim.keymap.set("n", "<leader>f", search_everything)
    vim.keymap.set("n", "<tab>", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
  end,
}
