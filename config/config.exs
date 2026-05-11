import Config

# :message_content é necessário para ler o texto (!ping, !cep, etc.).
# Ativa também "MESSAGE CONTENT INTENT" no Developer Portal → Bot.
config :nostrum,
  token: System.get_env("DISCORD_BOT_TOKEN"),
  gateway_intents: [
    :guilds,
    :guild_messages,
    :message_content,
    :direct_messages
  ]

config :meu_bot,
  store_path: Path.expand("../priv/reminders.json", __DIR__)
