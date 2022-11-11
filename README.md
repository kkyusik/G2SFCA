# Generalized 2SFCA



This generalized two-step catchment area (G2SFCA) method was used in Kim, K., & Kwon, K. (2022). Time-varying spatial accessibility of primary healthcare services based on spatiotemporal variations in demand, supply, and traffic conditions: A case study of Seoul, South Korea. *Journal of Transport & Health*, *27*, 101531.



접근성 지표는 다음의 수식으로 계산된다. 

$A_i = \sum_j \frac{S_j f(d_{ij})} { \sum_k P_k f(d_{kj})}$

여기서 $P_k$ 는 $k$에서의 수요이고, $S_j$는 $j$ 시설의 공급을 의미하며, $d_{kj}$는 수요 지점 $k$에서 공급 지점 $j$까지의 이동시간이다. 

$f(d_{ij})$는 거리/시간 조락 함수이며, power, negative exponential 또는 Gaussian 함수가 이용된다. Kim and Kwon (2022) 연구에서는 Gaussian 함수를 이용했으며, catchment area를 15분으로 설정했기 때문에 15분 한계거리에서 $f(d_{ij})$를 0.01로 만드는 Gaussian의 $\beta 파라미터로 50을 이용했다. 
