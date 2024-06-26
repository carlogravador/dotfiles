return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()

        local function displayRow()

            return "row: %l/%L"
        end

        local function displayColumn()
            return "col: %c"
        end

        -- local function displayFileLines()
        --     return " %L"
        -- end

        local lualine = require("lualine")

        lualine.setup({

            options = {
                theme = 'dracula',
                component_separators = {'|'},
                section_separators = {'|'},
            },

            sections = {
                lualine_b = {},  -- disable git branch, status
                lualine_c = {
                    {'filename', path = 1},
                    {'diagnostics'}
                },
                lualine_x = {
                    {
                        'searchcount',
                        maxcount = 999999,
                        timeout = 500,
                    },
                    {'encoding'},
                    {'fileformat'},
                    {'filetype'},
                },
                -- lualine_y = { displayFileLines },
                lualine_y = {},
                lualine_z = {
                {
                    displayRow
                },
                {
                    displayColumn
                }
                }
            },
            inactive_sections = {
                lualine_c = {
                    {'filename', path = 1}
                },
                lualine_x = {
                    {'encoding'},
                    {'fileformat'},
                    {'filetype'},
                },
                -- lualine_y = { displayFileLines },
                -- lualine_z = {
                --   {
                --       displayRow
                --   },
                --   {
                --       displayColumn
                --   }
                -- }
            },
            extensions = {
                'nvim-tree',
                'quickfix'
            }
        })
    end,
}
