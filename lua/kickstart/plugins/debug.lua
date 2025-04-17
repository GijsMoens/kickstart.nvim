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
    -- Problematic: passing a string instead of a table for something expected to be a table.
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
        '<leader>di',
        function()
          local lines = vim.fn.getregion(vim.fn.getpos '.', vim.fn.getpos 'v')
          dap.repl.open()
          dap.repl.execute(table.concat(lines, '\n'))
        end,
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

    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'inference',
        program = '/home/g.moens/nnUNet/nnunetv2/run/run_training.py',
        args = {
          '203',
          '3d_fullres',
          '0',
          '-device',
          'cuda',
          '-tr',
          'DS4Trainer',
          '--npz',
          '-val',
          '--val_with',
          '/projects/SSM_based_csPCa_segmentation/results/Dataset203_picai_zonal_nocrop/DS4Trainer__nnUNetPlans__3d_fullres__2025_03_19_16_53_41/fold_0/checkpoint_latest.pth',
        },
        console = 'integratedTerminal',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'run_ssm_training_2d',
        program = '/home/g.moens/nnUNet/nnunetv2/run/run_training.py',
        args = { '158', '2d', '0', '-device', 'cuda', '-tr', 'DS4Trainer', '--npz' },
        console = 'integratedTerminal',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'run_203_2d',
        program = '/home/g.moens/nnUNet/nnunetv2/run/run_training.py',
        args = { '203', '2d', '0', '-device', 'cuda', '-tr', 'DS4Trainer', '--npz' },
        console = 'integratedTerminal',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'run_ssm_training_2d_dino',
        program = '/home/g.moens/nnUNet/nnunetv2/run/run_training.py',
        args = { '203', '2d', '0', '-device', 'cuda', '-tr', 'DinoTrainer', '--npz' },
        console = 'integratedTerminal',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'run_ssm_training_3d',
        program = '/home/g.moens/nnUNet/nnunetv2/run/run_training.py',
        args = { '203', '3d_fullres', '0', '-device', 'cuda', '-tr', 'DS4Trainer', '--npz' },
        console = 'integratedTerminal',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'run_disco',
        program = '/home/g.moens/attention_guided_segmentation/disco/disco/main.py',
        args = {
          '--csv_file',
          '/home/g.moens/attention_guided_segmentation/disco/disco/data/h3_cbs_lgn_9_normalized_2023.csv',
          '--data_json',
          '/home/g.moens/attention_guided_segmentation/disco/disco/data/data.json',
        },
        console = 'integratedTerminal',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'validate_with',
        program = '/home/g.moens/nnUNet/nnunetv2/run/run_training.py',
        args = {
          '203',
          '3d_fullres',
          '0',
          '-device',
          'cuda',
          '-tr',
          'DS4Trainer',
          '--npz',
          '-val',
          '--val_with',
          '/projects/SSM_based_csPCa_segmentation/results/Dataset203_picai_zonal_nocrop/DS4Trainer__nnUNetPlans__3d_fullres__2025_03_19_16_53_41/fold_0/checkpoint_latest.pth',
        },
        console = 'integratedTerminal',
        justMyCode = false,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'continue_with',
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
          '--c',
          '--continue_with',
          '/projects/SSM_based_csPCa_segmentation/results/Dataset203_picai_zonal_nocrop/DS4Trainer__nnUNetPlans__2d__2025_04_10_16_23_15/fold_0',
        },
        console = 'integratedTerminal',
        justMyCode = false,
      },
    }

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        'delve',
      },
    }

    vim.keymap.set('n', '<leader>drl', function()
      dapui.open()
    end, { desc = 'reset the dapui layout', noremap = true })
    vim.keymap.set('n', '<leader>drr', dap.run_last, { desc = 'reset the dapui debugger' })

    dapui.setup {
      icons = {
        expanded = '▾',
        collapsed = '▸',
        current_frame = '*',
      },
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
      layouts = {
        {
          elements = {
            {
              id = 'breakpoints',
              size = 0.2,
            },
            {
              id = 'repl',
              size = 0.5,
            },
            {
              id = 'console',
              size = 0.3,
            },
          },
          position = 'left',
          size = 150,
        },
      },
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

    -- Define the initial sign with the icon
    vim.fn.sign_define('DapStopped', { text = '⭐️', texthl = '', linehl = 'DapStopped', numhl = '' })

    require('nvim-dap-projects').config_paths = { '~/nnUNet/nnunetv2/tests/nvim-dap.lua' }
    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
      },
    }
    require('dap-python').setup '/home/g.moens/miniconda3/envs/cuda12_env/bin/python'
  end,
}
