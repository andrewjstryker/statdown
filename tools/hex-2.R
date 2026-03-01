library(ggplot2)
library(grid)

# Create a simple analysis plot
p <- ggplot(mtcars, aes(wt, mpg)) +
  geom_point(color = "blue", size = 3) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  theme_minimal() +
  ggtitle("Analysis") +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

# Create a text grob for the writing element (this could be replaced with a custom image/grob)
writing_grob <- textGrob("Writing", gp = gpar(fontsize = 18, fontface = "italic", col = "darkgreen"))

# Overlay the writing grob onto the plot; adjust coordinates as needed
p_with_writing <- p +
  annotation_custom(writing_grob, xmin = 4, xmax = 5, ymin = 15, ymax = 20)

# Display the combined subplot
print(p_with_writing)
