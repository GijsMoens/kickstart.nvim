-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    'ldelossa/nvim-dap-projects',
    'theHamsta/nvim-dap-virtual-text',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  keys = function(_, keys)
    local dap = require 'dap'
    local dapui = require 'dapui'
    return {
      -- Basic debugging keymaps, feel free to change to your liking!
      { '<leader>dc', dap.continue, desc = 'Debug: Start/Continue' },
      { '<leader>di', dap.step_into, desc = 'Debug: Step Into' },
      { '<leader>do', dap.step_over, desc = 'Debug: Step Over' },
      { '<leader>dt', dap.step_out, desc = 'Debug: Step Out' },
      { '<leader>db', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
      {
        '<leader>de',
        function()
          dap.terminate() -- Terminate the current debugging session
          require('dapui').close() -- Close DAP UI windows if open
          print 'Debugging session terminated'
        end,
        desc = 'Debug: Exit Debugger',
      },
      {
        '<leader>dor',
        function()
          local repl_buf = vim.fn.bufnr 'dap-repl' -- Check if REPL buffer exists
          if repl_buf ~= -1 then
            for _, win in pairs(vim.fn.win_findbuf(repl_buf)) do
              vim.api.nvim_set_current_win(win) -- Focus the REPL window
              return
            end
          else
            require('dap').repl.open() -- Open the REPL if it's not already open
          end
        end,
        desc = 'Debug: Focus on REPL',
      },

      {
        '<leader>dom',
        function()
          -- Get the buffer number of the last edited file
          local last_buf = vim.fn.bufnr '#'

          if last_buf ~= -1 and vim.api.nvim_buf_is_valid(last_buf) then
            -- Check all windows to find the one displaying the last buffer
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              if vim.api.nvim_win_get_buf(win) == last_buf then
                vim.api.nvim_set_current_win(win) -- Focus on the window with the last edited buffer
                return
              end
            end
            print 'Last edited file is not visible in any window'
          else
            print 'No valid last edited file'
          end
        end,
        desc = "Focus on Last Edited File's Window",
      },

      vim.api.nvim_set_keymap('n', '<leader>dos', '<Cmd>lua require"dapui".float_element("scopes")<CR>', { noremap = true, silent = true }),
      -- { '<leader>doe', dapui.., desc = 'Debug: Open expressions' },
      {
        '<leader>B',
        function()
          dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      { '<F7>', dapui.toggle, desc = 'Debug: See last session result.' },
      unpack(keys),
    }
  end,
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }

    vim.keymap.set('n', '<leader>drl', ":lua require('dapui').open({reset_layout = true})<CR>", { desc = 'reset the dapui layout', noremap = true })
    vim.keymap.set('n', '<leader>drr', dap.run_last, { desc = 'reset the dapui debugger' })
    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
    require('dap-python').setup 'python3'
  end,
}
