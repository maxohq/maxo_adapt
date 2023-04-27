defmodule MaxoAdapt.Config do
  def debug do
    Application.get_env(:maxo_adapt, :debug, false)
  end

  def default_mode do
    Application.get_env(:maxo_adapt, :default_mode, :compile)
  end
end
