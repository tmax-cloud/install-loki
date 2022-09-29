# Grafana-Loki 로그 조회 가이드

### Loki Stack 기본 구조
* Loki stack은 Promtail - Loki - Grafana로 구성되어 있다.
* Promtail을 통해 k8s cluster 로그를 수집하여 Loki에 적재하면 Grafana UI를 통해 로그를 시각화하여 볼 수 있다.
* Promtail을 통해 수집한 log data는 Loki와 연동된 pvc에 적재하여 관리하거나 별도의 저장소를 연동하여 관리할 수 있다.
![image](../figure/loki-stack.png)

## Grafana UI에서 특정 네임스페이스 로그 조회
* 목적: Promtail을 통해 로그가 Loki에 적재가 잘 되고 있는지 확인하고, explore를 통해 로그의 상세 내역을 조회할 수 있다.
* 순서: 
    * Explore 화면에서 Data Source로 Loki를 선택한다.
    * Log browser를 클릭 후, namespace 라벨을 클릭하여 조회하고자 하는 네임스페이스 명을 클릭한다. ex) hyperauth
    * Show logs를 클릭하여 조회한다.
![image](../figure/grafana-log.png)
![image](../figure/grafana-log2.png)

    * Explore 화면의 가장 오른쪽 위에 있는 Live 버튼을 클릭하면 실시간으로 적재되는 log를 조회하여 확인할 수 있다.
![image](../figure/grafana-live.png)
