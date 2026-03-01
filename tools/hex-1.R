# Install hexSticker package if needed
install.packages("hexSticker")

library(hexSticker)
library(showtext)

# Load a Google font for better aesthetics (optional)
font_add_google("Roboto", "roboto")
showtext_auto()

# Create hex sticker
sticker(
  package = "statdown",
  p_size = 8,
  p_color = "#FFFFFF",
  p_family = "roboto",
  s_x = 1,
  s_y = 0.75,
  s_width = 1.3,
  s_height = 1.3,
  h_fill = "#3C8DBC",
  h_color = "#1F4E79",
  filename = "statdown_logo.png"
)
