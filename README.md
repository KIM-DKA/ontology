# 온톨로지 실습 풀 커리큘럼 (URL 포함 · 바로 실행용)

## 0단계. 실습 시나리오 고정 (권장)

* **주제**: 제조 / 공정 / 자산 공통 확장 구조
* **핵심 엔티티**: Product – Process – Machine – Location – Event

* **목표**
    * 온톨로지를 "지식 스키마"로 정의
    * 이후 ML / 최적화로 확장 가능한 구조 확보

## 1단계. 실습용 공개 데이터 다운로드

### 1-1. 기본 구조 이해용 (소규모 · 필수)

**W3C 공식 OWL/RDF 예제**
* [OWL 가이드](https://www.w3.org/TR/owl-guide/)
* [Part–Whole 온톨로지 예제](https://www.w3.org/2001/sw/BestPractices/OEP/SimplePartWhole/)

**목적**
* OWL 문법
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

### OpenRefine + RDF Extension (강력 추천)

* [OpenRefine](https://openrefine.org/)
* [RDF Extension](https://github.com/OpenRefine/OpenRefine/wiki/RDF-Extension)
* [설치 가이드](https://openrefine.org/docs/manual/installing)

**장점**
* 비개발자도 RDF 생성 가능
* 컬럼 → Property 매핑 직관적

## 6단계. SPARQL 실습

### 공식 문서
* [SPARQL 1.1 Query](https://www.w3.org/TR/sparql11-query/)

### 실습 예제
* [Apache Jena SPARQL Tutorial](https://jena.apache.org/tutorials/sparql.html)
* [RDF/SPARQL 공식 설명](https://www.w3.org/TR/rdf-sparql-query/)

## 7단계. Reasoner 실습

### Protégé 내 Reasoner
* HermiT (기본 포함)
* ELK

### 이론 참고
* [Protégé Ontology Reasoning](https://protege.stanford.edu/documentation/ontology-reasoning/)

## 8단계. (선택) LLM + 온톨로지 연계 개념 참고

※ 지금은 참고만, 실습 필수 아님

* [Natural Language → SPARQL 논문](https://arxiv.org/abs/2304.05390)
* [Ontop (Ontology-based Data Access)](https://github.com/ontop/ontop)
* [Prompt 설계 가이드](https://www.promptingguide.ai/)

## 9단계. 전체 실습 흐름 체크리스트

- [ ] 1. 공개 CSV 데이터 다운로드
- [ ] 2. Class / Property 설계
- [ ] 3. Protégé로 OWL 작성
- [ ] 4. OpenRefine으로 RDF 생성
- [ ] 5. Fuseki / GraphDB 적재
- [ ] 6. SPARQL 질의
- [ ] 7. Reasoner 결과 확인
- [ ] 8. (선택) LLM 질의 실험

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
