# 실무 가이드: 조선소 최적화 온톨로지 설계

**2026-01-14 기준 Protégé Desktop 5.6.8 (2025-09-03 릴리스)** 기준 작성

## 개요

이 가이드는 **Working Stage(공정/이동 단계)** 기반 조선소 최적화 모델링을 위한 온톨로지 설계 실무 가이드입니다.

**전체 흐름:**
1. Protégé에서 TBox/ABox 구축
2. TTL/RDF로 내보내기
3. Python에서 파싱/정규화
4. MILP 모델로 풀기

**핵심 목표:**
- H2G9 (중조→대조) 같은 Stage Code로 관리되는 작업 단계 모델링
- 최적화 모델링에 바로 쓰기 좋은 데이터 관계 설계
- 정반 후보 제약을 데이터로 명시하여 최적화 엔진이 바로 사용 가능하도록 구성

**설계 철학:**
- 최적화의 의사결정: "(호선, 블록, 송선=Stage) 작업을 어떤 정반에 배정할 것인가"
- OWL로 "A면 B만 가능"을 완전히 추론하기보다는, 최적화 엔진이 바로 쓰게 **후보집합(Eligible set)**을 데이터로 명시

**표준 필드명:**
- **PROJ_NO** (호선)
- **BLK_NO** (블록)
- **WSTG_CODE** (송선 = Stage)
- **JIG_CODE** (정반)

---

## 0. 준비: Protégé 5.6.8 설정

### 0.1 설치/버전 확인

- 상단 메뉴 **Help → About Protégé**에서 버전이 5.6.8인지 확인
- 5.6.8은 "frequent freeze(특히 macOS에서 발생)" 수정과, **원격 리소스를 조회하는 link extractor 비활성 옵션**이 추가된 릴리스입니다.
- 다운로드: [GitHub Releases](https://github.com/protegeproject/protege-distribution/releases)

### 0.2 사내망/보안망이면: 원격 링크 추출기 비활성 권장

- 5.6.8의 "remote resources(Bioregistry, Identifiers.org) 기반 link extractor 비활성 옵션"은 사내망에서 **UI 멈춤/지연/인증서 이슈**를 줄이는 데 유효합니다.
- 설정 위치: **Preferences(환경설정)**에서 **Link Extractor / External link / Remote resources** 류 옵션을 찾아 off

### 0.3 SPARQL 탭이 비어있거나 안 보이면

- (증상) "SPARQL Query 탭이 비어 있음/아무 것도 안 뜸"
- (대응) `Window > Views > Query Views > Snap SPARQL Query`를 추가해 사용

### 0.4 Protégé 화면 구성 이해

Protégé Desktop은 기본적으로 다음 2개 레벨을 왔다 갔다 합니다.

1. **TBox(스키마/개념)**: Class, Property, Restriction(axiom) 설계
2. **ABox(데이터/인스턴스)**: Individuals에 실제 PROJ_NO/BLK_NO/WSTG_CODE/JIG_CODE, 그리고 작업(job) 등을 입력

**주요 탭:**
- **Entities**: Classes / Object properties / Data properties / Individuals
- **Active Ontology**: Import, Prefix, Ontology annotations 등
- **Reasoner** 메뉴: 분류(Classify), 일관성 검사(Consistency), 설명(Explanation)

---

## 1. Protégé에서 TBox 만들기: 클릭 단위 스텝

### 1.1 새 온톨로지 생성

1. **File → New Ontology**
2. Ontology IRI(예): `http://example.com/shipyard-optim-onto#`
3. **Active Ontology → Prefixes**에서
   - `ex:` = `http://example.com/shipyard-optim-onto#`

### 1.2 클래스(Classes) 구성

**Protégé → Classes 탭 → owl:Thing 아래에 생성**

1. **Entities → Classes**
2. `owl:Thing` 우클릭 → **Add subclass**
3. 아래 클래스들을 생성

#### 마스터 엔터티

- **PROJ_NO** (호선)
- **BLK_NO** (블록)
- **WSTG_CODE** (송선 = Stage)
- **JIG_CODE** (정반)
- **(선택) ShopOrArea** (중조/대조 같은 구역을 명시적으로 두고 싶을 때)

#### 의사결정/입력 단위

- **MoveJob** (배정 대상 작업: 최적화의 "행")

#### 후보집합(제약 표현용)

- **EligibilityRule** (허용 후보 규칙)
  - "특정 (호선, 블록, Stage)은 특정 정반에만 가능"을 데이터로 저장

> **팁**: 클래스 이름은 영문으로 두고, `rdfs:label`로 "PROJ_NO(호선)"처럼 붙이면 현업/개발 모두 편합니다.

---

## 2. 관계(Object Properties) 설계

**Protégé → Object properties 탭에서 아래 생성 후 Domain/Range 설정**

1. **Entities → Object properties**
2. `owl:topObjectProperty` 우클릭 → Add subproperty
3. 각 property 선택 후 오른쪽 패널에서
   - **Domains**에 Domain 클래스 추가
   - **Ranges**에 Range 클래스 추가

### 2.1 호선–블록 귀속

- **belongsToVessel**
  - Domain: `BLK_NO`
  - Range: `PROJ_NO`

### 2.2 작업(MoveJob)의 구성요소

- **jobVessel**: `MoveJob` → `PROJ_NO`
- **jobBlock**: `MoveJob` → `BLK_NO`
- **jobStage**: `MoveJob` → `WSTG_CODE`

### 2.3 배정 결과(의사결정 변수에 대응)

- **assignedJig**: `MoveJob` → `JIG_CODE`
  - (최적화 결과를 적재할 때 채우는 값)

### 2.4 후보집합(EligibilityRule)

**권장 구조(조합 기반 후보 저장):**

- **ruleVessel**: `EligibilityRule` → `PROJ_NO`
- **ruleBlock**: `EligibilityRule` → `BLK_NO`
- **ruleStage**: `EligibilityRule` → `WSTG_CODE`
- **allowedJig**: `EligibilityRule` → `JIG_CODE` (여러 개 가능)

이게 바로 최적화의 `Eligible(job, jig)`를 만드는 원천 데이터가 됩니다.

---

## 3. 속성(Data Properties) 설계

**Protégé → Data properties 탭에서 생성 후 Domain/Range 설정**

1. **Entities → Data properties**
2. 생성 후,
   - Domain: 해당 클래스
   - Range: `xsd:string`, `xsd:decimal`, `xsd:integer` 등

### 3.1 PROJ_NO

- **vesselId**: `PROJ_NO` → `xsd:string`

### 3.2 BLK_NO

- **blockId**: `BLK_NO` → `xsd:string`
- **blockWeightTon**: `BLK_NO` → `xsd:decimal`
- **(선택) blockLengthM, blockWidthM**: `BLK_NO` → `xsd:decimal`

### 3.3 WSTG_CODE(송선 Stage)

- **stageCode**: `WSTG_CODE` → `xsd:string` (예: "H2G9")
- **(선택) fromAreaCode, toAreaCode**: `WSTG_CODE` → `xsd:string`
  - 예: "H2", "G9"를 분리해 관리하고 싶을 때

### 3.4 MoveJob

- **jobId**: `MoveJob` → `xsd:string`
- **priority**: `MoveJob` → `xsd:integer`
- **(선택) earliestStart, latestFinish**: `MoveJob` → `xsd:dateTime`

### 3.5 JIG_CODE

- **jigId**: `JIG_CODE` → `xsd:string`
- **(선택) jigMaxTon, jigLengthM, jigWidthM**: `JIG_CODE` → `xsd:decimal`

---

## 4. Restriction(구조 고정) 넣기: 최적화 연계를 위해 매우 중요

여기서부터가 실무 핵심입니다.
DB/최적화 입력처럼 "키가 흔들리지 않도록" cardinality를 고정합니다.

### 4.1 BLK_NO는 반드시 정확히 1개 PROJ_NO에 속한다

- `BLK_NO ⊑ (belongsToVessel exactly 1 PROJ_NO)`

**Protégé에서:**
1. Classes에서 `BLK_NO` 선택
2. **SubClass Of** 영역에서 `+`(Add)
3. `ObjectExactCardinality` 선택 → property `belongsToVessel`, cardinality `1`, filler `PROJ_NO`

### 4.2 MoveJob은 PROJ_NO/BLK_NO/WSTG_CODE를 각각 정확히 1개 가진다

- `MoveJob ⊑ (jobVessel exactly 1 PROJ_NO)`
- `MoveJob ⊑ (jobBlock exactly 1 BLK_NO)`
- `MoveJob ⊑ (jobStage exactly 1 WSTG_CODE)`

**Protégé에서:**
1. `MoveJob` 클래스 선택
2. **SubClass Of**에서 각각 `ObjectExactCardinality` 추가

### 4.3 EligibilityRule은 (PROJ_NO, BLK_NO, WSTG_CODE) 키를 각각 1개 + allowedJig는 1개 이상

- `EligibilityRule ⊑ (ruleVessel exactly 1 PROJ_NO)`
- `EligibilityRule ⊑ (ruleBlock exactly 1 BLK_NO)`
- `EligibilityRule ⊑ (ruleStage exactly 1 WSTG_CODE)`
- `EligibilityRule ⊑ (allowedJig some JIG_CODE)` (최소 1개)

---

## 5. Individuals(데이터 입력)

**Protégé → Individuals 탭에서 클래스별로 아래를 그대로 생성**

### 5.1 Individuals 생성 방법

- **Entities → Individuals**
- 왼쪽에서 클래스 선택 후 **Add individual**

### 5.2 예시 데이터(최소 세트)

#### (1) 호선 생성

**Class:** `PROJ_NO`

- **Individual:** `V_H001`
  - `vesselId` = "H001"

#### (2) 송선(Stage) 생성: H2G9

**Class:** `WSTG_CODE`

- **Individual:** `ST_H2G9`
  - `stageCode` = "H2G9"
  - **(선택)** `fromAreaCode`="H2", `toAreaCode`="G9"

#### (3) 정반 생성

**Class:** `JIG_CODE`

- `JIG_J01`: `jigId`="J01"
- `JIG_J02`: `jigId`="J02"
- `JIG_J99`: `jigId`="J99" (금지/예외 비교용으로 하나 만들어도 좋습니다)

#### (4) 블록 생성

**Class:** `BLK_NO`

- **Individual:** `B_H001_B010`
  - `blockId` = "B010"
  - `blockWeightTon` = 12.5
  - **Object property assertions:**
    - `belongsToVessel` → `V_H001`

#### (5) 작업(MoveJob) 생성 (최적화 "행")

**Class:** `MoveJob`

- **Individual:** `JOB_H001_B010_H2G9`
  - `jobId` = "H001-B010-H2G9"
  - `priority` = 1
  - **Object property assertions:**
    - `jobVessel` → `V_H001`
    - `jobBlock` → `B_H001_B010`
    - `jobStage` → `ST_H2G9`
  - `assignedJig`는 지금은 비워둡니다(최적화 결과 적재 시 채움).

#### (6) 제약(후보 정반 제한) 입력

**"특정 호선/블록/송선(Stage)은 특정 정반만 가능"**

이 요구사항은 OWL로 억지로 추론시키기보다, 아래처럼 `EligibilityRule`을 데이터로 만들어두는 방식이 최적화 연계에 가장 강합니다.

**Class:** `EligibilityRule`

- **Individual:** `RULE_H001_B010_H2G9`
  - **Object property assertions:**
    - `ruleVessel` → `V_H001`
    - `ruleBlock` → `B_H001_B010`
    - `ruleStage` → `ST_H2G9`
    - `allowedJig` → `JIG_J01`
    - `allowedJig` → `JIG_J02` (여러 개 가능)

**의미:**
- (H001, B010, H2G9) 조합의 작업은 정반 후보가 J01 또는 J02만이다.

**최적화에서는 그대로:**
- `x[job, jig] = 0 if jig ∉ Allowed(job)`로 들어갑니다.

---

## 6. Reasoner로 구조 검증(권장 워크플로)

Protégé Desktop은 reasoner 연동을 지원합니다.
(기능 위치는 대개 상단 **Reasoner** 메뉴)

1. **Reasoner 선택**(예: HermiT)
2. **Start reasoner**
3. **Classify ontology**
4. 이상할 때는 "Explanation" 기능(불일치 원인 추적)을 사용

> **여기서 잡고 싶은 오류 유형:**
- MoveJob에 jobStage가 빠짐('exactly 1' 위반)
- Block이 두 프로젝트에 속함('exactly 1' 위반)
- 서로소(Disjoint) 설정했다면 타입 충돌

---

## 7. 파일로 내보내기(Export): Turtle 권장

1. **File → Save As…**
2. Format: 가능하면 **Turtle(.ttl)** 권장(파이썬 파싱/버전관리에서 가장 읽기 좋음)

---

## 9. SPARQL로 "작업별 허용 정반 후보" 검증 쿼리

**Protégé에서 SPARQL Query 탭(없으면 Window > Tabs > SPARQL Query)을 열고 아래 실행**

### 9.1 모든 Rule 펼쳐보기

```sparql
PREFIX ex: <http://example.com/shipyard-optim-onto#>

SELECT ?rule ?v ?b ?st ?j
WHERE {
  ?rule a ex:EligibilityRule .
  ?rule ex:ruleVessel ?v .
  ?rule ex:ruleBlock ?b .
  ?rule ex:ruleStage ?st .
  ?rule ex:allowedJig ?j .
}
ORDER BY ?rule ?j
```

### 9.2 특정 Job의 후보 정반만 뽑기(Join 방식)

"JOB → (vessel, block, stage)"를 가져와서 Rule과 매칭합니다.

```sparql
PREFIX ex: <http://example.com/shipyard-optim-onto#>

SELECT ?job ?j
WHERE {
  ex:JOB_H001_B010_H2G9 a ex:MoveJob .
  ex:JOB_H001_B010_H2G9 ex:jobVessel ?v .
  ex:JOB_H001_B010_H2G9 ex:jobBlock ?b .
  ex:JOB_H001_B010_H2G9 ex:jobStage ?st .

  ?rule a ex:EligibilityRule .
  ?rule ex:ruleVessel ?v .
  ?rule ex:ruleBlock ?b .
  ?rule ex:ruleStage ?st .
  ?rule ex:allowedJig ?j .

  BIND(ex:JOB_H001_B010_H2G9 AS ?job)
}
ORDER BY ?j
```

---

## 10. Python에서 RDF 읽고, 최적화 입력 테이블로 변환

여기서는 "온톨로지(지식) → 최적화 엔진 입력(sets/params)" 변환을 목표로 합니다.

### 10.1 파이썬 기본 파이프라인(권장 라이브러리)

- RDF 파싱/쿼리: `rdflib`
- (선택) 검증: `pyshacl`
- 최적화: `pyomo` 또는 `docplex` 또는 `ortools`

**설치 예:**

```bash
pip install rdflib pandas pyomo highspy
# CPLEX 쓰면: pip install docplex
```

### 10.2 RDF에서 "JOB–Allowed JIG" 후보집합 뽑기 (SPARQL)

```python
from rdflib import Graph, Namespace

g = Graph()
g.parse("shipyard.ttl", format="turtle")

EX = Namespace("http://example.com/shipyard-optim-onto#")

q = """
PREFIX ex: <http://example.com/shipyard-optim-onto#>

SELECT ?job ?jigId
WHERE {
  ?job a ex:MoveJob .
  ?job ex:jobVessel ?v .
  ?job ex:jobBlock ?b .
  ?job ex:jobStage ?s .

  ?rule a ex:EligibilityRule .
  ?rule ex:ruleVessel ?v .
  ?rule ex:ruleBlock ?b .
  ?rule ex:ruleStage ?s .
  ?rule ex:allowedJig ?jig .

  ?jig ex:jigId ?jigId .
}
"""

rows = [(str(r["job"]), str(r["jigId"])) for r in g.query(q)]
# rows 예: [("http://example.com/shipyard-optim-onto#JOB_H001_B010_H2G9", "J01")]
print(rows)
```

> 이 결과가 곧 최적화의 `Eligible(JOB, JIG_CODE)` 집합이 됩니다.

---

## 11. Python 기반 최적화(MILP) 예시: "배정 + 후보제약"

아래는 가장 기본 형태(작업별 정반 1개 배정, 후보 밖 배정 금지, 비용 최소화)입니다.

### 11.1 입력(예시)

- `JOB`: RDF에서 읽은 job 목록
- `JIG_CODE`: RDF에서 읽은 정반 코드 목록
- `eligible[job, jig]`: 0/1
- `cost[job, jig]`: 거리/이동비용(이 값은 보통 RDB/CSV에서 join)

### 11.2 Pyomo 모델 스켈레톤

```python
import pyomo.environ as pyo

JOBS = ["H001-B010-H2G9"]
JIGS = ["J01", "J02"]

eligible = {("H001-B010-H2G9", "J01"): 1,
            ("H001-B010-H2G9", "J02"): 1}

cost = {("H001-B010-H2G9", "J01"): 10.0,
        ("H001-B010-H2G9", "J02"): 3.0}  # 싸도 후보 아니면 못 감

m = pyo.ConcreteModel()
m.J = pyo.Set(initialize=JOBS)
m.K = pyo.Set(initialize=JIGS)

m.x = pyo.Var(m.J, m.K, domain=pyo.Binary)

# 각 JOB은 JIG 1개에 배정
def one_jig_rule(m, j):
    return sum(m.x[j, k] for k in m.K) == 1
m.ONE = pyo.Constraint(m.J, rule=one_jig_rule)

# 후보제약: 후보 아니면 x=0
def eligible_rule(m, j, k):
    return m.x[j, k] <= eligible.get((j, k), 0)
m.ELIG = pyo.Constraint(m.J, m.K, rule=eligible_rule)

# 목적함수: 비용 최소화
m.OBJ = pyo.Objective(
    expr=sum(cost[(j, k)] * m.x[j, k] for j in m.J for k in m.K),
    sense=pyo.minimize
)

# 풀이 (HiGHS 예시)
solver = pyo.SolverFactory("highs")
res = solver.solve(m)

for j in m.J:
    for k in m.K:
        if pyo.value(m.x[j, k]) > 0.5:
            print(j, "->", k)
```

이 형태가 돌아가면, 이후 확장은 전형적으로:

- 시간축(동시점유/캘린더) → time-index 추가
- 용량(정반 크기/중량) → 누적 제약 추가
- 선후행/공정 연계 → precedence 제약 추가
- 다목적(비용+지연+우선순위) → 목적함수 확장

으로 진행합니다.

---

## 12. 최적화 관점에서 "확장 가능한" 제약 분해 패턴

현업에서 "정반 후보 제한"은 보통 한 가지 룰만으로 끝나지 않습니다. 확장성을 위해 아래처럼 후보를 다층으로 분해해두면 좋습니다.

### 12.1 제약 계층 구조

1. **Stage 기반 후보**: `Eligible(JIG_CODE | WSTG_CODE)`
2. **Block 물성 기반 후보**: `Eligible(JIG_CODE | BLK_NO Size, Weight)`
3. **Vessel/호선 정책 기반 후보**: `Eligible(JIG_CODE | PROJ_NO)`
4. **최종 조합 기반 후보**: `Eligible(JIG_CODE | PROJ_NO, BLK_NO, WSTG_CODE)` (지금 우리가 만든 Rule)

### 12.2 실무 구현 패턴

보통:
- (1)~(3)에서 후보를 생성한 뒤
- (4) 같은 "예외/특수"를 덮어씌우거나(intersection/override)
- 최종 `TB_ELIGIBLE(job_id, jig_id)`를 만듭니다.

### 12.3 Protégé 확장 방법

`EligibilityRule`을 "RuleType"으로 나누거나(예: `StageEligibilityRule`, `BlockEligibilityRule`), `ruleScope` 같은 속성을 추가해 관리할 수 있습니다.

**예시 확장 구조:**

```turtle
# Stage 기반 규칙
ex:StageEligibilityRule rdfs:subClassOf ex:EligibilityRule .
ex:RULE_STAGE_H2G9 a ex:StageEligibilityRule ;
    ex:ruleStage ex:ST_H2G9 ;
    ex:allowedJig ex:J_01, ex:J_02 .

# Block 무게 기반 규칙
ex:BlockWeightEligibilityRule rdfs:subClassOf ex:EligibilityRule .
ex:RULE_WEIGHT_OVER_10T a ex:BlockWeightEligibilityRule ;
    ex:minWeight 10.0 ;
    ex:allowedJig ex:J_01, ex:J_03 .
```

---

## 13. 다음 단계 확장 제안

위 구조를 그대로 유지하면서 다음 확장이 가능합니다:

### 13.1 Stage=H2G9의 출발/도착 구역 모델링

- `ShopOrArea` 클래스 추가
- `WSTG_CODE`에 `fromArea`, `toArea` 관계 추가
- Stage Code "H2G9"를 "H2 → G9"로 명시적으로 분해

### 13.2 정반 용량/치수 제약을 이용한 자동 후보 생성 로직

- `JIG_CODE`에 `jigMaxTon`, `jigLengthM`, `jigWidthM` 속성 활용
- `BLK_NO`의 `blockWeightTon`, `blockLengthM`, `blockWidthM`과 비교
- SPARQL로 자동 후보 생성 쿼리 작성

### 13.3 시간축(동시 점유 불가)까지 포함한 MoveJob 스키마

- `MoveJob`에 `earliestStart`, `latestFinish`, `duration` 속성 추가
- `JIG_CODE`에 시간대별 점유 상태 모델링
- 최적화 입력 표준 모델(테이블 형태)로 확장

---

## 14. 최적화 입력 테이블 매핑

온톨로지에서 최적화 엔진 입력 테이블로 변환하는 방법:

### 14.1 작업 테이블 (TB_JOBS)

```sparql
PREFIX ex: <http://example.com/shipyard-optim-onto#>

SELECT ?jobId ?vesselId ?blockId ?stageCode ?priority
WHERE {
  ?job a ex:MoveJob .
  ?job ex:jobId ?jobId .
  ?job ex:jobVessel ?v .
  ?v ex:vesselId ?vesselId .
  ?job ex:jobBlock ?b .
  ?b ex:blockId ?blockId .
  ?job ex:jobStage ?st .
  ?st ex:stageCode ?stageCode .
  ?job ex:priority ?priority .
}
```

### 14.2 후보 정반 테이블 (TB_ELIGIBLE)

```sparql
PREFIX ex: <http://example.com/shipyard-optim-onto#>

SELECT ?jobId ?jigId
WHERE {
  ?job a ex:MoveJob .
  ?job ex:jobId ?jobId .
  ?job ex:jobVessel ?v .
  ?job ex:jobBlock ?b .
  ?job ex:jobStage ?st .

  ?rule a ex:EligibilityRule .
  ?rule ex:ruleVessel ?v .
  ?rule ex:ruleBlock ?b .
  ?rule ex:ruleStage ?st .
  ?rule ex:allowedJig ?jig .
  ?jig ex:jigId ?jigId .
}
```

### 14.3 정반 테이블 (TB_JIGS)

```sparql
PREFIX ex: <http://example.com/shipyard-optim-onto#>

SELECT ?jigId ?jigMaxTon ?jigLengthM ?jigWidthM
WHERE {
  ?jig a ex:JIG_CODE .
  ?jig ex:jigId ?jigId .
  OPTIONAL { ?jig ex:jigMaxTon ?jigMaxTon }
  OPTIONAL { ?jig ex:jigLengthM ?jigLengthM }
  OPTIONAL { ?jig ex:jigWidthM ?jigWidthM }
}
```

---

## 15. 실무 체크리스트

### 15.1 Protégé 작업 순서

- [ ] 1. Classes 생성 (PROJ_NO, BLK_NO, WSTG_CODE, JIG_CODE, MoveJob, EligibilityRule)
- [ ] 2. Object Properties 생성 및 Domain/Range 설정
- [ ] 3. Data Properties 생성 및 Domain/Range 설정
- [ ] 4. Restriction(Cardinality) 설정
- [ ] 5. Individuals 생성 (호선, 블록, Stage, 정반, 작업)
- [ ] 6. EligibilityRule Individuals 생성 (제약 규칙)
- [ ] 7. Reasoner로 검증
- [ ] 8. SPARQL 쿼리로 검증
- [ ] 9. Turtle 파일로 내보내기

### 15.2 데이터 검증 포인트

- [ ] 모든 MoveJob이 (vessel, block, stage)를 가지고 있는가?
- [ ] 모든 EligibilityRule이 (vessel, block, stage, allowedJig)를 가지고 있는가?
- [ ] Reasoner가 일관성 검사를 통과하는가?
- [ ] SPARQL로 특정 Job의 후보 정반이 올바르게 나오는가?
- [ ] Python에서 RDF 파싱이 정상적으로 되는가?
- [ ] 최적화 엔진 입력 테이블로 변환이 가능한가?

### 15.3 운영 관점 체크리스트

- [ ] 온톨로지에는 "후보집합(Eligibility)"를 반드시 데이터로 남긴다
  - OWL만으로 "조합별 허용 정반"을 완전 강제하려 하지 말고, 엔진 입력이 되는 `Eligible(JOB, JIG)`를 만들기 좋게 저장
- [ ] 키 구조 고정(Restriction)
  - `MoveJob`는 `jobVessel/jobBlock/jobStage` 각각 exactly 1
  - `BLK_NO`은 `belongsToVessel` exactly 1
- [ ] 버전관리
  - TBox(스키마)는 Git으로 버전관리
  - ABox(운영데이터)는 별도 적재 파이프라인(Python/ETL)로 관리
- [ ] 사내망이면 외부 링크/플러그인 최소화
  - 5.6.8의 원격 link extractor 비활성 옵션 적극 활용

---

## 참고사항

- 이 가이드는 **최적화 엔진과의 연계**를 우선시한 실무 중심 설계입니다.
- OWL의 완전한 추론 기능보다는 **데이터 구조화와 쿼리 효율성**에 중점을 둡니다.
- 필요에 따라 추론 기능을 추가로 확장할 수 있습니다.
- Protégé Desktop은 OWL 2 편집과 시각화/설명 기능, 그리고 **HermiT·Pellet 같은 DL reasoner를 메모리 내로 연동**하는 편집 환경입니다.

---

## 참고 링크

- [Protégé GitHub Releases](https://github.com/protegeproject/protege-distribution/releases)
- [Protégé 공식 사이트](https://protege.stanford.edu/software.php)
- [SPARQL Query 탭 문제 해결](https://stackoverflow.com/questions/44328191/sparql-query-tab-in-protege-doesnt-show-anything)