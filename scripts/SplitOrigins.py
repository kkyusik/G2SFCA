# writtin in Python 3.7.11

# Network Analysis에서 집계구를 모두 이용하게 되면 output file의 크기가 4GB를 넘어 계산이 불가능.
# 10개로 나누어 network analysis를 따로 수행.


import os
os.chdir("../")
os.getwd()

import pandas as pd
import geopandas as gpd

gdf = gpd.read_file('raw_input/통계지역경계(2016년+기준)/집계구.shp')

gdf = gdf.set_crs(epsg=5179) #UTM-K
gdf = gdf.to_crs(epsg=4326) #WGS84

# gdf.head()

## Export base data
gdf.to_file('clean_input/TOT_REG_CD_polygon.gpkg', driver='GPKG')
gdf.geometry = gdf.centroid
gdf.to_file('clean_input/TOT_REG_CD.gpkg', driver='GPKG')


## Split 집계구 to 10
# 폴더 이름 (clean_input/origins)는 사용자의 환경에 따라 수정. 
output_folder = "clean_input/origins/"
split_number = 10
gdf_length = int(len(gdf) / split_number)

total_len = 0

for i in range(0, split_number):

    if i == 0:
        gdf_temp = gdf.loc[0:gdf_length, :]
        gdf_temp.to_file(output_folder + 'TOT_REG_CD_' + str(i+1) + '.shp')
        total_len += len(gdf_temp)

    elif i == (split_number-1):
        gdf_temp = gdf.loc[gdf_length*i+1:, :]
        gdf_temp.to_file(output_folder + 'TOT_REG_CD_' + str(i+1) + '.shp')
        total_len += len(gdf_temp)

    else:
        start_ind = gdf_length * i + 1
        end_ind = gdf_length * (i+1)
        gdf_temp = gdf.loc[start_ind:end_ind, :]
        gdf_temp.to_file(output_folder + 'TOT_REG_CD_' + str(i+1) + '.shp')
        total_len += len(gdf_temp)

print("Total numbers: " + str(total_len))
