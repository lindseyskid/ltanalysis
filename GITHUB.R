install.packages("rgl")
install.packages("sf")
install.packages("terra")
install.packages("raster")
install.packages("spatstat")
library(rgl)
library(sf)
library(terra)
library(raster)
library(spatstat)

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
print(lt)

#change raster to Spatraster
?rast
spatrast <- rast("NWCasc_Lindsey/Data Inputs/scratch_folder/CHM_with_Buffer1.tif", subds = 0, lyrs = NULL, drivers = NULL, opts = NULL, win = NULL, snap = "near", vsi = FALSE)
plot(spatrast)
print(spatrast)
ltspatrast <- rast("NWCasc_Lindsey/Data Inputs/Middle_data/lt-gee_growth_map(2).tif", subds = "", lyrs = 2, drivers = NULL, opts = NULL, win = NULL, snap = "near", vsi = FALSE)
plot(ltspatrast)
print(ltspatrast)

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
?spatSample
randompointsground <- spatSample(groundrastmask, 2500, method = "stratified", replace = FALSE, na.rm = FALSE, as.raster = FALSE, as.df = FALSE, as.points = TRUE, values = TRUE, cells = FALSE, xy = TRUE, ext = NULL, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)
randompointsmeadow <- spatSample(meadowrastmask, 2500, method = "stratified", replace = FALSE, na.rm = FALSE, as.raster = FALSE, as.df = FALSE, as.points = TRUE, values = TRUE, cells = FALSE, xy = TRUE, ext = meadowrastmask, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)
randompointsshrub <- spatSample(groundrastmask, 2500, method = "stratified", replace = FALSE, na.rm = FALSE, as.raster = FALSE, as.df = FALSE, as.points = TRUE, values = TRUE, cells = FALSE, xy = TRUE, ext = shrubrastmask, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)
randompointstreed <- spatSample(groundrastmask, 2500, method = "stratified", replace = FALSE, na.rm = FALSE, as.raster = FALSE, as.df = FALSE, as.points = TRUE, values = TRUE, cells = FALSE, xy = TRUE, ext = treedrastmask, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)

#plot points
plot(randompointsground, add = TRUE, cex = 0.1)
print(randompointsground)

plot(randompointsmeadow, add = TRUE, cex = 0.1)
print(randompointsmeadow)

plot(randompointsshrub, add = TRUE, cex = 0.1)
print(randompointsshrub)

plot(randompointstreed, add = TRUE, cex = 0.1)
print(randompointstreed)

#extract values from points
extractvaluesground <- terra::extract(ltspatrast, randompointsground, fun = NULL, method = "simple")
summary(extractvaluesground)

extractvaluesmeadow <- terra::extract(ltspatrast, randompointsmeadow, fun = NULL, method = "simple")
summary(extractvaluesmeadow)


extractvaluesshrub <- terra::extract(ltspatrast, randompointsshrub, fun = NULL, method = "simple")
summary(extractvaluesshrub)

extractvaluestreed <- terra::extract(ltspatrast, randompointstreed, fun = NULL, method = "simple")
summary(extractvaluestreed)
print(extractvaluestreed)

#box plot 
?boxplot

magnitude_ground <- extractvaluesground$mag
magnitude_meadow <- extractvaluesmeadow$mag
magnitude_shrub <- extractvaluesshrub$mag
magnitude_treed <- extractvaluestreed$mag

extracted_magnitude_list <- list(
  ground = magnitude_ground,
  meadow = magnitude_meadow,
  shrub = magnitude_shrub,
  tree = magnitude_treed
)

par(mar = c(5, 6, 4, 2))  
boxplot(extracted_magnitude_list,   
        out = "red", 
        names = c("Ground", "Meadow", "Shrub", "Tree"), 
        ylab = "Magnitude", 
        main = "Landtrendr Magnitude of Change for Land Type", 
        notch = TRUE,
        col = "lightblue", 
        ylim = c(0,1700),
        border = "darkblue", 
        pch = 1700)             



