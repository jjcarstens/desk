# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget, :runtime_tools],
  app: Mix.Project.config()[:app]

config :nerves_firmware_ssh,
  authorized_keys: [File.read!(Path.join(System.user_home!(), ".ssh/mx.pub"))]

config :nerves_init_gadget,
  ifname: "eth0",
  address_method: :dhcp,
  node_host: :mdns_domain,
  ssh_console_port: 22,
  node_name: "controller",
  mdns_domain: System.get_env("MDNS_DOMAIN") || "desk.local"

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :nerves_network, regulatory_domain: "US"

[ssid, psk] = File.read!(".wlan_settings") |> String.split("\n", trim: true)

config :nerves_network, :default,
  wlan0: [
    networks: [
      [
        ssid: ssid,
        psk: psk,
        key_mgmt: :"WPA-PSK"
      ]
    ]
  ],
  eth0: [
    ipv4_address_method: :dhcp
  ]

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn,
  init: [:nerves_runtime],
  app: Mix.Project.config()[:app]

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]
config :logger, handle_otp_reports: true, handle_sasl_reports: true

config :controller, :websocket_url, System.get_env("WEBSOCKET_URL") || "ws://localhost:4000/desk_controller_socket/websocket"
config :controller, :id, System.get_env("CONTROLLER_ID") || "some_controller_id"

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.Project.config[:target]}.exs"
