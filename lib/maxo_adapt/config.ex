defmodule MaxoAdapt.Config do
  def debug do
    Application.get_env(:maxo_adapt, :debug, false)
  end
end
