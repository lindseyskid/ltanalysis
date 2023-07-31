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

#Hello Lindsey!
#howdy!

#import data
spatrast <- rast("NWCasc_Lindsey/Data Inputs/scratch_folder/CHM_with_Buffer1.tif", subds = 0, lyrs = NULL, drivers = NULL, opts = NULL, win = NULL, snap = "near", vsi = FALSE)
ltspatrast <- rast("NWCasc_Lindsey/Data Inputs/Middle_data/lt-gee_changemap.tif", lyrs = "mag")
DEM <- rast("Wetland_MeadowID/intermediate_data/RF_Model_Input/DEM.tif")
NDVI <- rast("NWCasc_Lindsey/Data Inputs/scratch_folder/NDVIground7.tif")

#change projection
epsg_code <- 4269
ltspatrast <- project(ltspatrast, "epsg:26910")
spatrast <- project(spatrast, "epsg:26910")
DEM <- project(DEM, "epsg:26910")
NDVI <- project(NDVI, "epsg:26910")

crs(ltspatrast)
crs(spatrast)
crs(DEM)
crs(NDVI)

#mask for classes
groundrastmask <- as.numeric(NDVI == 1)
groundrastmask[groundrastmask != 1] <- NA
plot(groundrastmask, main = "ground")

meadowrastmask <- as.numeric(spatrast == 1)
meadowrastmask[meadowrastmask != 1] <- NA
plot(meadowrastmask, main = "meadow")

shrubrastmask <- as.numeric(spatrast == 2)
shrubrastmask[shrubrastmask != 1] <- NA
plot(shrubrastmask, main = "shrub")

treedrastmask <- as.numeric(spatrast == 3)
treedrastmask[treedrastmask != 1] <- NA
plot(treedrastmask, main = "treed")

#random points
?spatSample
randompointsground <- spatSample(groundrastmask, 2500, method = "stratified", replace = FALSE, na.rm = TRUE, as.raster = FALSE, as.df = TRUE, as.points = TRUE, values = FALSE, cells = FALSE, xy = TRUE, ext = NULL, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)
randompointsmeadow <- spatSample(meadowrastmask, 2500, method = "stratified", replace = FALSE, na.rm = TRUE, as.raster = FALSE, as.df = FALSE, as.points = TRUE, values = FALSE, cells = FALSE, xy = TRUE, ext = NULL, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)
randompointsshrub <- spatSample(shrubrastmask, 2500, method = "stratified", replace = FALSE, na.rm = TRUE, as.raster = FALSE, as.df = FALSE, as.points = TRUE, values = FALSE, cells = FALSE, xy = TRUE, ext = NULL, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)
randompointstreed <- spatSample(treedrastmask, 2500, method = "stratified", replace = FALSE, na.rm = TRUE, as.raster = FALSE, as.df = FALSE, as.points = TRUE, values = FALSE, cells = FALSE, xy = TRUE, ext = NULL, warn = TRUE, weights = NULL, exp = 3, exhaustive = FALSE)

#plot points
plot(ltspatrast)
print(ltspatrast)
plot(spatrast)

plot(randompointsground, add = TRUE, cex = 0.1)
print(randompointsground)

plot(randompointsmeadow, add = TRUE, cex = 0.1)
print(randompointsmeadow)

plot(randompointsshrub, add = TRUE, cex = 0.1)
print(randompointsshrub)

plot(randompointstreed, add = TRUE, cex = 0.1)
print(randompointstreed)

#extract MAGNITUDE values from points
?extract
extractvaluesground <- terra::extract(ltspatrast, randompointsground, fun = NULL, method = "simple", bind = TRUE)
summary(extractvaluesground)

extractvaluesmeadow <- terra::extract(ltspatrast, randompointsmeadow, fun = NULL, method = "simple", bind = TRUE)
summary(extractvaluesmeadow)

extractvaluesshrub <- terra::extract(ltspatrast, randompointsshrub, fun = NULL, method = "simple", bind = TRUE)
summary(extractvaluesshrub)

extractvaluestreed <- terra::extract(ltspatrast, randompointstreed, fun = NULL, method = "simple", bind = TRUE)
summary(extractvaluestreed)

#box plot 
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

#Bring points into arc 
write.csv(extractvaluesground, "groundpoints.csv")
write.csv(extractvaluesmeadow, "meadowpoints.csv")
write.csv(extractvaluesshrub, "shrubpoints.csv")
write.csv(extractvaluestreed, "treedpoints.csv")



