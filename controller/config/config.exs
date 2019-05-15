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
  eth0: [
    ipv4_address_method: :dhcp
  ],
  wlan0: [
    networks: [
      [
        ssid: ssid,
        psk: psk,
        key_mgmt: :"WPA-PSK"
      ]
    ]
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

config :nerves, :firmware, provisioning: :nerves_hub

# For connecting to NervesHub without NervesKey.
# See https://github.com/nerves-hub/nerves_hub#initializing-devices
# for more info on generating device and create certs.
config :controller,
  certfile: File.read!("./nerves-hub/desk-controller-cert.pem"),
  keyfile: File.read!("./nerves-hub/desk-controller-key.pem")

# This is a firmware signing key local to my machine.
# To use NervesHub, you will need to generate your own and
# place it here.
# see https://github.com/nerves-hub/nerves_hub#creating-nerveshub-firmware-signing-keys
config :nerves_hub,
  fwup_public_keys: [:controller_key],
  remote_iex: true # disable if you don't want remote iex in NervesHub

if Mix.target() == :host do
  config :nerves_runtime, :kernel, autoload_modules: false
  config :nerves_runtime, target: "host"

  config :nerves_runtime, Nerves.Runtime.KV.Mock, %{
    "nerves_fw_active" => "a",
    "a.nerves_fw_uuid" => "924d4d6c-c4c5-50c3-aee8-1f6975ecec87",
    "a.nerves_fw_product" => "genie_hub",
    "a.nerves_fw_architecture" => "arm", # arm?
    "a.nerves_fw_version" => "0.2.0",
    "a.nerves_fw_platform" => "arm",
    "a.nerves_fw_misc" => "extra comments",
    "a.nerves_fw_description" => "Genie controller for home automation fun",
    "nerves_fw_devpath" => "/tmp/fwup_bogus_path",
    "nerves_serial_number" => "test"
  }

  config :nerves_runtime, :modules, [
    {Nerves.Runtime.KV, Nerves.Runtime.KV.Mock}
  ]
end
