local M = {}

--- Toggle lf file browser in tmux
-- If an lf pane exists, focus it
-- Otherwise, create a new left pane with lf (30% width)
function M.toggle()
  -- Check if current window has a pane running lf
  -- We look for pane title containing "lf"
  local handle = os.popen("tmux list-panes -F '#P #W' 2>/dev/null")
  local panes = handle:read("*a")
  handle:close()
  
  if string.find(panes, "lf") then
    -- lf pane exists, focus it
    os.execute("tmux select-pane -t :.")
  else
    -- No lf pane, create one on the left (30% width)
    os.execute("tmux split-window -h -p 30 'lf'")
  end
end

return M
