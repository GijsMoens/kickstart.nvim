local Hydra = require 'hydra'
local dap = require 'dap'
local dapui = require 'dapui'

-- Define your debug mode Hydra
local hint = [[
 Debug Mode:
 _c_: Continue      _o_: Step over   _i_: Step into    _O_: Step out
 _b_: Toggle Breakpoint   _B_: Conditional Breakpoint   _r_: Run to Cursor
 _q_: Quit Debugger
]]

Hydra {
  name = 'Debug Mode',
  hint = hint,
  config = {
    color = 'pink',
    invoke_on_body = true,
    hint = {
      border = 'rounded',
    },
  },
  mode = 'n', -- Normal mode for debugging
  body = '<leader>d', -- Start the Hydra with <leader>d
  heads = {
    { 'c', dap.continue, { desc = 'Continue' } },
    { 'o', dap.step_over, { desc = 'Step Over' } },
    { 'i', dap.step_into, { desc = 'Step Into' } },
    { 'O', dap.step_out, { desc = 'Step Out' } },
    { 'b', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint' } },
    {
      'B',
      function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      { desc = 'Conditional Breakpoint' },
    },
    { 'r', dap.run_to_cursor, { desc = 'Run to Cursor' } },
    {
      'q',
      function()
        dap.terminate()
        dapui.close()
      end,
      { exit = true, desc = 'Quit Debugger' },
    },
    {
      't',
      function()
        dapui.toggle()
      end,
      { desc = 'Toggle DAP UI' },
    },
  },
}
local dap = require 'dap'

dap.adapters.python = {
  type = 'executable',
  command = 'python3', -- Adjust this to your Python executable
  args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}', -- This will launch the current file
    pythonPath = function()
      return 'python3' -- Adjust this to your Python executable
    end,
  },
}
