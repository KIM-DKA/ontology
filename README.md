# 온톨로지 실습 풀 커리큘럼 (URL 포함 · 바로 실행용)

## 0단계. 실습 시나리오 고정 (권장)

* **주제**: 제조 / 공정 / 자산 공통 확장 구조
* **핵심 엔티티**: Product – Process – Machine – Location – Event

* **목표**
    * 온톨로지를 "지식 스키마"로 정의
    * 이후 ML / 최적화로 확장 가능한 구조 확보

## 1단계. 실습용 공개 데이터 다운로드

### 1-1. 기본 구조 이해용 (소규모 · 필수)

**표준 문서 학습 (참고)**
* [OWL 2 가이드 (W3C 표준 문서)](https://www.w3.org/TR/owl-guide/)
* [Part–Whole 온톨로지 Best Practices (W3C 표준 문서)](https://www.w3.org/2001/sw/BestPractices/OEP/SimplePartWhole/)

**실제 예제 온톨로지 파일**
* Protégé 튜토리얼 예제 (Protégé 설치 시 포함)
* [Pizza 온톨로지 (유명한 튜토리얼 예제)](https://github.com/owlcs/pizza-ontology)
* [Wine 온톨로지 예제](http://www.w3.org/TR/owl-guide/wine.rdf)

**목적**
* OWL 문법 학습
* Class / Object Property / Restriction 감각 익히기
* Reasoner 동작 확인

### 1-2. 실제 데이터 기반 실습 (권장)

#### (A) 제조 공정 / 설비 데이터 (CSV)

**UCI Machine Learning Repository**
* 메인: [UCI Archive](https://archive.ics.uci.edu/)

**추천 데이터셋**

1. **AI4I 2020 Predictive Maintenance Dataset (강력 추천)**
* 직접 링크: [AI4I 2020 Predictive Maintenance Dataset](https://archive.ics.uci.edu/dataset/601/ai4i+2020+predictive+maintenance+dataset)
* 포함 개념:
    * Machine
    * Process
    * Failure / Event
    * Sensor Attribute
→ 온톨로지 → ML / 이상탐지 확장에 최적

2. **Steel Plates Faults Dataset (대안)**
* [Steel Plates Faults Dataset](https://archive.ics.uci.edu/ml/datasets/Steel+Plates+Faults)

#### (B) 물류 / 이벤트 구조 이해용 (대안)

**Open Logistics Data**
* GitHub 저장소: [Open Logistics Data](https://github.com/opentransport/openlogisticsdata)
* 활용 목적:
    * Event 중심 온톨로지
    * Shipment / Location / Status 모델링

## 2단계. 온톨로지 편집기 설치 (필수)

### Protégé (사실상 표준)

* 공식 사이트: [Protégé](https://protege.stanford.edu/)
* 다운로드:
    * Desktop Protégé (Windows / macOS / Linux)

**가능 작업**
* OWL 작성
* Reasoner 실행 (HermiT / ELK)
* 클래스 구조 시각화

## 3단계. 트리플 스토어 설치 (지식그래프 DB)

### 옵션 A. Apache Jena Fuseki (가장 안정적 · 추천)

* 문서: [Fuseki 공식 문서](https://jena.apache.org/documentation/fuseki2/)
* 바이너리 다운로드: [Apache Jena Binaries](https://archive.apache.org/dist/jena/binaries/)

**특징**
* SPARQL Endpoint 제공
* 로컬 실행 가능
* Python 연계 용이

### 옵션 B. GraphDB Free (GUI 중시)

* 제품 페이지: [GraphDB Free](https://www.ontotext.com/products/graphdb/graphdb-free/)

**특징**
* GUI 매우 우수
* PoC / 시연에 적합

## 4단계. RDF / OWL 실습 자료 (문법 이해)

### RDF / OWL 기본 문서
* [OWL 2 Primer](https://www.w3.org/TR/owl2-primer/)
* [Turtle 문법](https://www.w3.org/TR/turtle/)

### CSV → RDF 개념
* [R2RML (표준 매핑 개념)](https://www.w3.org/TR/r2rml/)
* [CSV on the Web (CSVW)](https://csvw.org/)

## 5단계. CSV → RDF 변환 도구

### 옵션 A. OpenRefine + RDF Extension (GUI 기반, 강력 추천)

* [OpenRefine](https://openrefine.org/)
* [RDF Extension](https://github.com/OpenRefine/OpenRefine/wiki/RDF-Extension)
* [설치 가이드](https://openrefine.org/docs/manual/installing)

**장점**
* 비개발자도 RDF 생성 가능
* 컬럼 → Property 매핑 직관적

### 옵션 B. Python (프로그래밍 기반)

**주요 라이브러리**
* [RDFLib](https://rdflib.readthedocs.io/) - RDF/OWL 처리, SPARQL 쿼리
* [owlready2](https://owlready2.readthedocs.io/) - OWL 온톨로지 프로그래밍
* [pandas](https://pandas.pydata.org/) - CSV 데이터 처리

**설치**
```bash
pip install rdflib owlready2 pandas
```

**장점**
* 자동화 가능
* ML 파이프라인과 통합 용이
* 대용량 데이터 처리에 적합

## 6단계. SPARQL 실습

### 공식 문서
* [SPARQL 1.1 Query](https://www.w3.org/TR/sparql11-query/)

### 실습 예제
* [Apache Jena SPARQL Tutorial](https://jena.apache.org/tutorials/sparql.html)
* [RDF/SPARQL 공식 설명](https://www.w3.org/TR/rdf-sparql-query/)

### Python으로 SPARQL 실행

**RDFLib 사용**
```python
from rdflib import Graph, SPARQLStore

# 로컬 파일 또는 SPARQL 엔드포인트 연결
g = Graph()
g.parse("ontology.ttl", format="turtle")

# SPARQL 쿼리 실행
query = """
SELECT ?machine ?process WHERE {
    ?machine :hasProcess ?process .
}
"""
results = g.query(query)
for row in results:
    print(row)
```

**SPARQLWrapper 사용 (원격 엔드포인트)**
```bash
pip install SPARQLWrapper
```

```python
from SPARQLWrapper import SPARQLWrapper, JSON

sparql = SPARQLWrapper("http://localhost:3030/ds/query")
sparql.setQuery("SELECT * WHERE { ?s ?p ?o } LIMIT 10")
sparql.setReturnFormat(JSON)
results = sparql.query().convert()
```

## 7단계. Reasoner 실습

### Protégé 내 Reasoner
* HermiT (기본 포함)
* ELK

### 이론 참고
* [Protégé Ontology Reasoning](https://protege.stanford.edu/documentation/ontology-reasoning/)

## 7-1단계. Python으로 온톨로지 프로그래밍 (선택)

### RDFLib로 RDF/OWL 작업

**기본 사용법**
```python
from rdflib import Graph, Namespace, Literal
from rdflib.namespace import RDF, RDFS, OWL

# 네임스페이스 정의
ex = Namespace("http://example.org/ontology#")
g = Graph()

# 클래스 정의
g.add((ex.Machine, RDF.type, OWL.Class))
g.add((ex.Process, RDF.type, OWL.Class))

# 속성 정의
g.add((ex.hasProcess, RDF.type, OWL.ObjectProperty))
g.add((ex.hasProcess, RDFS.domain, ex.Machine))
g.add((ex.hasProcess, RDFS.range, ex.Process))

# 인스턴스 생성
machine1 = ex.machine001
g.add((machine1, RDF.type, ex.Machine))
g.add((machine1, ex.hasProcess, ex.process001))

# 저장
g.serialize("ontology.ttl", format="turtle")
```

### owlready2로 OWL 프로그래밍

**설치**
```bash
pip install owlready2
```

**기본 사용법**
```python
from owlready2 import *

# 온톨로지 생성
onto = get_ontology("http://example.org/ontology")

with onto:
    class Machine(Thing):
        pass
    
    class Process(Thing):
        pass
    
    class hasProcess(Machine >> Process):
        pass

# 인스턴스 생성
machine1 = Machine("machine001")
process1 = Process("process001")
machine1.hasProcess = [process1]

# 저장
onto.save(file="ontology.owl", format="rdfxml")
```

### CSV → RDF 변환 (Python)

```python
import pandas as pd
from rdflib import Graph, Namespace, Literal, URIRef

# CSV 읽기
df = pd.read_csv("data.csv")

# RDF 그래프 생성
g = Graph()
ex = Namespace("http://example.org/")

# CSV 행을 RDF 트리플로 변환
for idx, row in df.iterrows():
    machine_uri = URIRef(f"{ex}machine_{row['machine_id']}")
    g.add((machine_uri, RDF.type, ex.Machine))
    g.add((machine_uri, ex.hasTemperature, Literal(row['temperature'])))
    # ... 추가 매핑

# 저장
g.serialize("output.ttl", format="turtle")
```

### 참고 자료
* [RDFLib 문서](https://rdflib.readthedocs.io/)
* [owlready2 문서](https://owlready2.readthedocs.io/)
* [RDFLib 튜토리얼](https://rdflib.readthedocs.io/en/stable/gettingstarted.html)

## 8단계. (선택) LLM + 온톨로지 연계 개념 참고

※ 지금은 참고만, 실습 필수 아님

* [Natural Language → SPARQL 논문](https://arxiv.org/abs/2304.05390)
* [Ontop (Ontology-based Data Access)](https://github.com/ontop/ontop)
* [Prompt 설계 가이드](https://www.promptingguide.ai/)

## 9단계. 전체 실습 흐름 체크리스트

- [ ] 1. 공개 CSV 데이터 다운로드
- [ ] 2. Class / Property 설계
- [ ] 3. Protégé로 OWL 작성
- [ ] 4. CSV → RDF 변환 (OpenRefine 또는 Python)
- [ ] 5. Fuseki / GraphDB 적재
- [ ] 6. SPARQL 질의 (웹 UI 또는 Python)
- [ ] 7. Reasoner 결과 확인
- [ ] 8. (선택) Python으로 온톨로지 프로그래밍 (RDFLib / owlready2)
- [ ] 9. (선택) LLM 질의 실험

## 10단계. 실습 후 바로 쓰는 산출물

* 온톨로지가 실제로 필요했던 지점
* SQL로는 어려웠던 질의 사례
* ML / 최적화 확장 가능 포인트
* 필요한 역할 정의
    * Domain Expert
    * Ontology Engineer
    * Data / ML Engineer

---

## 라이선스

이 프로젝트는 학습 및 실습 목적으로 제공됩니다.
