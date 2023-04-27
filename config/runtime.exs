import Config

config :maxo_adapt, debug: false

if config_env() == :test do
  config :maxo_adapt, default_mode: :get_dict
end
