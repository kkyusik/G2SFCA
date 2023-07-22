# writtin in R

# 2021-09-23 version

#' 국가교통DB의 2020년 도로망 자료에 (2019년 기반) 서울시교통정보(https://topis.seoul.go.kr/)에서 서울시 차량통행속도를 매칭시킴. 여기서 도로망자료의 링크아이디는 표준링크 아이디이고, 서울시 차량통행속도의 링크아이디는 서비스링크아이디임. 따라서 서울특별시 교통소통 표준링크 매핑정보 (http://data.seoul.go.kr/dataList/OA-15061/S/1/datasetView.do)를 이용해 두 자료를 연계함. 
#' 이 자료는 통행거리와 통행속도를 포함하고 있기 때문에 통행시간을 계산할 수 있음.
#' 통행거리는 meter인 것으로 보이며, 통행속도는 km/h임. 따라서 통행시간은 다음의 식으로 구함. 
#' 통행시간(분) = \frac{통행거리(m)/1000}{통행속도} \times 60


#' 다음 단계는 통행거리와 통행속도를 모두 도로망에 집계하는 것임.
#' 2019년 ktdb에 2021년 3월 자료를 매칭해도 됨.
#' 근데 표준노드링크는 도저히 매칭이 안됨. 
#' LINK_ID는 안 맞는데 T_NODE가 맞는 경우가 있음. 
#' LINK_ID, F_NODE, T_NODE를 모두 동원하면 많이 맞긴 하지만 여전히 안 맞는 부분들이 존재하고, 노드번호로 매칭하는 것은 신뢰하기 어려움. 
#' 

#' 2021년 4월 속도자료를 이용해 각 시간별 평균속도 구하기.  평일을 중심으로.
#' 


#### 필요 정보 ####
# 속도: 2021년 04월 서울시 차량통행속도.csv
# 표준링크 매핑정보: 서울특별시 교통소통 표준링크 매핑정보_20190716.csv
# 도로 shapefile: seoul_road.shp
# 시도 shapefile: bnd_sido_00_2019_2019_2Q.shp

# output은 road_network_ktdb_april.gpkg


requiredPackages <- c("data.table", "tidyverse", "sf", "tmap")
for (p in requiredPackages) {
    if (!require(p, character.only = TRUE)) install.packages(p)
    library(p, character.only = TRUE)
}

# 시간 기준은 8시, 10시, 15시, 18시, 20시임.
link <- read.csv('raw_input/2021년 04월 서울시 차량통행속도.csv', fileEncoding = 'euc-kr') # Import 속도
link <- link %>% as_tibble()

link <- link %>% filter(!요일 %in% c('금', '토', '일'))
link <- link %>%
        mutate(X01시 = ifelse(is.na(X01시), rowMeans(across(X01시:X24시), na.rm=TRUE), X01시),
               X02시 = ifelse(is.na(X02시), rowMeans(across(X01시:X24시), na.rm=TRUE), X02시),
               X03시 = ifelse(is.na(X03시), rowMeans(across(X01시:X24시), na.rm=TRUE), X03시),
               X04시 = ifelse(is.na(X04시), rowMeans(across(X01시:X24시), na.rm=TRUE), X04시),
               X05시 = ifelse(is.na(X05시), rowMeans(across(X01시:X24시), na.rm=TRUE), X05시),
               X06시 = ifelse(is.na(X06시), rowMeans(across(X01시:X24시), na.rm=TRUE), X06시),
               X07시 = ifelse(is.na(X07시), rowMeans(across(X01시:X24시), na.rm=TRUE), X07시),
               X08시 = ifelse(is.na(X08시), rowMeans(across(X01시:X24시), na.rm=TRUE), X08시),
               X09시 = ifelse(is.na(X09시), rowMeans(across(X01시:X24시), na.rm=TRUE), X09시),
               X10시 = ifelse(is.na(X10시), rowMeans(across(X01시:X24시), na.rm=TRUE), X10시),
               X11시 = ifelse(is.na(X11시), rowMeans(across(X01시:X24시), na.rm=TRUE), X11시),
               X12시 = ifelse(is.na(X12시), rowMeans(across(X01시:X24시), na.rm=TRUE), X12시),
               X13시 = ifelse(is.na(X13시), rowMeans(across(X01시:X24시), na.rm=TRUE), X13시),
               X14시 = ifelse(is.na(X14시), rowMeans(across(X01시:X24시), na.rm=TRUE), X14시),
               X15시 = ifelse(is.na(X15시), rowMeans(across(X01시:X24시), na.rm=TRUE), X15시),
               X16시 = ifelse(is.na(X16시), rowMeans(across(X01시:X24시), na.rm=TRUE), X16시),
               X17시 = ifelse(is.na(X17시), rowMeans(across(X01시:X24시), na.rm=TRUE), X17시),
               X18시 = ifelse(is.na(X18시), rowMeans(across(X01시:X24시), na.rm=TRUE), X18시),
               X19시 = ifelse(is.na(X19시), rowMeans(across(X01시:X24시), na.rm=TRUE), X19시),
               X20시 = ifelse(is.na(X20시), rowMeans(across(X01시:X24시), na.rm=TRUE), X20시),
               X21시 = ifelse(is.na(X21시), rowMeans(across(X01시:X24시), na.rm=TRUE), X21시),
               X22시 = ifelse(is.na(X22시), rowMeans(across(X01시:X24시), na.rm=TRUE), X22시),
               X23시 = ifelse(is.na(X23시), rowMeans(across(X01시:X24시), na.rm=TRUE), X23시),
               X24시 = ifelse(is.na(X24시), rowMeans(across(X01시:X24시), na.rm=TRUE), X24시))

network <- link %>%
    group_by(링크아이디) %>%
    summarise(
        distance = mean(거리),
        speed_01 = mean(X01시),
        speed_02 = mean(X02시),
        speed_03 = mean(X03시),
        speed_04 = mean(X04시),
        speed_05 = mean(X05시),
        speed_06 = mean(X06시),
        speed_07 = mean(X07시),
        speed_08 = mean(X08시),
        speed_09 = mean(X09시),
        speed_10 = mean(X10시),
        speed_11 = mean(X11시),
        speed_12 = mean(X12시),
        speed_13 = mean(X13시),
        speed_14 = mean(X14시),
        speed_15 = mean(X15시),
        speed_16 = mean(X16시),
        speed_17 = mean(X17시),
        speed_18 = mean(X18시),
        speed_19 = mean(X19시),
        speed_20 = mean(X20시),
        speed_21 = mean(X21시),
        speed_22 = mean(X22시),
        speed_23 = mean(X23시),
        speed_24 = mean(X24시)
    )

network$링크아이디 <- as.character(network$링크아이디)


connection <- read.csv("raw_input/서울특별시 교통소통 표준링크 매핑정보_20190716.csv", fileEncoding = "euc-kr") %>%
    as_tibble()

connection <- connection %>%
    select(-표준링크순서) %>%
    mutate(
        서비스링크아이디 = as.character(서비스링크아이디),
        표준링크아이디 = as.character(표준링크아이디)
    )

rawdata_road <- read_sf("raw_input/seoul_road.shp")


road <- rawdata_road
road <- road %>% select(LINK_ID, LENGTH, MAX_SPD, TRAF_ID_P, TRAF_ID_N) # N: 상행, P: 하행
road <- road %>% mutate(
    TRAF_ID_P = as.character(TRAF_ID_P),
    TRAF_ID_N = as.character(TRAF_ID_N)
)

road <- road %>%
    left_join(connection, by = c("TRAF_ID_N" = "표준링크아이디")) %>%
    left_join(connection, by = c("TRAF_ID_P" = "표준링크아이디"))

road <- road %>% filter(!is.na(서비스링크아이디.x) | !is.na(서비스링크아이디.y)) # x:상행, y:하행


road <- road %>%
    left_join(network, by = c("서비스링크아이디.x" = "링크아이디")) %>%
    left_join(network, by = c("서비스링크아이디.y" = "링크아이디"))

road <- road %>% filter(!is.na(speed_08.x) | !is.na(speed_08.y))


road <- road %>%
    mutate(
        speed_01 = rowMeans(across(c(speed_01.x, speed_01.y)), na.rm = T),
        speed_02 = rowMeans(across(c(speed_02.x, speed_02.y)), na.rm = T),
        speed_03 = rowMeans(across(c(speed_03.x, speed_03.y)), na.rm = T),
        speed_04 = rowMeans(across(c(speed_04.x, speed_04.y)), na.rm = T),
        speed_05 = rowMeans(across(c(speed_05.x, speed_05.y)), na.rm = T),
        speed_06 = rowMeans(across(c(speed_06.x, speed_06.y)), na.rm = T),
        speed_07 = rowMeans(across(c(speed_07.x, speed_07.y)), na.rm = T),
        speed_08 = rowMeans(across(c(speed_08.x, speed_08.y)), na.rm = T),
        speed_09 = rowMeans(across(c(speed_09.x, speed_09.y)), na.rm = T),
        speed_10 = rowMeans(across(c(speed_10.x, speed_10.y)), na.rm = T),
        speed_11 = rowMeans(across(c(speed_11.x, speed_11.y)), na.rm = T),
        speed_12 = rowMeans(across(c(speed_12.x, speed_12.y)), na.rm = T),
        speed_13 = rowMeans(across(c(speed_13.x, speed_13.y)), na.rm = T),
        speed_14 = rowMeans(across(c(speed_14.x, speed_14.y)), na.rm = T),
        speed_15 = rowMeans(across(c(speed_15.x, speed_15.y)), na.rm = T),
        speed_16 = rowMeans(across(c(speed_16.x, speed_16.y)), na.rm = T),
        speed_17 = rowMeans(across(c(speed_17.x, speed_17.y)), na.rm = T),
        speed_18 = rowMeans(across(c(speed_18.x, speed_18.y)), na.rm = T),
        speed_19 = rowMeans(across(c(speed_19.x, speed_19.y)), na.rm = T),
        speed_20 = rowMeans(across(c(speed_20.x, speed_20.y)), na.rm = T),
        speed_21 = rowMeans(across(c(speed_21.x, speed_21.y)), na.rm = T),
        speed_22 = rowMeans(across(c(speed_22.x, speed_22.y)), na.rm = T),
        speed_23 = rowMeans(across(c(speed_23.x, speed_23.y)), na.rm = T),
        speed_24 = rowMeans(across(c(speed_24.x, speed_24.y)), na.rm = T)
    )

road <- road %>% select(LINK_ID, LENGTH, MAX_SPD, speed_01:speed_24)

road <- st_transform(road, 4326)

write_sf(road, "clean_input/road_ktdb_matched.gpkg", delete_layer = T)


## Get road network with no speed

link_id_list <- unique(road$LINK_ID)
road_temp <- rawdata_road %>% filter(!LINK_ID %in% link_id_list)

## Intersect

zone <- read_sf('raw_input/bnd_sido_00_2019_2019/bnd_sido_00_2019_2019_2Q.shp')
zone <- zone %>% filter(sido_cd == '11')

zone <- st_buffer(zone, 2000)

road_temp <- st_transform(road_temp, 4326)
zone <- st_transform(zone, 4326)

intersected_road <- st_intersection(zone, road_temp)
# qtm(intersected_road)

intersected_road <- intersected_road %>% 
        select(LINK_ID, LENGTH, MAX_SPD)

intersected_road <- intersected_road %>%
        mutate(speed_01 = 0,
               speed_02 = 0,
               speed_03 = 0,
               speed_04 = 0,
               speed_05 = 0,
               speed_06 = 0,
               speed_07 = 0,
               speed_08 = 0,
               speed_09 = 0,
               speed_10 = 0,
               speed_11 = 0,
               speed_12 = 0,
               speed_13 = 0,
               speed_14 = 0,
               speed_15 = 0,
               speed_16 = 0,
               speed_17 = 0,
               speed_18 = 0,
               speed_19 = 0,
               speed_20 = 0,
               speed_21 = 0,
               speed_22 = 0,
               speed_23 = 0,
               speed_24 = 0)

temp <- rbind(road, intersected_road)
temp$MAX_SPD <- as.integer(temp$MAX_SPD)

unique(temp$MAX_SPD)

temp %>% filter(MAX_SPD != 0) %>%
        ggplot(., aes(x=as.factor(MAX_SPD))) + geom_bar()



road_sum <- road %>% 
        as_tibble() %>%
        # filter(MAX_SPD==60) %>%
        group_by(MAX_SPD) %>%
        summarise(speed_01 = mean(speed_01),
                  speed_02 = mean(speed_02),
                  speed_03 = mean(speed_03),
                  speed_04 = mean(speed_04),
                  speed_05 = mean(speed_05),
                  speed_06 = mean(speed_06),
                  speed_07 = mean(speed_07),
                  speed_08 = mean(speed_08),
                  speed_09 = mean(speed_09),
                  speed_10 = mean(speed_10),
                  speed_11 = mean(speed_11),
                  speed_12 = mean(speed_12),
                  speed_13 = mean(speed_13),
                  speed_14 = mean(speed_14),
                  speed_15 = mean(speed_15),
                  speed_16 = mean(speed_16),
                  speed_17 = mean(speed_17),
                  speed_18 = mean(speed_18),
                  speed_19 = mean(speed_19),
                  speed_20 = mean(speed_20),
                  speed_21 = mean(speed_21),
                  speed_22 = mean(speed_22),
                  speed_23 = mean(speed_23),
                  speed_24 = mean(speed_24))

# MAX_SPD가 60인 경우가 제일 많았음. 
# 따라서 속도가 0값인 경우 60의 평균 속도를 입력함.
temp$MAX_SPD[temp$MAX_SPD == 0] <- 60

road_sum$speed_08[road_sum$MAX_SPD==60]

time_var_list <- c('01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
                   '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', 
                   '21', '22', '23', '24')

for (max_speed in unique(road_sum$MAX_SPD)){
        for (time_var in time_var_list){
                speed_name <- paste0('speed_',time_var)
                temp[[speed_name]][temp$MAX_SPD==max_speed & temp[[speed_name]] == 0 ] <- 
                        road_sum[[speed_name]][road_sum$MAX_SPD==max_speed]
        }
}


max_speed <- 10

for (time_var in time_var_list){
        speed_name <- paste0('speed_', time_var)
        temp[[speed_name]][temp$MAX_SPD==max_speed & temp[[speed_name]] == 0 ] <- max_speed
}

# Time 계산
result <- temp %>%
        mutate(time_max = LENGTH/MAX_SPD*60,
               time_01 = LENGTH/speed_01*60,
               time_02 = LENGTH/speed_02*60,
               time_03 = LENGTH/speed_03*60,
               time_04 = LENGTH/speed_04*60,
               time_05 = LENGTH/speed_05*60,
               time_06 = LENGTH/speed_06*60,
               time_07 = LENGTH/speed_07*60,
               time_08 = LENGTH/speed_08*60,
               time_09 = LENGTH/speed_09*60,
               time_10 = LENGTH/speed_10*60,
               time_11 = LENGTH/speed_11*60,
               time_12 = LENGTH/speed_12*60,
               time_13 = LENGTH/speed_13*60,
               time_14 = LENGTH/speed_14*60,
               time_15 = LENGTH/speed_15*60,
               time_16 = LENGTH/speed_16*60,
               time_17 = LENGTH/speed_17*60,
               time_18 = LENGTH/speed_18*60,
               time_19 = LENGTH/speed_19*60,
               time_20 = LENGTH/speed_20*60,
               time_21 = LENGTH/speed_21*60,
               time_22 = LENGTH/speed_22*60,
               time_23 = LENGTH/speed_23*60,
               time_24 = LENGTH/speed_24*60)


# Exclude unreliable links
## First three links will make unlinked results, and fourth one isi 
exclude <- c(478752631, 478752639, 478752630, 571652242)
result <- result %>% filter(!LINK_ID %in% exclude)

summary(result[29:53])

write_sf(result, 'clean_input/road_network_ktdb_april.gpkg', delete_layer = T)