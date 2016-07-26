# Defines the robot movement logic
defmodule Robots do

  def tick(buttons, orange, blue) do
    tick(buttons, orange, blue, 0)
  end

  defp tick([], _orange, _blue, seconds) do
    seconds
  end

  defp tick([{"O", button_num}|buttons_tail], {button_num, [button_num|orange_tail]}, blue, seconds) do
    tick(buttons_tail, {button_num, orange_tail}, move(blue), seconds+1)
  end

  defp tick([{"B", button_num}|buttons_tail], orange, {button_num, [button_num|blue_tail]}, seconds) do
    tick(buttons_tail, move(orange), {button_num, blue_tail}, seconds+1)
  end

  defp tick(buttons, orange, blue, seconds) do
    tick(buttons, move(orange), move(blue), seconds+1)
  end

  defp move({cur, []}) do
    {cur, []}
  end

  defp move({cur, [cur|t]}) do
    {cur, [cur|t]}
  end

  defp move({cur, [h|t]}) when cur < h do
    {cur+1, [h|t]}
  end

  defp move({cur, [h|t]}) when cur > h do
    {cur-1, [h|t]}
  end

end

# Parses the input file and formats the output file
defmodule RobotsIO do

  # Usage:
  # RobotsIO.process("A-small-practice.in", "A-small-practice.out")
  def process(in_file_name, out_file_name) do
    input_file = File.open!(in_file_name, [:read, :utf8])
    IO.read(input_file, :line) # discard first line

    results = process_file(input_file, [])  # for each line, create a "case" as a list of instructions like [{"0", 1}, {"B", 4}...]
      |> Enum.map(&run_case &1)             # run each case through Robots module
      |> Enum.reverse                       # reverse because the first cases are at the tail of the list
      |> Stream.with_index(1)               # use Stream to index the results (although at this point they are backward, like [{220, 1}, {194, 2}...])
      |> Enum.map(fn { seconds, idx } -> [idx, seconds] end) # flip the results and format as lists like [[1, 220], [2, 194]...]

    # Write out results in the specified format
    {:ok, output_file} = File.open(out_file_name, [:write])
    Enum.each(results, fn [idx, seconds] -> IO.binwrite(output_file, "Case ##{idx}: #{seconds}\n") end)
    File.close(output_file)
  end

  def process_file(input_file, cases) do
    line = IO.read(input_file, :line)
    if (line != :eof) do
      process_file(input_file, [process_line(String.strip(line)) | cases])
    else
      cases
    end
  end

  def process_line(line) do
    String.split(line)  # split line on spaces (the default for split)
    |> Enum.drop(1)     # drop the first number which describes the total # of buttons that need to be pressed
    |> Enum.chunk(2)    # break the list into pairs of 2 elements
    |> Enum.map(fn [color, button] -> { color, String.to_integer(button)} end) # convert the inner lists to tuples and convert the button to integer
  end

  def run_case(a_case) do
    orange_buttons = filter_robot_buttons("O", a_case)
    blue_buttons   = filter_robot_buttons("B", a_case)
    Robots.tick(a_case, { 1, orange_buttons }, { 1, blue_buttons })
  end

  # For the specified color ("O" or "B"), return a list of buttons the robot
  # will need to press.
  def filter_robot_buttons(robot_color, all_buttons) do
    Enum.filter_map(all_buttons, fn { color, _button } -> color == robot_color end, fn { _color, button } -> button end)
  end
end

