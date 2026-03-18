# 조선소 최적화 온톨로지 설계 가이드북

**데이터 소스**: NPS 3BAY 최적화 정의서 기반 데이터  
**목표**: SQL 기반 최적화 입력 데이터를 온톨로지로 전환하여 의미론적 모델링 및 확장 가능한 구조 구축

---

## 1. 데이터 구조 분석

### 1.1 입력 데이터 파일 목록

| 파일명 | 용도 | 핵심 컬럼 |
|--------|------|-----------|
| **TB_BLOCK** | 블록 기본 정보 | PROJ_NO, BLK_NO, WSTG_CODE, BLK_LNTH, BLK_BDTH, PRIORITY |
| **TB_PLAN_INFO** | 계획 메타데이터 | SHOP_CODE, BAY_CODE, WORK_TYPE, PLN_SD, PLN_FD |
| **TB_WORKPLATE** | 정반 정보 | OPTZ_JIG_CODE, JIG_BDTH, JIG_LNTH |
| **TB_WORKPLATE_RELATION** | 정반 관계 | JIG_CODE, OPTZ_JIG_CODE (정반 조합) |
| **TB_PRODUCIBILITY** | 생산 가능성 (핵심) | PROJ_NO, BLK_NO, WSTG_CODE, OPTZ_JIG_CODE, AVAL_INDC |
| **TB_FIXED_PLAN** | 고정 계획 | PROJ_NO, BLK_NO, WSTG_CODE, JIG_CODE, FIX_SD, FIX_FD |
| **TB_ENGINE_PARAMETER** | 엔진 파라미터 | CPLX_MAX_THREAD_LIMT, CPLX_MEM_LIMT, CPLX_SOLV_TIME_LIMT |
| **TB_OBJECTIVE_CONFIG** | 목적함수 설정 | CPLX_OBJT_FMLA_CODE, PRIORITY, APLY_FCTR |
| **TB_CONSTRAINT_CONFIG** | 제약 설정 | CPLX_CNST_CODE, USE_INDC |
| **TB_SERIAL_BLOCK** | 순차 블록 | PROJ_NO, BLK_NO, WSTG_CODE, NEXT_PROJ_NO, NEXT_BLK_NO |
| **TB_PAIR_BLOCK** | 블록 쌍 | PROJ_NO, BLK_NO, COMB_BLK_SEQ |
| **TB_CALENDAR** | 캘린더 | (날짜 정보) |

### 1.2 핵심 개념: PRODUCIBILITY

**PRODUCIBILITY**는 **블록의 속성(호선, 블록, 송선)에 따라 특정 정반에 갈 수 있는지 여부**를 정의합니다.

**데이터 구조:**
- `(PROJ_NO, BLK_NO, WSTG_CODE, OPTZ_JIG_CODE, AVAL_INDC)`
- `AVAL_INDC = 1`: 해당 정반에 배정 가능
- `AVAL_INDC = 0`: 배정 불가

**온톨로지 모델링 전략:**
- 이는 **EligibilityRule** 패턴으로 모델링
- 블록의 물리적 속성(크기, 무게 등)과 정반 속성을 기반으로 자동 추론 가능하도록 설계

---

## 2. 클래스(Classes) 설계

### 2.1 마스터 엔터티 (Master Entities)

#### Project (호선)
- **용도**: 호선 마스터 정보
- **키**: `PROJ_NO`
- **관계**: Block의 상위 개념

#### Block (블록)
- **용도**: 블록 기본 정보
- **키**: `(PROJ_NO, BLK_NO)` 조합
- **특징**: 물리적 속성(길이, 폭), 우선순위, 리드타임 보유
- **중요**: 하나의 블록은 **여러 WorkingStage를 거칠 수 있음** (예: R1G9 → G9G9 → H2G9)

#### WorkingStage (송선)
- **용도**: 공정/이동 단계 (예: R1G9, G9G9, H2G9)
- **키**: `WSTG_CODE`
- **특징**: 출발 구역 → 도착 구역 정보 포함 가능
- **관계**: 하나의 Block은 여러 WorkingStage를 가질 수 있음 (1:N)

#### Jig (정반)
- **용도**: 정반 정보
- **키**: `OPTZ_JIG_CODE` (정반 조합 포함)
- **특징**: 물리적 용량(길이, 폭), 정반 조합 관계

#### Shop (샵)
- **용도**: 샵 정보 (예: NPS)
- **키**: `SHOP_CODE`
- **관계**: Plan의 구성요소

#### Bay (베이)
- **용도**: 베이 정보 (예: 3BAY)
- **키**: `BAY_CODE`
- **관계**: Plan의 구성요소

### 2.2 계획 및 설정 엔터티

#### OptimizationPlan (최적화 계획)
- **용도**: 최적화 실행 단위
- **키**: `OPTZ_PLN_ID`
- **특징**: SHOP, BAY, WORK_TYPE, 기간 정보 포함

#### WorkType (근무 타입)
- **용도**: 근무 타입 분류 (예: "2")
- **키**: `WORK_TYPE`
- **관계**: Plan의 속성

#### Date (날짜)
- **용도**: 작업 날짜 정보 및 캘린더 관리
- **키**: `WORK_DATE` (날짜 값)
- **특징**: 날짜별 작업 가능 여부, 근무 타입, 작업 분류 등
- **관계**: TB_CALENDAR와 연계하여 날짜별 상세 정보 관리

### 2.3 의사결정 및 제약 엔터티

#### MoveJob (배정 작업)
- **용도**: 최적화의 의사결정 단위
- **키**: `(PROJ_NO, BLK_NO, WSTG_CODE)` 조합
- **특징**: 
  - 하나의 작업은 하나의 정반에 배정됨
  - **하나의 Block은 여러 MoveJob을 가질 수 있음** (각 WorkingStage마다 하나씩)
  - 예: Block_2579_183은 MoveJob_2579_183_R1G9, MoveJob_2579_183_G9G9 등을 가질 수 있음

#### EligibilityRule (후보 정반 규칙)
- **용도**: PRODUCIBILITY를 모델링하는 핵심 엔터티
- **구조**: `(PROJ_NO, BLK_NO, WSTG_CODE) → OPTZ_JIG_CODE`
- **특징**: 블록 속성 기반 자동 생성 가능

#### FixedAssignment (고정 배정)
- **용도**: 이미 결정된 배정 (TB_FIXED_PLAN)
- **구조**: `(PROJ_NO, BLK_NO, WSTG_CODE) → JIG_CODE`
- **특징**: 최적화에서 제외되거나 제약으로 사용

#### SerialBlockRelation (순차 블록 관계)
- **용도**: 같은 정반에서 순차 처리해야 하는 블록 관계
- **구조**: `(PROJ_NO, BLK_NO, WSTG_CODE) → (NEXT_PROJ_NO, NEXT_BLK_NO, NEXT_WSTG_CODE)`

### 2.4 설정 엔터티

#### EngineParameter (엔진 파라미터)
- **용도**: 최적화 엔진 설정
- **특징**: Plan별 설정

#### ObjectiveFunction (목적함수)
- **용도**: 목적함수 설정
- **특징**: 다중 목적함수 지원 (우선순위, 가중치)

#### Constraint (제약)
- **용도**: 제약 조건 설정
- **특징**: 활성화/비활성화 가능

---

## 3. 속성(Properties) 설계

### 3.1 Object Properties (관계 속성)

#### 마스터 엔터티 관계
```turtle
ex:belongsToProject    # Block → Project
ex:hasStage            # Block → WorkingStage
ex:belongsToPlan       # Block → OptimizationPlan
ex:hasShop             # OptimizationPlan → Shop
ex:hasBay              # OptimizationPlan → Bay
ex:hasWorkType         # OptimizationPlan → WorkType
```

#### 작업(MoveJob) 관계
```turtle
ex:jobProject          # MoveJob → Project
ex:jobBlock            # MoveJob → Block
ex:jobStage            # MoveJob → WorkingStage
ex:assignedJig         # MoveJob → Jig (결과)
```

#### PRODUCIBILITY 관계 (핵심)
```turtle
ex:ruleProject         # EligibilityRule → Project
ex:ruleBlock           # EligibilityRule → Block
ex:ruleStage           # EligibilityRule → WorkingStage
ex:allowedJig          # EligibilityRule → Jig (여러 개 가능)
```

#### 정반 조합 관계
```turtle
ex:hasJigComponent     # Jig → Jig (정반 조합: OPTZ_JIG_CODE가 여러 JIG_CODE 포함)
ex:componentOf         # Jig → Jig (역관계)
```

#### 고정 배정 관계
```turtle
ex:fixedProject        # FixedAssignment → Project
ex:fixedBlock          # FixedAssignment → Block
ex:fixedStage          # FixedAssignment → WorkingStage
ex:fixedJig            # FixedAssignment → Jig
```

#### 순차 블록 관계
```turtle
ex:hasNextBlock        # Block → Block (순차 처리)
ex:hasPreviousBlock    # Block → Block (역관계)
```

#### 날짜 관계 (Date 클래스)
```turtle
ex:hasExecPlnStartDate    # MoveJob → Date
ex:hasExecPlnFinishDate   # MoveJob → Date
ex:hasIssAvalDate         # MoveJob → Date
ex:hasCrotDedlDate        # MoveJob → Date
ex:hasCrotTolrDate        # MoveJob → Date
ex:hasMaxDlayAvalDate     # MoveJob → Date
ex:hasFixStartDate        # FixedAssignment → Date
ex:hasFixFinishDate       # FixedAssignment → Date
ex:hasPlanStartDate       # OptimizationPlan → Date
ex:hasPlanFinishDate      # OptimizationPlan → Date
```

### 3.2 Data Properties (값 속성)

#### Project
```turtle
ex:projNo              # Project → xsd:string
```

#### Block
```turtle
ex:blkNo               # Block → xsd:string
ex:blockLength         # Block → xsd:decimal
ex:blockBreadth        # Block → xsd:decimal
ex:priority            # Block → xsd:integer
ex:leadTime            # Block → xsd:integer
ex:rotateIndc          # Block → xsd:integer (회전 지시)
ex:combBlkIndc         # Block → xsd:integer (결합 블록 지시)
ex:fixIndc             # Block → xsd:integer (고정 지시)

# 주의: Block의 날짜 정보는 MoveJob별로 다를 수 있음
# (각 WorkingStage마다 다른 날짜를 가질 수 있음)
```

#### Date (날짜 클래스)
```turtle
ex:workDate            # Date → xsd:date (날짜 값)
ex:workType            # Date → xsd:string (근무 타입, TB_CALENDAR의 WORK_TYPE)
ex:workClsf            # Date → xsd:string (작업 분류: A/B/N)
ex:workDateSeq         # Date → xsd:decimal (날짜 순서)
ex:workClsfSeq         # Date → xsd:decimal (작업 분류 순서)
ex:workDateType        # Date → xsd:string (날짜 타입)
ex:isWorkable          # Date → xsd:boolean (작업 가능 여부)
ex:isHoliday           # Date → xsd:boolean (휴일 여부)
```

#### WorkingStage
```turtle
ex:wstgCode            # WorkingStage → xsd:string
ex:fromAreaCode        # WorkingStage → xsd:string (선택)
ex:toAreaCode          # WorkingStage → xsd:string (선택)
```

#### Jig
```turtle
ex:jigCode             # Jig → xsd:string (단일 정반)
ex:optzJigCode         # Jig → xsd:string (정반 조합)
ex:jigBreadth          # Jig → xsd:decimal
ex:jigLength           # Jig → xsd:decimal
ex:jigClsf             # Jig → xsd:string (정반 분류)
```

#### OptimizationPlan
```turtle
ex:optzPlnId           # OptimizationPlan → xsd:string
# 날짜는 Date 클래스와의 관계로 모델링 (planStartDate, planFinishDate는 Object Property)
```

#### Shop / Bay / WorkType
```turtle
ex:shopCode            # Shop → xsd:string
ex:bayCode             # Bay → xsd:string
ex:workType            # WorkType → xsd:string
```

#### EligibilityRule
```turtle
ex:avalIndc            # EligibilityRule → xsd:integer (1: 가능, 0: 불가)
```

#### Date (날짜 클래스) ⭐
```turtle
ex:workDate            # Date → xsd:date (날짜 값, 키 역할)
ex:workType            # Date → xsd:string (근무 타입, TB_CALENDAR의 WORK_TYPE)
ex:workClsf            # Date → xsd:string (작업 분류: A/B/N)
ex:workDateSeq         # Date → xsd:decimal (날짜 순서)
ex:workClsfSeq         # Date → xsd:decimal (작업 분류 순서)
ex:workDateType        # Date → xsd:string (날짜 타입)
ex:isWorkable          # Date → xsd:boolean (작업 가능 여부)
ex:isHoliday           # Date → xsd:boolean (휴일 여부)
```

#### FixedAssignment
```turtle
ex:fixStartDate        # FixedAssignment → xsd:date
ex:fixFinishDate       # FixedAssignment → xsd:date
ex:fixSdWorkClsf      # FixedAssignment → xsd:string
ex:fixFdWorkClsf      # FixedAssignment → xsd:string
```

#### EngineParameter
```turtle
ex:maxThreadLimit      # EngineParameter → xsd:decimal
ex:memLimit            # EngineParameter → xsd:decimal
ex:solvTimeLimit       # EngineParameter → xsd:decimal
ex:mipGapLimit         # EngineParameter → xsd:decimal
```

#### ObjectiveFunction
```turtle
ex:objtFmlaCode        # ObjectiveFunction → xsd:string
ex:objtFmlaDesc        # ObjectiveFunction → xsd:string
ex:useIndc             # ObjectiveFunction → xsd:integer
ex:priority            # ObjectiveFunction → xsd:decimal
ex:aplyFctr            # ObjectiveFunction → xsd:decimal
```

---

## 4. 제약(Restrictions) 설계

### 4.1 Cardinality 제약

#### Block
```turtle
# Block은 정확히 1개의 Project에 속함
Block ⊑ (belongsToProject exactly 1 Project)

# Block은 1개 이상의 WorkingStage를 가짐 (중요: 여러 단계를 거칠 수 있음)
Block ⊑ (hasStage some WorkingStage)
# 정확히 1개가 아니라 여러 개 가능하므로 cardinality 제약 없음

# Block은 정확히 1개의 OptimizationPlan에 속함
Block ⊑ (belongsToPlan exactly 1 OptimizationPlan)
```

**구조 설명:**
- **Project (호선)** → 여러 **Block (블록)** 포함
- **Block (블록)** → 여러 **WorkingStage (송선)** 포함 (1:N)
- **(Block, WorkingStage)** 조합 → **MoveJob (작업)** 생성
- 예: Block_2579_183은 R1G9, G9G9, H2G9 등 여러 단계를 거칠 수 있음

#### MoveJob
```turtle
# MoveJob은 정확히 1개의 Project, Block, WorkingStage를 가짐
MoveJob ⊑ (jobProject exactly 1 Project)
MoveJob ⊑ (jobBlock exactly 1 Block)
MoveJob ⊑ (jobStage exactly 1 WorkingStage)

# MoveJob은 최대 1개의 Jig에 배정됨 (결과)
MoveJob ⊑ (assignedJig max 1 Jig)
```

#### EligibilityRule
```turtle
# EligibilityRule은 정확히 1개의 Project, Block, WorkingStage를 가짐
EligibilityRule ⊑ (ruleProject exactly 1 Project)
EligibilityRule ⊑ (ruleBlock exactly 1 Block)
EligibilityRule ⊑ (ruleStage exactly 1 WorkingStage)

# EligibilityRule은 최소 1개 이상의 allowedJig를 가짐
EligibilityRule ⊑ (allowedJig some Jig)
```

#### OptimizationPlan
```turtle
# OptimizationPlan은 정확히 1개의 Shop, Bay, WorkType을 가짐
OptimizationPlan ⊑ (hasShop exactly 1 Shop)
OptimizationPlan ⊑ (hasBay exactly 1 Bay)
OptimizationPlan ⊑ (hasWorkType exactly 1 WorkType)
```

### 4.2 Disjoint 제약

```turtle
# 서로 다른 클래스는 겹치지 않음
Block owl:disjointWith Jig
Block owl:disjointWith WorkingStage
Project owl:disjointWith Block
```

---

## 5. PRODUCIBILITY 모델링 전략

### 5.1 현재 데이터 구조

**TB_PRODUCIBILITY**는 명시적으로 `(PROJ_NO, BLK_NO, WSTG_CODE, OPTZ_JIG_CODE, AVAL_INDC)` 조합을 저장합니다.

### 5.2 온톨로지 모델링 방법

#### 방법 1: EligibilityRule로 직접 매핑 (현재 데이터 그대로)

```turtle
# TB_PRODUCIBILITY의 각 행을 EligibilityRule로 변환
# AVAL_INDC = 1인 경우만 생성

ex:Rule_2586_193_G9G9_J05D a ex:EligibilityRule ;
    ex:ruleProject ex:Project_2586 ;
    ex:ruleBlock ex:Block_2586_193 ;
    ex:ruleStage ex:Stage_G9G9 ;
    ex:allowedJig ex:Jig_J05D ;
    ex:avalIndc 1 .
```

**장점:**
- 기존 데이터를 그대로 활용
- 구현이 간단

**단점:**
- 규칙이 많아질 수 있음
- 블록 속성 변경 시 수동 업데이트 필요

#### 방법 2: 블록 속성 기반 자동 추론 (확장 가능)

```turtle
# 블록의 물리적 속성과 정반 용량을 기반으로 자동 생성

# 예: 블록 크기 기반 규칙
ex:SizeBasedRule a ex:EligibilityRule ;
    ex:ruleType "SIZE_BASED" ;
    ex:minBlockLength 10.0 ;
    ex:maxBlockLength 20.0 ;
    ex:allowedJig ex:Jig_J05D .

# 예: 호선별 정책 규칙
ex:ProjectPolicy_2586 a ex:EligibilityRule ;
    ex:ruleType "PROJECT_POLICY" ;
    ex:ruleProject ex:Project_2586 ;
    ex:allowedJig ex:Jig_J05D, ex:Jig_J05C .
```

**장점:**
- 확장 가능
- 블록 속성 변경 시 자동 반영 가능
- 규칙 수 감소

**단점:**
- 초기 설계가 복잡
- 추론 엔진 필요

#### 방법 3: 하이브리드 접근 (권장)

**1단계: 명시적 규칙 (TB_PRODUCIBILITY)**
- 기존 데이터를 EligibilityRule로 직접 변환
- 예외/특수 케이스 처리

**2단계: 속성 기반 규칙 (확장)**
- 블록 크기, 무게 기반 자동 생성
- 호선 정책 기반 생성

**3단계: 최종 후보 집합 생성**
- SPARQL로 모든 규칙을 통합하여 최종 Eligible(job, jig) 생성

---

## 6. 클래스 계층 구조 설계

### 6.1 EligibilityRule 확장

```turtle
# 기본 EligibilityRule
ex:EligibilityRule a owl:Class .

# 속성 기반 규칙
ex:SizeBasedEligibilityRule rdfs:subClassOf ex:EligibilityRule .
ex:WeightBasedEligibilityRule rdfs:subClassOf ex:EligibilityRule .

# 정책 기반 규칙
ex:ProjectPolicyEligibilityRule rdfs:subClassOf ex:EligibilityRule .
ex:StageBasedEligibilityRule rdfs:subClassOf ex:EligibilityRule .

# 명시적 규칙 (TB_PRODUCIBILITY)
ex:ExplicitEligibilityRule rdfs:subClassOf ex:EligibilityRule .
```

### 6.2 Block 확장

```turtle
# 기본 Block
ex:Block a owl:Class .

# 특수 블록 타입
ex:FixedBlock rdfs:subClassOf ex:Block .
ex:CombinedBlock rdfs:subClassOf ex:Block .
ex:SerialBlock rdfs:subClassOf ex:Block .
```

---

## 7. 정반 조합 모델링

### 7.1 문제

**TB_WORKPLATE_RELATION**에서 `OPTZ_JIG_CODE`는 여러 `JIG_CODE`의 조합입니다.
- 예: `"J06AJ06BJ06CJ06D"` = J06A + J06B + J06C + J06D

### 7.2 모델링 방법

#### 방법 1: 문자열로 저장 (간단)
```turtle
ex:Jig_J06AJ06BJ06CJ06D a ex:Jig ;
    ex:optzJigCode "J06AJ06BJ06CJ06D" .
```

#### 방법 2: 조합 관계로 모델링 (권장)
```turtle
# 정반 조합
ex:Jig_J06AJ06BJ06CJ06D a ex:Jig ;
    ex:optzJigCode "J06AJ06BJ06CJ06D" ;
    ex:hasJigComponent ex:Jig_J06A ;
    ex:hasJigComponent ex:Jig_J06B ;
    ex:hasJigComponent ex:Jig_J06C ;
    ex:hasJigComponent ex:Jig_J06D .

# 개별 정반
ex:Jig_J06A a ex:Jig ;
    ex:jigCode "J06A" .
```

**장점:**
- SPARQL로 조합 내 개별 정반 조회 가능
- 정반 용량 계산 시 유용

---

## 8. 시간 정보 모델링

### 8.1 Date를 클래스로 모델링하는 이유

**Date를 단순 Data Property가 아닌 클래스로 정의하는 이유:**

1. **날짜별 상세 정보 관리**
   - TB_CALENDAR에 날짜별 WORK_TYPE, WORK_CLSF 정보가 있음
   - 날짜를 클래스로 만들면 이 정보를 속성으로 관리 가능

2. **날짜 간 관계 모델링**
   - 날짜 순서, 날짜 타입 등 관계 정보 표현
   - 작업 가능 여부, 휴일 여부 등 상태 정보

3. **확장 가능성**
   - 향후 날짜별 정반 가용성, 날짜별 작업량 등 추가 가능
   - 날짜를 개체로 취급하여 더 풍부한 추론 가능

### 8.2 Date 클래스 모델링

```turtle
# Date 클래스 정의
ex:Date a owl:Class .

# Date 속성
ex:workDate            # Date → xsd:date (날짜 값, 키 역할)
ex:workType            # Date → xsd:string
ex:workClsf            # Date → xsd:string (A/B/N)
ex:workDateSeq         # Date → xsd:decimal
ex:isWorkable          # Date → xsd:boolean
ex:isHoliday           # Date → xsd:boolean

# Date와 다른 엔터티의 관계
ex:hasStartDate        # MoveJob → Date
ex:hasFinishDate       # MoveJob → Date
ex:hasExecPlnStartDate # MoveJob → Date
ex:hasExecPlnFinishDate # MoveJob → Date
ex:hasIssAvalDate      # MoveJob → Date
ex:hasCrotDedlDate     # MoveJob → Date
```

### 8.3 MoveJob의 날짜 정보

**중요**: 날짜 정보는 Block이 아니라 **MoveJob**에 속합니다.
- 같은 Block이라도 WorkingStage마다 다른 날짜를 가질 수 있음
- 예: Block_2579_183의 R1G9 단계는 20250912~20250918, G9G9 단계는 다른 날짜

```turtle
# MoveJob의 날짜 속성 (Date 클래스와의 관계)
ex:hasExecPlnStartDate    # MoveJob → Date
ex:hasExecPlnFinishDate   # MoveJob → Date
ex:hasIssAvalDate         # MoveJob → Date
ex:hasCrotDedlDate        # MoveJob → Date
ex:hasCrotTolrDate        # MoveJob → Date
ex:hasMaxDlayAvalDate     # MoveJob → Date

# FixedAssignment의 날짜
ex:hasFixStartDate        # FixedAssignment → Date
ex:hasFixFinishDate       # FixedAssignment → Date
```

### 8.4 Date 클래스 사용 예시

```turtle
# 날짜 인스턴스 생성
ex:Date_20250912 a ex:Date ;
    ex:workDate "2025-09-12"^^xsd:date ;
    ex:workType "2" ;
    ex:workClsf "B" ;
    ex:isWorkable true ;
    ex:isHoliday false .

# MoveJob과 Date 연결
ex:Job_2579_183_R1G9 a ex:MoveJob ;
    ex:hasExecPlnStartDate ex:Date_20250912 ;
    ex:hasExecPlnFinishDate ex:Date_20250918 .
```

### 8.5 Date 클래스의 장점

1. **SPARQL 쿼리 효율성**
   ```sparql
   # 특정 날짜에 작업 가능한 MoveJob 조회
   SELECT ?job WHERE {
       ?job a ex:MoveJob .
       ?job ex:hasExecPlnStartDate ?date .
       ?date ex:isWorkable true .
       ?date ex:workDate "2025-09-12"^^xsd:date .
   }
   ```

2. **날짜별 통계 및 분석**
   - 날짜별 작업량 집계
   - 날짜별 정반 가용성 분석

3. **캘린더 정보 통합**
   - TB_CALENDAR 데이터를 Date 인스턴스로 변환
   - 날짜별 상세 정보 관리

---

## 9. 실무 구현 단계

### 9.1 1단계: 기본 구조 (TB_BLOCK 중심)

**목표**: TB_BLOCK 데이터를 온톨로지로 변환

**클래스:**
- Project, Block, WorkingStage, OptimizationPlan, MoveJob

**속성:**
- 기본 물리적 속성 (길이, 폭, 우선순위)

**관계:**
- Block → Project, Block → WorkingStage, Block → Plan

### 9.2 2단계: PRODUCIBILITY 추가

**목표**: TB_PRODUCIBILITY를 EligibilityRule로 변환

**클래스 추가:**
- EligibilityRule, Jig

**관계 추가:**
- EligibilityRule → (Project, Block, WorkingStage, Jig)

**SPARQL 쿼리:**
- MoveJob의 후보 정반 조회

### 9.3 3단계: 정반 정보 추가

**목표**: TB_WORKPLATE, TB_WORKPLATE_RELATION 통합

**클래스 확장:**
- Jig의 조합 관계 모델링

**속성 추가:**
- Jig의 물리적 용량

### 9.4 4단계: 계획 정보 추가

**목표**: TB_PLAN_INFO 통합

**클래스 추가:**
- Shop, Bay, WorkType

**관계 추가:**
- OptimizationPlan → (Shop, Bay, WorkType)

### 9.5 5단계: 고정 계획 및 제약 추가

**목표**: TB_FIXED_PLAN, TB_SERIAL_BLOCK 통합

**클래스 추가:**
- FixedAssignment, SerialBlockRelation

**제약 추가:**
- 고정 배정 제약
- 순차 처리 제약

### 9.6 6단계: 설정 정보 추가

**목표**: TB_ENGINE_PARAMETER, TB_OBJECTIVE_CONFIG, TB_CONSTRAINT_CONFIG 통합

**클래스 추가:**
- EngineParameter, ObjectiveFunction, Constraint

**속성:**
- 각 설정의 파라미터

---

## 10. SPARQL 쿼리 패턴

### 10.1 MoveJob의 후보 정반 조회 (PRODUCIBILITY 활용)

```sparql
PREFIX ex: <http://example.org/shipyard-optim-onto#>

SELECT ?job ?jigCode
WHERE {
    ?job a ex:MoveJob .
    ?job ex:jobProject ?project .
    ?job ex:jobBlock ?block .
    ?job ex:jobStage ?stage .

    ?rule a ex:EligibilityRule .
    ?rule ex:ruleProject ?project .
    ?rule ex:ruleBlock ?block .
    ?rule ex:ruleStage ?stage .
    ?rule ex:allowedJig ?jig .
    ?rule ex:avalIndc 1 .
    
    ?jig ex:optzJigCode ?jigCode .
}
```

### 10.2 블록 크기 기반 후보 정반 자동 생성

```sparql
PREFIX ex: <http://example.org/shipyard-optim-onto#>

SELECT ?block ?jig
WHERE {
    ?block a ex:Block .
    ?block ex:blockLength ?blkLength .
    ?block ex:blockBreadth ?blkBreadth .
    
    ?jig a ex:Jig .
    ?jig ex:jigLength ?jigLength .
    ?jig ex:jigBreadth ?jigBreadth .
    
    FILTER (?blkLength <= ?jigLength)
    FILTER (?blkBreadth <= ?jigBreadth)
}
```

### 10.3 고정 배정 제외한 후보 정반

```sparql
PREFIX ex: <http://example.org/shipyard-optim-onto#>

SELECT ?job ?jigCode
WHERE {
    ?job a ex:MoveJob .
    ?job ex:jobProject ?project .
    ?job ex:jobBlock ?block .
    ?job ex:jobStage ?stage .

    # EligibilityRule로 후보 정반 찾기
    ?rule a ex:EligibilityRule .
    ?rule ex:ruleProject ?project .
    ?rule ex:ruleBlock ?block .
    ?rule ex:ruleStage ?stage .
    ?rule ex:allowedJig ?jig .
    ?rule ex:avalIndc 1 .
    
    # 고정 배정이 아닌 정반만
    MINUS {
        ?fixed a ex:FixedAssignment .
        ?fixed ex:fixedProject ?project .
        ?fixed ex:fixedBlock ?block .
        ?fixed ex:fixedStage ?stage .
        ?fixed ex:fixedJig ?jig .
    }
    
    ?jig ex:optzJigCode ?jigCode .
}
```

---

## 11. 데이터 구조 재정의 (중요)

### 11.1 실제 데이터 구조

**올바른 구조:**
```
Project (호선)
  └─ Block (블록) - 여러 개
      └─ WorkingStage (송선) - 여러 개 (1:N)
          └─ MoveJob (작업) - 각 (Block, WorkingStage) 조합마다 1개
```

**예시:**
- Project_2579
  - Block_2579_183
    - WorkingStage_R1G9 → MoveJob_2579_183_R1G9
    - WorkingStage_G9G9 → MoveJob_2579_183_G9G9 (다른 날짜)
  - Block_2579_193
    - WorkingStage_R1G9 → MoveJob_2579_193_R1G9

### 11.2 모델링 시 주의사항

1. **Block의 WorkingStage는 여러 개 가능**
   - `hasStage`는 cardinality 제약 없음
   - `Block ⊑ (hasStage some WorkingStage)` (최소 1개)

2. **MoveJob은 (Block, WorkingStage) 조합의 고유 식별자**
   - 같은 Block이라도 WorkingStage가 다르면 다른 MoveJob
   - 각 MoveJob은 독립적인 날짜 정보를 가짐

3. **날짜 정보는 MoveJob에 속함**
   - Block이 아니라 MoveJob이 날짜를 가짐
   - 같은 Block의 다른 WorkingStage는 다른 날짜를 가질 수 있음

---

## 12. 확장 가능한 설계 원칙

### 12.1 계층적 규칙 구조

```
1. 기본 규칙 (명시적)
   └─ TB_PRODUCIBILITY → EligibilityRule

2. 속성 기반 규칙 (자동 생성)
   ├─ 크기 기반: Block 크기 vs Jig 용량
   ├─ 무게 기반: Block 무게 vs Jig 최대 무게
   └─ 호선 정책: Project별 정반 정책

3. 예외 규칙 (오버라이드)
   └─ 특수 케이스 처리
```

### 12.2 규칙 우선순위

```turtle
# 규칙 타입별 우선순위
ex:rulePriority        # EligibilityRule → xsd:integer
```

**우선순위 적용 로직:**
1. 예외 규칙 (priority = 1)
2. 명시적 규칙 (priority = 2)
3. 속성 기반 규칙 (priority = 3)

### 12.3 블록 속성 확장

**현재:**
- 길이, 폭, 우선순위, 리드타임

**확장 가능:**
- 무게, 높이, 특수 요구사항, 작업 타입 등

---

## 13. 최적화 엔진 연계 설계

### 13.1 입력 테이블 생성 (SPARQL → 최적화 엔진)

#### TB_JOBS (작업 테이블)
```sparql
SELECT ?jobId ?projNo ?blkNo ?wstgCode ?priority ?length ?breadth
WHERE {
    ?job a ex:MoveJob .
    ?job ex:jobId ?jobId .
    ?job ex:jobProject ?project .
    ?project ex:projNo ?projNo .
    ?job ex:jobBlock ?block .
    ?block ex:blkNo ?blkNo .
    ?job ex:jobStage ?stage .
    ?stage ex:wstgCode ?wstgCode .
    OPTIONAL { ?block ex:priority ?priority }
    OPTIONAL { ?block ex:blockLength ?length }
    OPTIONAL { ?block ex:blockBreadth ?breadth }
}
```

#### TB_ELIGIBLE (후보 정반 테이블) - 핵심
```sparql
SELECT ?jobId ?jigCode
WHERE {
    ?job a ex:MoveJob .
    ?job ex:jobId ?jobId .
    ?job ex:jobProject ?project .
    ?job ex:jobBlock ?block .
    ?job ex:jobStage ?stage .

    ?rule a ex:EligibilityRule .
    ?rule ex:ruleProject ?project .
    ?rule ex:ruleBlock ?block .
    ?rule ex:ruleStage ?stage .
    ?rule ex:allowedJig ?jig .
    ?rule ex:avalIndc 1 .
    
    ?jig ex:optzJigCode ?jigCode .
}
```

#### TB_JIGS (정반 테이블)
```sparql
SELECT ?jigCode ?jigLength ?jigBreadth ?jigClsf
WHERE {
    ?jig a ex:Jig .
    ?jig ex:optzJigCode ?jigCode .
    OPTIONAL { ?jig ex:jigLength ?jigLength }
    OPTIONAL { ?jig ex:jigBreadth ?jigBreadth }
    OPTIONAL { ?jig ex:jigClsf ?jigClsf }
}
```

#### TB_FIXED (고정 배정 테이블)
```sparql
SELECT ?projNo ?blkNo ?wstgCode ?jigCode ?fixStartDate ?fixFinishDate
WHERE {
    ?fixed a ex:FixedAssignment .
    ?fixed ex:fixedProject ?project .
    ?project ex:projNo ?projNo .
    ?fixed ex:fixedBlock ?block .
    ?block ex:blkNo ?blkNo .
    ?fixed ex:fixedStage ?stage .
    ?stage ex:wstgCode ?wstgCode .
    ?fixed ex:fixedJig ?jig .
    ?jig ex:optzJigCode ?jigCode .
    OPTIONAL { ?fixed ex:fixStartDate ?fixStartDate }
    OPTIONAL { ?fixed ex:fixFinishDate ?fixFinishDate }
}
```

---

## 14. 실무 체크리스트

### 14.1 설계 단계

- [ ] 1. 마스터 엔터티 클래스 정의 (Project, Block, WorkingStage, Jig)
- [ ] 2. 계획 엔터티 클래스 정의 (OptimizationPlan, Shop, Bay, WorkType)
- [ ] 3. 의사결정 엔터티 클래스 정의 (MoveJob, EligibilityRule)
- [ ] 4. Object Properties 정의 및 Domain/Range 설정
- [ ] 5. Data Properties 정의 및 Domain/Range 설정
- [ ] 6. Cardinality 제약 설정
- [ ] 7. PRODUCIBILITY 모델링 전략 결정
- [ ] 8. 정반 조합 모델링 방법 결정

### 14.2 구현 단계

- [ ] 1. TB_BLOCK → 온톨로지 변환
- [ ] 2. TB_PRODUCIBILITY → EligibilityRule 변환
- [ ] 3. TB_WORKPLATE → Jig 변환
- [ ] 4. TB_WORKPLATE_RELATION → 정반 조합 관계 변환
- [ ] 5. TB_PLAN_INFO → Plan, Shop, Bay, WorkType 변환
- [ ] 6. TB_FIXED_PLAN → FixedAssignment 변환
- [ ] 7. TB_SERIAL_BLOCK → SerialBlockRelation 변환
- [ ] 8. TB_ENGINE_PARAMETER, TB_OBJECTIVE_CONFIG, TB_CONSTRAINT_CONFIG 변환

### 14.3 검증 단계

- [ ] 1. SPARQL로 MoveJob의 후보 정반 조회 테스트
- [ ] 2. 고정 배정 제외 로직 테스트
- [ ] 3. 순차 블록 제약 테스트
- [ ] 4. 최적화 엔진 입력 테이블 생성 테스트
- [ ] 5. Reasoner로 일관성 검사

---

## 15. 권장 사항

### 15.1 PRODUCIBILITY 모델링

**단기 (즉시 구현):**
- TB_PRODUCIBILITY를 EligibilityRule로 직접 변환
- 명시적 규칙으로 관리

**중기 (확장):**
- 블록 속성 기반 자동 규칙 생성 로직 추가
- SPARQL로 속성 기반 후보 생성

**장기 (최적화):**
- 규칙 우선순위 시스템 구축
- 예외 규칙 오버라이드 메커니즘

### 15.2 데이터 관리 전략

**TBox (스키마):**
- Git으로 버전관리
- 변경 시 문서화

**ABox (데이터):**
- ETL 파이프라인으로 자동 변환
- 최적화 실행 전마다 최신 데이터로 갱신

### 15.3 성능 고려사항

**대용량 데이터:**
- EligibilityRule이 많을 경우 인덱싱 고려
- SPARQL 쿼리 최적화
- 필요시 트리플 스토어 튜닝

---

## 16. 참고 자료

- `PRACTICAL_GUIDE.md`: Protégé 사용법 및 Python 연계
- `TERMINOLOGY.md`: 온톨로지 용어 정리
- `STEP_BY_STEP_GUIDE.md`: 단계별 실행 가이드

---

## 부록: 전체 클래스 계층 구조

```
owl:Thing
├─ ex:Project (호선)
│   └─ 여러 Block 포함
├─ ex:Block (블록)
│   ├─ ex:FixedBlock
│   ├─ ex:CombinedBlock
│   └─ ex:SerialBlock
│   └─ 여러 WorkingStage 포함 (1:N)
├─ ex:WorkingStage (송선)
├─ ex:Jig (정반)
├─ ex:Shop (샵)
├─ ex:Bay (베이)
├─ ex:WorkType (근무 타입)
├─ ex:Date (날짜) ⭐ 추가
├─ ex:OptimizationPlan (최적화 계획)
├─ ex:MoveJob (배정 작업)
│   └─ (Block, WorkingStage) 조합마다 1개
│   └─ 여러 Date 관계 포함
├─ ex:EligibilityRule (후보 정반 규칙)
│   ├─ ex:ExplicitEligibilityRule
│   ├─ ex:SizeBasedEligibilityRule
│   ├─ ex:WeightBasedEligibilityRule
│   ├─ ex:ProjectPolicyEligibilityRule
│   └─ ex:StageBasedEligibilityRule
├─ ex:FixedAssignment (고정 배정)
├─ ex:SerialBlockRelation (순차 블록 관계)
├─ ex:EngineParameter (엔진 파라미터)
├─ ex:ObjectiveFunction (목적함수)
└─ ex:Constraint (제약)
```

### 구조 다이어그램

```
Project (호선)
  │
  ├─ Block_1 (블록)
  │   ├─ WorkingStage_A (송선)
  │   │   └─ MoveJob_1_A (작업) → Date_1, Date_2
  │   ├─ WorkingStage_B (송선)
  │   │   └─ MoveJob_1_B (작업) → Date_3, Date_4
  │   └─ WorkingStage_C (송선)
  │       └─ MoveJob_1_C (작업) → Date_5, Date_6
  │
  └─ Block_2 (블록)
      ├─ WorkingStage_A (송선)
      │   └─ MoveJob_2_A (작업) → Date_7, Date_8
      └─ WorkingStage_D (송선)
          └─ MoveJob_2_D (작업) → Date_9, Date_10
```

**핵심 포인트:**
- 하나의 Block은 여러 WorkingStage를 가짐
- 각 (Block, WorkingStage) 조합마다 MoveJob이 생성됨
- 각 MoveJob은 독립적인 날짜 정보를 가짐
- Date는 클래스로 정의하여 날짜별 상세 정보 관리

---

이 가이드북을 참고하여 단계적으로 온톨로지를 구축하시면 됩니다.
