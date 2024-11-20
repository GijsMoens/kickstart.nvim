return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'ldelossa/nvim-dap-projects',
    'theHamsta/nvim-dap-virtual-text',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  keys = function(_, keys)
    local dap = require 'dap'
    local dapui = require 'dapui'
    return {
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
      },
      {
        '<leader>dk',
        function()
          dap.down()
        end,
        desc = 'DAP down',
      },
      {
        '<leader>dj',
        function()
          dap.up()
        end,
        desc = 'DAP up',
      },
      {
        '<leader>dl',
        function()
          dapui.close()
          dapui.setup()
          dapui.open()
        end,
        desc = 'DAP reset UI layout',
      },
      unpack(keys),
    }
  end,
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    local widgets = require 'dap.ui.widgets'

    -- Python configuration example
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'inference',
        program = '/home/g.moens/nnUNet/nnunetv2/run/run_training.py',
        args = {
          '203',
          '2d',
          '0',
          '-device',
          'cuda',
          '-tr',
          'DS4Trainer',
          '--npz',
          '--val',
          '--val_with',
          '/data/groups/beets-tan/g.moens/PI-CAI_results/Dataset203_picai_zonal_nocrop/DS4Trainer__nnUNetPlans__2d/fold_0/checkpoint_final.pth',
        },
        console = 'integratedTerminal',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'validate_plain',
        program = '/home/g.moens/nnUNet/nnunetv2/run/run_training.py',
        args = { '203', '2d', '0', '-device', 'cuda', '-tr', 'DS4Trainer', '--npz' },
        console = 'integratedTerminal',
        justMyCode = false,
      },
    }

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      ensure_installed = { 'delve' },
    }

    dap.set_log_level 'DEBUG'
    dapui.setup {
      layouts = {
        {
          elements = { 'scopes', 'watches', 'breakpoints', 'stacks' },
          size = 50,
          position = 'left',
        },
        {
          elements = { 'repl', 'console' },
          size = 15,
          position = 'bottom',
        },
      },
      floating = { border = 'rounded' },
    }

    require('nvim-dap-projects').config_paths = { '/home/g.moens/nnUNet/nnunetv2/tests/nvim-dap.lua' }

    -- Custom REPL formatting
    local function custom_repr(value)
      if type(value) == 'table' and value.__repr__ then
        return value:__repr__()
      else
        return vim.inspect(value)
      end
    end

    dap.repl.commands = {
      custom_print = function(expression)
        local value = assert(loadstring('return ' .. expression))()
        print(custom_repr(value))
      end,
      expand = function(expression)
        local value = assert(loadstring('return ' .. expression))()
        print(vim.inspect(value))
      end,
    }

    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    require('dap-go').setup()
    require('dap-python').setup '/home/g.moens/miniconda3/envs/cuda12_env/bin/python'
  end,
}
