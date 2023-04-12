defmodule GenTape do
  def run do
    content = File.read!(file_path())
    lines = String.split(content, "\n")
    Enum.map(lines, &convert_line/1) |> Enum.map(& IO.puts(&1))
  end

  def convert_line(line) do
    cond do
      String.starts_with?(line, "#") -> convert_comment(line)
      String.trim_leading(line) == "" -> ""
      true -> convert_code(line)
    end
  end

  def convert_code(line) do
    ~s|Type@.2 '#{line}' Sleep 0.5 Enter Sleep 0.3|
  end

  def convert_comment(line) do
    ~s|Type@.3 '#{line}' Sleep 0.5 Enter Sleep 0.3|
  end

  def file_path do
    Path.join(__DIR__, "example.exs")
  end
end

GenTape.run()
