# 동작방법

```bash
#example
# /terraform/dev/back
terraform init
terraform plan
terraform apply
```
- 하단의 API 문서를 참고하여 요청을 보내 테스트 가능
- Grafana 접속
- http://15.165.74.4:3000/ 

back - vpc - instance - storage - monitor-instance 폴더순으로 들어가서 위의 3개의 명령어를 진행한다.
# 프로젝트 소개

## 요구사항

- 수행 방법

```bash
1. AWS 기반으로 서비스를 생성해주세요 
2. IaC 도구를 이용해서 인프라 구성을 해주세요 
3. laC 관련 yaml 파일과 sample project 파일은 같은 Github Repository에 저장해주세요 
```

- 개발 필수요건

```bash
1. Docker 기반의 서비스 생성 
	- API 1개를 만들어서 기본적인 응답을 할 수 있도록 해주세요 
	- ECS 또는 EKS 기반으로 서비스를 생성해주세요 

2. ELB 를 포함한 구조로 만들어 주세요 

3. CI/CD 를 구성해주세요
```

- 개발 추가요건(선택)

```bash
1. CRUD 기능 구현(NoSQL DB)
2. Route53 도메인 연결
```

# 프로젝트 결과물

## 인프라 아키텍쳐

![image](https://github.com/hansungmoon/marketboro/assets/98951034/27836e2c-7627-4931-b162-dc5944566f41)


## ECS 기반 서비스

**Docker 기반의 서비스 생성**

Dockerfile을 생성하여 Docker이미지를 생성하였습니다.

생성된 이미지를 ECR의 private repository로 업로드하여 이미지를 관리하였습니다.

.dockerignore를 이용하여 node_modules를 제외하고 이미지가 생성되게 관리하였습니다.

**CURD 구현(NoSQL DB)**

먼저 사용할 DB는 AWS DynamoDB를 이용하여 기본적인 CRUD를 구현하였습니다. 

사용한 언어는 nodeJS를 이용하였고 express 프레임워크 기반으로 코드를 작성 했습니다.

aws-sdk를 이용하여 dynamoDB를 소스코드로 이용했습니다.

**ECS**

ECR에 업로드된 이미지를 이용하여 ECS를 배포하였습니다.

private subnet에 ECS를 배포 함으로써 외부 노출을 최소화 하였습니다.

외부의 트래픽을 받기위해서 ALB는 public subnet에 배포하였습니다.

private subnet에서 외부의 ECR과 DynamoDB로 접근하기 위해서 vpc endpoint를 이용하였습니다.

## Route53 도메인 연결

[marketboro.click](http://marketboro.click) 도메인을 구매하여 Route53에 연결 하였습니다.

또한 로드밸런서를 레코드로 등록시켜 [www.marketboro.click](http://www.marketboro.click) 으로 요청을 받을 수 있게 했습니다.

해당 레코드만 terraform으로 추가하고 삭제될 수 있게 구현했습니다.

## CI/CD

Github Actions를 사용하여 CI/CD를 구축했습니다.

main branch에 curd폴더 안에 push가 되었을 때 Github Actions가 작동합니다.

특정 폴더 안으로 경로를 지정함으로써 소스코드와 관련이 없는 다른 변경사항이 push가 되었을 때는 실행되지 않게 했습니다.

**GitHub Actions 작동 과정**

- docker 이미지를 생성한 후에 ECR에 업로드 합니다.
- 업로드가 완료되면 ECS의 Task-definition을 받아와서 이미지의 url과 환경변수값을 변경하여 ECS에 변경된 Task-definition을 배포합니다.
- ECS 가 새로 개정된 Task-definition에 의해서 자동으로 재배포됩니다.

## IaC

Terraform을 사용하여 인프라 구성을 하였습니다.

DRY 원칙을 고려하여 코드의 로직을 재사용 가능한 단위로 나누어서 구성하였습니다.

원하는 위치에서 해당 코드를 호출 하여 사용할 수 있기 위해 [output.tf](http://output.tf)파일에 외부 폴더에서 필요한 값들을 내보내고 호출하는 폴더에서는 .tfstate파일에서 해당 값을 받아서 사용 할 수 있습니다.

숨겨야 되는 값들은 .auto.tfvars를 이용하여 노출되지 않도록 관리하였습니다.

```bash
/terraform/dev
├── back
│   ├── backend.tf
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   └── variable.tf
├── instance
│   ├── backend.tf
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   └── variable.tf
├── monitor-instance
│   ├── backend.tf
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   └── variable.tf
├── storage
│   ├── backend.tf
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   └── variable.tf
└── vpc
    ├── backend.tf
    ├── main.tf
    ├── output.tf
    ├── provider.tf
    └── variable.tf
```

### Terraform GitOps

**Terraform GitOps 작동과정**

- terraform폴더 안에서 변경사항이 push 되면 작동한다.
- AWS 자격 증명 구성을 한다.
- VPC - Storage - instance - monitor instance 순서로 terraform으로 배포된다.

Terraform GitOps를 구성하는 과정에서 GitHub Actions로 .tfstate파일을 편하게 읽고 사용할 수 있도록 Terraform backend 기능을 이용하여 **S3에 .tfstate파일을 저장**하여 사용했습니다.

이로 인해 GitOps를 여러번 실행해도 해당 상태를 인지하고 관리할 수 있었으며, 로컬에서도 현재 상태를 읽어와서 사용할 수 있었습니다.

또한, dynamoDB를 상태잠금으로 구성하여 주어진 시간에 하나의 실행만 상태파일을 수정할 수있게 lock을 걸어서 **동시성 에러를 방지**할 수 있었습니다.

## 모니터링

```bash
# 그라파나 접속
http://15.165.74.4:3000
id : admin
pw : admin
```

ec2안에 docker, k6를 다운받고 Grafana와 influxDB를 docker-compose로 컨테이너에 배포 했습니다.

해당 ec2는 AMI를 만들어 문제가 생겼을 때 빠른 복구를 할 수 있도록 하였습니다.

모니터링은 총 4가지를 구성했습니다.

- ECS - CloudWatch - Grafana
- DynamoDB- CloudWatch - Grafana
- CloudWatch loggroup(ECS) - Grafana
- K6 - influxDB - Grafana

### CloudWatch 메트릭을 이용해서 모니터링

ECS와 DynamoDB의 메트릭을 CloudWatch에서 받아와서 Grafana로 시각화 하였습니다.

- ECS

메모리 사용량과 CPU 사용량 체크

![image](https://github.com/hansungmoon/marketboro/assets/98951034/e20a4f2e-24b0-4cfb-9a89-1a11746fc506)


- DynamoDB

프로비저닝된 값 사용량과 읽기와 쓰기의 횟수 등 체크

![image](https://github.com/hansungmoon/marketboro/assets/98951034/5d7242cb-ba05-445b-85a0-82f3ee5bfc29)


### CloudWatch log group 모니터링

ECS가 배포되면 생기는 CloudWatch loggroup을 Grafana로 시각화 하였습니다.

수신 또는 송신되는 초당 바이트를 측정하여 여러개의 로그그룹을 비교할 수 있습니다.
에러 로그의 개수를 확인 할 수있습니다.

![image](https://github.com/hansungmoon/marketboro/assets/98951034/abbf199c-9704-4a45-9c9e-584e57de6c75)


### 부하테스트와 모니터링 연결

k6과 InfluxDB를 함께 사용하여, k6은 웹 애플리케이션의 부하를 생성하고 성능 테스트를 실행하며, InfluxDB는 k6이 생성하는 결과 및 지표 데이터를 저장하고 분석할 수 있었습니다.

k6은 성능 테스트 결과를 InfluxDB로 직접 전송할 수 있는 플러그인을 제공하므로, 테스트 실행 중에 생성된 지표 데이터를 InfluxDB에 전송하여 Grafana와 연결해서 시각화하여 모니터링 할 수 있었습니다.

![image](https://github.com/hansungmoon/marketboro/assets/98951034/8a17ba9c-c03e-489e-9edd-92d2229b0e91)


이를 통해 현재 서버가 얼마만큼의 부하를 감당할 수 있으며 반응 시간은 적합한 지를 검토할 수 있도록 하였습니다.

## API 문서

## **베이스 URL**

```arduino
http://www.marketboro.click/items
```

### CREATE

새로운 아이템을 생성합니다.

**요청**

- URL: **`/items`**
- 메서드: **`POST`**
- 요청 바디 데이터:

```json
{
  "id": "1",
  "name": "Item One"
}
```

**응답**

- 상태 코드: **`201 Created`**
- 응답 바디 데이터:

```json
{
    "message": "Item created successfully"
}
```

### READ

아이템의 세부 정보를 조회합니다.

**요청**

- URL: **`/items/{id}`**
- 메서드: **`GET`**
- 경로 파라미터:
    - **`id`** (문자열): 아이템의 고유 식별자

**응답**

- 상태 코드: **`200 OK`**
- 응답 바디 데이터:

```json
{
    "id": "1",
    "name": "Item One"
}
```

### Update

기존 아이템의 정보를 업데이트합니다.

**요청**

- URL: **`/items/{id}`**
- 메서드: **`PUT`**
- 경로 파라미터:
    - **`id`** (문자열): 아이템의 고유 식별자
- 요청 바디 데이터:

```json
{
  "name": "Updated Item"
}
```

**응답**

- 상태 코드: **`200 OK`**
- 응답 바디 데이터:

```json
{
    "message": "Item updated successfully"
}
```

### DELETE

아이템을 삭제합니다.

**요청**

- URL: **`/items/{id`**
- 메서드: **`DELETE`**
- 경로 파라미터:
    - **`id`** (문자열): 아이템의 고유 식별자

**응답**

- 상태 코드: **`200 OK`**
- 응답 바디 데이터:

```json
{
    "message": "Item deleted successfully"
}
```
