import rasterio
import numpy
from xml.dom import minidom

# Inputs for function.. to be scaled up in future
# This doesn't need to be operational persay like the fog script..
# therefore, should have this bee something that can run in one shot where we need all of the data
image = "./data/20210711_183242/20210711_183242_20_240c_3B_AnalyticMS_SR_clip.tif"
xml = "./data/20210711_183242/20210711_183242_20_240c_3B_AnalyticMS_metadata_clip.xml"
output = './data/20210711_183242/ndvi.tif'

def create_ndvi_raster(image,xml,output):
    # Load red and NIR bands - note all PlanetScope 4-band images have band order BGRN
    with rasterio.open(image) as src:
        band_red = src.read(3)

    with rasterio.open(image) as src:
        band_nir = src.read(4)

    xmldoc = minidom.parse(xml)
    nodes = xmldoc.getElementsByTagName("ps:bandSpecificMetadata")

    # XML parser refers to bands by numbers 1-4
    coeffs = {}
    for node in nodes:
        bn = node.getElementsByTagName("ps:bandNumber")[0].firstChild.data
        if bn in ['1', '2', '3', '4']:
            i = int(bn)
            value = node.getElementsByTagName("ps:reflectanceCoefficient")[0].firstChild.data
            coeffs[i] = float(value)
            
    # Multiply by corresponding coefficients
    band_red = band_red * coeffs[3]
    band_nir = band_nir * coeffs[4]

    # Allow division by zero
    numpy.seterr(divide='ignore', invalid='ignore')

    # Calculate NDVI
    ndvi = (band_nir.astype(float) - band_red.astype(float)) / (band_nir + band_red)

    # Set spatial characteristics of the output object to mirror the input
    kwargs = src.meta
    kwargs.update(
        dtype=rasterio.float32,
        count = 1)

    # Create the file
    with rasterio.open(output, 'w', **kwargs) as dst:
            dst.write_band(1, ndvi.astype(rasterio.float32))
