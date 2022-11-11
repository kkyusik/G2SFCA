# Generalized 2SFCA



This generalized two-step catchment area (G2SFCA) method was used in Kim, K., & Kwon, K. (2022). Time-varying spatial accessibility of primary healthcare services based on spatiotemporal variations in demand, supply, and traffic conditions: A case study of Seoul, South Korea. *Journal of Transport & Health*, *27*, 101531.



접근성 지표는 다음의 수식으로 계산된다. 

$A_i = \sum_j \frac{S_j f(d_{ij})} { \sum_k P_k f(d_{kj})}$

여기서 $P_k$ 는 $k$에서의 수요이고, $S_j$는 $j$ 시설의 공급을 의미하며, $d_{kj}$는 수요 지점 $k$에서 공급 지점 $j$까지의 이동시간이다. 

$f(d_{ij})$는 거리/시간 조락 함수이며, power, negative exponential 또는 Gaussian 함수가 이용된다. Kim and Kwon (2022) 연구에서는 Gaussian 함수를 이용했으며, catchment area를 15분으로 설정했기 때문에 15분 한계거리에서 $f(d_{ij})$를 0.01로 만드는 Gaussian의 $\beta 파라미터로 50을 이용했다. 



Gaussian 함수 수식:

$f(d_{ij}) = exp^{-d_{ij}^2/\beta}$



G2SFCA를 계산하기 위한 Generalized2SFCA 함수는 몇 가지 파라미터들을 필요로 한다. 

* `network_data`: 이미 계산된 OD cost matrix

* `cost_col`: `network_data`에 포함된 distance 또는 time 열의 이름

* `demand_data`: 수요 자료의 이름

* `demand_id`: 수요 자료에서 id의 열 이름

* `demand_col`: 수요 자료에서 수요를 의미하는 열 이름

* `supply_data`: 공급 자료의 이름

* `supply_id`: 공급 자료에서 id의 열 이름

* `supply_col`: 공급자료에서 공급을 의미하는 열 이름

* `catchment`: 한계 거리 또는 시간 설정

* `impedance_beta`: Gaussian 함수의 $\beta$ 파라미터



기본적인 데이터 구성은 다음과 같다.

**network_data**

| demand_id     | supply_id     | cost_col      |
| ------------- | ------------- | ------------- |
| 101100        | hkh5592       | 5             |
| 101100        | kkn4421       | 13            |
| .<br/>.<br/>. | .<br/>.<br/>. | .<br/>.<br/>. |

**demand_data**

| demand_id     | demand_col    |
| ------------- | ------------- |
| 101100        | 5042          |
| 101101        | 7220          |
| .<br/>.<br/>. | .<br/>.<br/>. |

**supply_data**

| supply_id     | supply_col    |
| ------------- | ------------- |
| hkh5592       | 2             |
| kkn4421       | 5             |
| .<br/>.<br/>. | .<br/>.<br/>. |
