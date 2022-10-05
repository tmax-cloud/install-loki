# Loki Alert plugin 가이드
* 목적: Loki에 적재되는 index & chunk data가 특정 조건을 충족하면 알림을 수신할 수 있다.
* rules.yaml를 생성한 후, [01_loki.yaml](../yaml/01_loki.yaml) 의 configmap에서 ruler에 설정된 alertmanager_url로 alert를 수신한다.


## Rules 설정하기
* 목적: Alert를 수신하기 위한 트리거 혹은 Record를 통해 새로운 timeseries set을 저장하기 위한 트리거를 생성한다.
* prometheus와 동일하게 rule.yml 내부에 groups 아래에 여러 개의 rule을 설정할 수 있다.
* Alert 예시) 특정 네임스페이스와 파드를 지정하여 "error"를 포함하는 로그의 비율이 지정한 값보다 높으면 alert를 firing한다.

```
rule.yml: |
  groups:
    - name: should_fire
      rules:
      - alert: HighPercentageError
        expr: |
          sum(rate({namespace="monitoring", pod_name="loki-0"} |= "error" [5m])) by (hostname)
            /
          sum(rate({namespace="monitoring", pod_name="loki-0"}[5m])) by (hostname)
            > 0.05
        for: 10m  ## 
        labels:
            severity: page
        annotations:
            summary: High request latency
```

* kubectl apply -f loki-rule.yaml을 실행하여 설정한 rule을 적용시킨다.
* 설정된 Rule을 삭제하고자 경우, kubectl delete -f loki-rule.yaml을 실행한다.
