install.packages("rgl")
install.packages("sf")
install.packages("terra")
install.packages("raster")
library(rgl)
library(sf)
library(terra)
library(raster)

#import data
lt <- brick("NWCasc_Lindsey/Data Inputs/Middle_data/lt-gee_growth_map(2).tif")
chm <- raster("NWCasc_Lindsey/Data Inputs/scratch_folder/CHM_with_Buffer1.tif")
meadows <- st_read("Wetland_MeadowID/input_data/MORA polygons/MORA_meadows.shp")

#change projection
epsg_code <- 4269
crs(chm) <- CRS(paste0("+init=EPSG:", epsg_code))
crs(lt) <- CRS(paste0("+init=EPSG:", epsg_code))
st_crs(meadows) <- 4269
projection(chm)
projection(lt)
projection(meadows)

#plot 
plot(chm, main = "Canopy Height Model")
plot(meadows, add = TRUE)
plot(lt[[2]], main = "Magnitude")

#change raster to Spatraster
?crs
spatrast <- rast("NWCasc_Lindsey/Data Inputs/scratch_folder/CHM_with_Buffer1.tif", subds = 0, lyrs = NULL, drivers = NULL, opts = NULL, win = NULL, snap = "near", vsi = FALSE)
plot(spatrast)
?`plot,SpatRaster,SpatRaster-method`
#mask for classes
groundrastmask <- spatrast == 0
plot(groundrastmask, main = "ground")
meadowrastmask <- spatrast == 1
plot(meadowrastmask, main = "meadow")
shrubrastmask <- spatrast == 2
plot(shrubrastmask, main = "shrub")
treedrastmask <- spatrast == 3
plot(treedrastmask, main = "treed")

#random points
randompointsground <- spatSample(groundrastmask, 2500, method = "random", replace = FALSE, na.rm = FALSE, as.raster = FALSE, as.df = TRUE, as.points = TRUE, values = TRUE, cells = TRUE, xy = TRUE, ext = NULL, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)
randompointsmeadow <- spatSample(meadowrastmask, 2500, method = "random", replace = FALSE, na.rm = FALSE, as.raster = FALSE, as.df = TRUE, as.points = TRUE, values = TRUE, cells = TRUE, xy = TRUE, ext = NULL, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)
randompointsshrub <- spatSample(groundrastmask, 2500, method = "random", replace = FALSE, na.rm = FALSE, as.raster = FALSE, as.df = TRUE, as.points = TRUE, values = TRUE, cells = TRUE, xy = TRUE, ext = NULL, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)
randompointstreed <- spatSample(groundrastmask, 2500, method = "random", replace = FALSE, na.rm = FALSE, as.raster = FALSE, as.df = TRUE, as.points = TRUE, values = TRUE, cells = TRUE, xy = TRUE, ext = NULL, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)