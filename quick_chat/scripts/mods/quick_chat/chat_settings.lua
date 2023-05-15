--[[
    You can add your custom chat messages by editing this file.
    Each setting must follow the template below.

    {
        id = "<id>",
        title = "<title>",
        message = "<message>"
    },

    id      -- Unique string that does not duplicate others. Use "_" (underscore) instead of " " (space) .
    title   -- Text that appears on the option menu.
    message -- Text that you want to send.

    You can use "[name]" as a place holder.
    It will be replaced by the character name of the player who triggered the event.
]]

-- The following settings are just examples. Feel free to remove or edit them.

return {
    {
        id = "alert_daemonhost",
        title = "Daemonhost",
        message = "Stay alert! A Daemonhost"
    },
    {
        id = "alert_need_help",
        title = "Need Help",
        message = "I need help!"
    },
    {
        id = "alert_stay_together",
        title = "Stay Together",
        message = "Close up! Stay together!"
    },
    {
        id = "greeting_good_game",
        title = "Good Game",
        message = "gg"
    },
    {
        id = "greeting_player_joined",
        title = "Greeting",
        message = "Hi [name]"
    },
    {
        id = "response_yes",
        title = "Yes",
        message = "Yes",
    },
    {
        id = "response_no",
        title = "No",
        message = "No"
    },
    {
        id = "response_sorry",
        title = "Sorry",
        message = "Sorry"
    },
}