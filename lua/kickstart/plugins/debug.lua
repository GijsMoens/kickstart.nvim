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
      -- Function keys for main DAP actions
      { '<F3>', dapui.toggle, desc = 'DAP toggle UI' },
      { '<F4>', dap.pause, desc = 'DAP pause (thread)' },
      { '<F5>', dap.continue, desc = 'DAP launch or continue' },
      { '<F6>', dap.step_into, desc = 'DAP step into' },
      { '<F7>', dap.step_over, desc = 'DAP step over' },
      { '<F8>', dap.step_out, desc = 'DAP step out' },
      { '<F9>', dap.step_back, desc = 'DAP step back' },
      {
        '<F10>',
        function()
          dap.run_last()
        end,
        desc = 'DAP run last',
      },
      { '<F12>', dap.terminate, desc = 'DAP terminate' },

      -- Leader-based mappings for extended DAP actions
      {
        '<leader>dd',
        function()
          dap.disconnect { terminateDebuggee = false }
        end,
        desc = 'DAP disconnect',
      },
      { '<leader>de', vim.diagnostic.open_float, desc = 'Debug: open float' },
      {
        '<leader>dt',
        function()
          dap.disconnect { terminateDebuggee = true }
        end,
        desc = 'DAP disconnect and terminate',
      },
      { '<leader>db', dap.toggle_breakpoint, desc = 'DAP toggle breakpoint' },
      {
        '<leader>dB',
        function()
          dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'DAP set breakpoint with condition',
      },
      {
        '<leader>dp',
        function()
          dap.set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
        end,
        desc = 'DAP set breakpoint with log point message',
      },
      {
        '<leader>dr',
        function()
          dap.repl.toggle()
        end,
        desc = 'DAP toggle debugger REPL',
      }, -- Optional if not using dap-ui

      {
        '<leader>dk',
        function()
          dap.down()
        end,
        { noremap = true, silent = true, desc = 'DAP down' },
      },
      {
        '<leader>dj',
        function()
          dap.up()
        end,
        { noremap = true, silent = true, desc = 'DAP up' },
      },
      -- Additional mappings (optional)
      unpack(keys),
    }
  end,
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = { 'delve' },
    }

    dap.set_log_level 'DEBUG'
    dap.defaults.php.exception_breakpoints = { 'Notice', 'Warning', 'Error', 'Exception' }
    dapui.setup {
      icons = {
        expanded = '▾',
        collapsed = '▸',
        current_frame = '⚪', -- Changed for better visibility
      },
      controls = {
        enabled = true, -- Show controls by default for easy stepping
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = '🔙', -- Updated for clarity
          run_last = '🔄', -- Clear icon for rerun
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.4 }, -- Larger size for easy viewing of model parameters, gradients
            { id = 'watches', size = 0.2 },
            { id = 'breakpoints', size = 0.2 },
            { id = 'stacks', size = 0.2 },
          },
          size = 50, -- Adjusted for a good balance
          position = 'left',
        },
        {
          elements = {
            'repl', -- Moved REPL to top for quick access to variable states
            'console',
          },
          size = 15, -- Larger console for debugging printouts
          position = 'bottom',
        },
      },
      floating = {
        border = 'rounded', -- Rounded borders for better aesthetics
      },
      render = {
        max_type_length = nil, -- Remove any length limit to view full data structures
      },
    }

    local status, err = pcall(function()
      dofile(vim.fn.expand '~/nnUNet/nnunetv2/tests/nvim-dap.lua')
    end)

    if not status then
      print('Error loading nvim-dap.lua: ', err)
    end

    require('nvim-dap-projects').config_paths = { '/home/g.moens/nnUNet/nnunetv2/tests/nvim-dap.lua' }

    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end
    -- Lock 'q' and fix pane sizes
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'dapui_scopes', 'dapui_breakpoints', 'dapui_stacks', 'dapui_watches', 'dapui_repl', 'dapui_console' },
      callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', 'q', '', { noremap = true, silent = true }) -- Disable `q` key
        vim.cmd 'setlocal winfixwidth'
        vim.cmd 'setlocal winfixheight'
      end,
    })

    -- Golang specific config
    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
      },
    }

    require('dap-python').setup '/home/g.moens/miniconda3/envs/cuda12_env/bin/python'
  end,
}
