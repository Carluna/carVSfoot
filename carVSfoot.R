# ███████╗████████╗ █████╗ ██████╗ ████████╗██████╗ ██╗      █████╗ ███╗   ██╗
# ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██║     ██╔══██╗████╗  ██║
# ███████╗   ██║   ███████║██║  ██║   ██║   ██████╔╝██║     ███████║██╔██╗ ██║
# ╚════██║   ██║   ██╔══██║██║  ██║   ██║   ██╔═══╝ ██║     ██╔══██║██║╚██╗██║
# ███████║   ██║   ██║  ██║██████╔╝   ██║   ██║     ███████╗██║  ██║██║ ╚████║
# ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═════╝    ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝

# 25.07.2024
# Author: R. K.


# Download fonts ----------------------------------------------------------

sysfonts::font_add_google("Roboto Slab")
sysfonts::font_add_google("Playfair Display")
showtext::showtext_auto()

# Load Packages -----------------------------------------------------------

require(sf)
require(osmextract)
require(dplyr)
require(tidyr)
require(ggplot2)
require(cowplot)


# Load data ---------------------------------------------------------------

# Load shape of Freiburg
sh_districts <- read_sf("C:/Users/ruben/Documents/Programmieren/stadtplan/data/stadtteile.shp")|>
  st_transform("WGS84")

sh_freiburg <- sh_districts |> 
  st_union()

# Get osm data of Freiburg
osm_lines = oe_get("Freiburg", stringsAsFactors = FALSE, quiet = TRUE) |> 
  st_intersection(sh_freiburg)

# Extract waterways
waterways <- osm_lines |> 
  select(waterway, name, z_order) |> 
  na.omit()

# Extract motorways
streets <- osm_lines |> 
  select(highway, name, z_order) |> 
  na.omit()

# Elements for cars
ls_roads <- c("primary", "secondary", "tertiary", "trunk", "residential", 
              "primary_link", "secondary_link", "tertiary_link", "trunk_link",
              "tertiary_link", "unclassified")

# Elements for pedestrians and cyclists
ls_foot <- c("pedestrian", "living_street", "footway", "path", "track", "steps",
             "cycleway")

# Plotting ----------------------------------------------------------------

map_cars <- ggplot() +
  geom_sf(data = sh_freiburg,
          aes(geometry = geometry),
          color = "grey70",
          fill = "grey90"
  ) +
  geom_sf(data = waterways, 
          aes(geometry = geometry),
          color = "blue",
          alpha = 0.4
          ) +
  geom_sf(data = streets |> filter(highway %in% ls_roads), 
          aes(geometry = geometry),
          color = "grey20") +
  theme_void() +
  labs(caption = "Data from: \nOpenStreet Map \nStadt Freiburg, www.freiburg.de\n\n R. Kubina\n") +
  theme(plot.caption = element_text(hjust = 0,
                                    family = "roboto", 
                                    color = "grey15"
                                    )
        )

map_foot <- ggplot() +
  geom_sf(data = sh_freiburg,
          aes(geometry = geometry),
          color = "grey70",
          fill = "grey90"
  ) +
  geom_sf(data = waterways, 
          aes(geometry = geometry),
          color = "blue",
          alpha = 0.4
  ) +
  geom_sf(data = streets |> filter(highway %in% ls_foot), 
          aes(geometry = geometry),
          color = "grey10") +
  theme_void() +
  labs(title = "\nComparison of streets for cars and pedestrians/cyclists",
       subtitle = "Who can go where in Freiburg?") +
  theme(plot.title = element_text(hjust = 1,
                                  family = "Playfair Display",
                                  face = "bold",
                                  size = 15, 
                                  color = "grey15"),
        plot.subtitle = element_text(hjust = 1,
                                     family = "Playfair Display", 
                                     color = "grey15")
        )


map_fin <- cowplot::plot_grid(map_cars, map_foot, align = "h") +
  theme(plot.background = element_rect(fill = "orange", colour = "orange"))

# ggsave(plot = map_fin, 
#        filename = "C:/Users/ruben/Documents/Programmieren/stadtplan/data/final_map.png",
#        height = 6,
#        width = 12,
#        units = "cm")
