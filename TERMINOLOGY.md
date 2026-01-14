# 온톨로지 용어 정리집

## 1. 큰 그림 한 줄

OWL/RDF(시맨틱 웹 표준)로 **"의미 모델(TBox)"**을 먼저 정의하고, 실제 데이터(ABox)를 RDF 트리플로 적재하면, Reasoner가 TBox 근거로 타입/관계 중 일부를 자동 추론한다. 저장은 트리플 DB(트리플 스토어)에 한다.

---

## 2. 핵심 용어 맵 (헷갈리기 쉬운 것만)

### 2.1 RDF vs RDFS vs OWL

| 용어 | 의미 | 역할 |
|------|------|------|
| **RDF** | 데이터를 **트리플(S–P–O)**로 표현하는 데이터 모델 | 기본 데이터 구조 |
| **RDFS** | RDF 위에 얹는 가벼운 스키마/타입 | Class, subClassOf, domain/range 등 기본 스키마 |
| **OWL** | RDFS보다 더 강한 온톨로지 언어 | 제약/정합성/풍부한 추론: cardinality, disjoint, equivalence, property characteristics 등 |

**관계:**
```
RDF (기본 모델)
  └─ RDFS (가벼운 스키마)
      └─ OWL (강한 의미론/제약)
```

### 2.2 TBox vs ABox

| 용어 | 의미 | 예시 |
|------|------|------|
| **TBox** | "추론 근거(스키마)" = 클래스/속성/제약 정의 | `ex:Person a owl:Class .`<br>`ex:hasMother rdfs:domain ex:Person .` |
| **ABox** | "데이터(인스턴스)" = 개체(Individual)와 그 관계 트리플 | `ex:철수 ex:hasMother ex:영희 .` |

**비유:**
- TBox = 데이터베이스 스키마 (CREATE TABLE, ALTER TABLE)
- ABox = 실제 데이터 (INSERT INTO)

### 2.3 Reasoner(리즈너)

**의미:**
- TBox + ABox를 보고 논리적으로 함의되는(triple) 사실을 도출
- "예측/추천"이 아니라 **근거 기반의 논리적 추론**

**예시:**
```
TBox: ex:hasMother rdfs:domain ex:Person .
ABox: ex:철수 ex:hasMother ex:영희 .

Reasoner 추론 결과:
→ ex:철수 rdf:type ex:Person .
→ ex:영희 rdf:type ex:Person .
```

**주요 Reasoner:**
- HermiT (Protégé 기본 포함)
- Pellet
- ELK

---

## 3. RDF vs LPG

### 3.1 차이점

| 구분 | RDF/OWL | LPG (Labeled Property Graph) |
|------|---------|------------------------------|
| **표준** | W3C 표준 | 제품별 구현 (Neo4j, Amazon Neptune 등) |
| **추론** | Reasoner로 자동 추론 | 제품/룰/코드로 구현 필요 |
| **제약** | OWL로 명시적 제약 정의 | 기본값 없음, 별도 구현 필요 |
| **온톨로지** | 표준 온톨로지 표현 | 온톨로지 "같은 역할"은 가능하나 표준 아님 |

### 3.2 RDF/OWL의 핵심 장점

**domain/range가 잘 정의되어 있으면:**
```
TBox: ex:plannedOnProject rdfs:domain ex:BasePlan ;
                          rdfs:range ex:Project .

ABox: ex:BasePlan_001 ex:plannedOnProject ex:Proj_3002 .
```

**Reasoner가 자동으로:**
```
→ ex:BasePlan_001 rdf:type ex:BasePlan .
→ ex:Proj_3002 rdf:type ex:Project .
```

**핵심 포인트:**
- **"데이터 → 근거"**가 아니라 **"근거(TBox) → 데이터(ABox) 적재"**로 생각하는 게 OWL/RDF 방식에 맞다.

---

## 4. "시멘틱 레이어"가 뭔가

### 4.1 정의

**원천 데이터(테이블/파일)**를 그대로 쓰지 않고, **"업무 개념(도메인 언어)"**인 객체/관계/규칙으로 올려서 조직 전체가 같은 의미로 조회/연결/활용하게 만드는 의미 계층.

### 4.2 LLM과의 관계

**시멘틱 레이어 자체를 LLM이 "대체"하기보다는:**

- **시멘틱 레이어(정의/정합성/거버넌스)**: 명시적 모델(OWL/Foundry Ontology 등)로 유지
- **LLM**: 그 위에서 **질의/도구호출/리포팅 인터페이스(오케스트레이터)**로 사용

**패턴:**
```
원천 데이터 (RDB/CSV)
    ↓
시멘틱 레이어 (OWL/RDF 온톨로지)
    ↓
LLM (질의/인터페이스)
```

---

## 5. LPG vs RDF(트리플) — "온톨로지인가?"의 결론

### 5.1 비교

| 구분 | LPG | RDF/OWL |
|------|-----|---------|
| **데이터 모델** | 노드/엣지 + 속성의 그래프 | 트리플(S-P-O) |
| **추론** | 제품/룰/코드로 구현 | Reasoner 추론 생태계 |
| **표준** | 제품별 구현 | W3C 표준 |
| **온톨로지** | 온톨로지 "같은 역할"은 가능하나 표준 아님 | 표준 의미론 기반의 온톨로지 표현 |

### 5.2 결론

**LPG 자체는 OWL 온톨로지 표준이 아니며**, 온톨로지 "같은 역할"은 구현할 수 있으나 표준 추론/제약은 기본값이 아니다.

---

## 6. 파일 "양식"에 대한 결론 (가장 많이 헷갈린 지점)

### 6.1 핵심 이해

**OWL/RDF는 "파일 양식"이 아니라 "표준 모델/언어"**

- 파일로 저장할 때는 **직렬화(문법)**가 필요함
- 대표 직렬화:
  - **Turtle**: `.ttl` (가장 읽기 쉬움, 권장)
  - **RDF/XML**: `.rdf` (관습적으로)
  - **N-Triples**: `.nt`
  - **JSON-LD**: `.jsonld`

**따라서 TTL은 '트리플 구조'가 아니라 '트리플을 적는 문법'임.**

### 6.2 Protégé가 파일을 만들어 주나?

**네.** Protégé에서 온톨로지를 정의하고 저장하면 RDF/OWL 데이터를 파일로 직렬화해 저장해줌.

**실무에서는 보통:**
- **Protégé**: TBox(스키마) 관리
- **파이프라인/ETL**: ABox(신규 호선/블록 등 인스턴스 트리플) 생성·적재

로 분리하는 게 효율적.

---

## 7. 트리플 DB(Triple Store)는 "어떤 스토리지냐"

### 7.1 정의

**"파일 저장소"가 아니라** RDF 트리플을 저장/인덱싱/질의(SPARQL)하는 DB 엔진

### 7.2 사용자 관점 기능

내부 구현은 제품마다 다르지만 사용자 관점에서는:

1. **RDF 적재**
2. **SPARQL 조회**
3. **(옵션) 추론(Reasoning) 지원**

을 제공하는 저장소로 이해하면 충분.

### 7.3 대표 제품

- **Apache Jena Fuseki** (오픈소스, 추천)
- **GraphDB Free** (GUI 우수)
- **Amazon Neptune** (클라우드)
- **Virtuoso** (엔터프라이즈)

---

## 8. domain / range를 제대로 이해하는 핵심

### 8.1 핵심 개념

**domain/range는 "클래스"가 아니라 "속성(Property)에 붙는 타입 규칙"**

- **rdfs:domain**: 이 속성의 **subject**는 어떤 클래스인가
- **rdfs:range**: 이 속성의 **object**는 어떤 클래스/데이터 타입인가

### 8.2 가장 직관적 예시: hasMother

**TBox:**
```turtle
ex:hasMother a owl:ObjectProperty ;
  rdfs:domain ex:Person ;
  rdfs:range  ex:Person .
```

**ABox:**
```turtle
ex:철수 ex:hasMother ex:영희 .
```

**Reasoner 추론:**
```
→ ex:철수 rdf:type ex:Person .
→ ex:영희 rdf:type ex:Person .
```

**즉, 관계 하나만 넣어도 양쪽 타입이 따라온다**가 domain/range의 핵심 효용.

### 8.3 주의사항

**"사람은 포유류다"**는 domain/range가 아니라 **subClassOf**로 표현하는 게 정석.

```turtle
ex:Person rdfs:subClassOf ex:Mammal .
```

---

## 9. RDFS만 쓸 때 vs OWL을 써야 할 때 (가이드)

### 9.1 RDFS로 충분한 경우

- 클래스/관계/도메인·레인지/상속 정도의 **"가벼운 스키마"**
- 목표가 통합/조회 중심이고 **"강한 제약"**이 필요 없을 때

**RDFS만 쓰는 파일 특징:**
- `rdfs:Class`, `rdf:Property`, `rdfs:subClassOf`, `rdfs:domain`, `rdfs:range` 위주

### 9.2 OWL이 유리/필요한 경우

- **카디널리티**(정확히 1개/최소 1개)
- **disjointness** (서로 겹치면 안 됨)
- **equivalence** (동치 클래스)
- **property characteristics** (추이/대칭/함수성)
- **property chain** 등

**OWL을 쓰는 파일 특징:**
- `owl:Class`, `owl:ObjectProperty`, `owl:DatatypeProperty`, `owl:Restriction`, `owl:disjointWith` 등 OWL 어휘가 등장

**특히 제약과 정합성이 최적화 입력 품질에 직접 영향을 줄 때** OWL이 필요하다.

(단, 폐세계 검증/데이터 품질 체크는 SHACL/검증 파이프라인과 조합이 흔함)

---

## 10. 조선 도메인 기준 "최소 TTL" 개념(요약)

### 10.1 Class(개념)

```turtle
ex:Project a owl:Class .           # 호선
ex:Block a owl:Class .             # 블록
ex:WorkingStage a owl:Class .      # 송선
ex:Jig a owl:Class .               # 정반
ex:BasePlan a owl:Class .          # 기준계획
```

### 10.2 Property + domain/range

```turtle
ex:plannedOnProject a owl:ObjectProperty ;
  rdfs:domain ex:BasePlan ;
  rdfs:range ex:Project .

ex:hasBlock a owl:ObjectProperty ;
  rdfs:domain ex:Project ;
  rdfs:range ex:Block .

ex:hasStage a owl:ObjectProperty ;
  rdfs:domain ex:Block ;
  rdfs:range ex:WorkingStage .

ex:assignedToJig a owl:ObjectProperty ;
  rdfs:domain ex:Block ;
  rdfs:range ex:Jig .
```

### 10.3 ABox 설계 원칙

**ABox는 최소 관계 트리플만 넣고, 타입은 domain/range로 Reasoner가 일부 채우게 설계 가능**

```turtle
# 최소한의 데이터만 입력
ex:BasePlan_001 ex:plannedOnProject ex:Proj_3002 .
ex:Proj_3002 ex:hasBlock ex:Block_010 .
ex:Block_010 ex:hasStage ex:Stage_H2G9 .

# Reasoner가 자동으로 타입 추론
→ ex:BasePlan_001 rdf:type ex:BasePlan
→ ex:Proj_3002 rdf:type ex:Project
→ ex:Block_010 rdf:type ex:Block
→ ex:Stage_H2G9 rdf:type ex:WorkingStage
```

---

## 11. RDF/Turtle 문법 치트시트

### 11.1 Prefix(@prefix)와 네임스페이스

#### @prefix 선언

**긴 URI를 짧은 접두어(prefix)로 쓰기 위한 선언**

```turtle
@prefix ex:   <http://example.org/ontology#> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
```

#### 주요 네임스페이스 의미

| Prefix | 의미 | 예시 |
|--------|------|------|
| **ex:** | 내가 정의하는 "내 도메인" 용어 | `ex:Person` = `http://example.org/ontology#Person` |
| **rdf:** | RDF 기본 어휘 | `rdf:type` (매우 중요) |
| **rdfs:** | RDFS(가벼운 스키마) 어휘 | `rdfs:Class`, `rdfs:subClassOf`, `rdfs:domain`, `rdfs:range`, `rdfs:label` |
| **owl:** | OWL(강한 의미론/제약/추론) 어휘 | `owl:Class`, `owl:ObjectProperty`, `owl:Restriction` 등 |
| **xsd:** | 데이터 타입 | `xsd:string`, `xsd:integer`, `xsd:date` 등 |

### 11.2 `a`는 무엇인가? (핵심)

**Turtle에서 `a`는 `rdf:type`의 축약입니다.**

```turtle
ex:Person a owl:Class .
```

**동일한 의미:**
```turtle
ex:Person rdf:type owl:Class .
```

**의미:** "Person은 클래스다."

### 11.3 "한 줄이 트리플" (S–P–O) 구조

**Turtle의 기본 문장은 트리플입니다.**

```
주어(Subject)   술어(Predicate)   목적어(Object) .
```

**예:**
```turtle
ex:철수 ex:hasMother ex:영희 .
```

**구조:**
- Subject: `ex:철수`
- Predicate: `ex:hasMother`
- Object: `ex:영희`

### 11.4 `;`와 `,` 문법 (쓰기 편의)

#### `;` (세미콜론)

**주어가 같을 때, 술어-목적어를 이어 씀**

```turtle
ex:hasMother a owl:ObjectProperty ;
  rdfs:domain ex:Person ;
  rdfs:range  ex:Person .
```

**동일한 의미:**
```turtle
ex:hasMother a owl:ObjectProperty .
ex:hasMother rdfs:domain ex:Person .
ex:hasMother rdfs:range ex:Person .
```

#### `,` (콤마)

**목적어가 여러 개일 때 나열**

```turtle
ex:Person rdfs:subClassOf ex:Mammal, ex:Animal .
```

**동일한 의미:**
```turtle
ex:Person rdfs:subClassOf ex:Mammal .
ex:Person rdfs:subClassOf ex:Animal .
```

### 11.5 자주 쓰는 키워드(속성/클래스/제약)와 쓰임새

#### (1) 클래스 선언

**RDFS 방식(가벼움):**
```turtle
ex:Person a rdfs:Class .
```

**OWL 방식(권장/표준적 온톨로지):**
```turtle
ex:Person a owl:Class .
```

#### (2) 상속/포함: `rdfs:subClassOf`

**의미:** "A는 B의 하위 클래스(모든 A는 B)"

```turtle
ex:Person rdfs:subClassOf ex:Mammal .
```

**추론:** 모든 Person은 Mammal이다.

#### (3) 속성 선언

**RDFS 방식(범용):**
```turtle
ex:hasMother a rdf:Property .
```

**OWL에서 관계 속성(개체→개체):**
```turtle
ex:hasMother a owl:ObjectProperty .
```

**OWL에서 값 속성(개체→리터럴):**
```turtle
ex:birthYear a owl:DatatypeProperty .
```

#### (4) 도메인/레인지: `rdfs:domain`, `rdfs:range`

**속성(Property)에 붙는 타입 규칙**

```turtle
ex:hasMother a owl:ObjectProperty ;
  rdfs:domain ex:Person ;
  rdfs:range  ex:Person .
```

**Reasoner 효과(전형):**
```turtle
# ABox에 이것만 넣으면
ex:철수 ex:hasMother ex:영희 .

# Reasoner가 자동으로 추론
→ ex:철수 rdf:type ex:Person .
→ ex:영희 rdf:type ex:Person .
```

#### (5) 라벨/설명(표시명): `rdfs:label`, `rdfs:comment`

```turtle
ex:Person rdfs:label "사람"@ko ;
          rdfs:comment "사람 클래스 정의"@ko .
```

**`@ko`, `@en`은 언어 태그**

#### (6) OWL에서 자주 쓰는 제약/관계

**inverse 관계:**
```turtle
ex:hasBlock owl:inverseOf ex:belongsToProject .
```

**disjoint(서로 겹치면 안 됨):**
```turtle
ex:Block owl:disjointWith ex:Jig .
```

**equivalent class(동치):**
```turtle
ex:Human owl:equivalentClass ex:Person .
```

**Restriction(제약) 기본 형태:**

"Block은 hasStage를 정확히 1개 가진다" 같은 형태를 OWL로 표현할 때 사용

**대표 어휘:**
- `owl:Restriction`
- `owl:onProperty`
- `owl:someValuesFrom`
- `owl:allValuesFrom`
- `owl:minCardinality`
- `owl:maxCardinality`
- `owl:cardinality`

**예(개념만):**
```turtle
ex:Block rdfs:subClassOf [
  a owl:Restriction ;
  owl:onProperty ex:hasStage ;
  owl:cardinality "1"^^xsd:nonNegativeInteger
] .
```

### 11.6 "RDFS만 쓸 때 vs OWL을 쓸 때" 문법 관찰 포인트

**RDFS만 쓰는 파일:**
- `rdfs:Class`, `rdf:Property`, `rdfs:subClassOf`, `rdfs:domain`, `rdfs:range` 위주

**OWL을 쓰는 파일:**
- `owl:Class`, `owl:ObjectProperty`, `owl:DatatypeProperty`, `owl:Restriction`, `owl:disjointWith` 등 OWL 어휘가 등장

---

## 12. 실무 팁

### 12.1 TBox vs ABox 관리 전략

- **TBox(스키마)**: Protégé로 관리, Git 버전관리
- **ABox(데이터)**: 파이프라인/ETL로 생성·적재, 별도 데이터베이스

### 12.2 파일 형식 선택

- **개발/버전관리**: Turtle (`.ttl`) - 가장 읽기 쉬움
- **프로덕션/대용량**: N-Triples (`.nt`) - 파싱 빠름
- **웹/JSON 연계**: JSON-LD (`.jsonld`)

### 12.3 Reasoner 사용 시점

- **개발 중**: Protégé에서 실시간 검증
- **프로덕션**: 트리플 스토어에 적재 전 사전 검증 또는 스토어 내 추론

---

## 참고사항

- 이 문서는 **온톨로지 초보자를 위한 용어 정리**입니다.
- 실무 적용 시에는 `PRACTICAL_GUIDE.md`를 참고하세요.
- 더 자세한 내용은 W3C 표준 문서를 참조하세요.
