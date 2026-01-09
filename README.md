# 온톨로지 실습 풀 커리큘럼

온톨로지(Ontology) 실습을 위한 완전한 가이드입니다. 제조/공정/자산 공통으로 확장 가능한 구조를 기반으로 실습합니다.

## 0단계. 실습 시나리오 고정 (권장)

**주제**: 제조/공정/자산 공통으로 확장 가능한 구조

**엔티티**: 
- Product (제품)
- Process (공정)
- Machine (기계)
- Location (위치)
- Event (이벤트)

## 1단계. 실습용 공개 데이터 다운로드

### 1-1. 기본 구조 이해용 (소규모, 필수)

**W3C 공식 샘플 (RDF/OWL 연습용)**
- [OWL 가이드](https://www.w3.org/TR/owl-guide/)
- [Simple Part-Whole Best Practices](https://www.w3.org/2001/sw/BestPractices/OEP/SimplePartWhole/)

**목적**: OWL 문법, Class/Property 구조 감각 익히기

### 1-2. 실제 데이터 기반 실습 (권장)

#### (A) 제조 공정 데이터 (CSV)

**UCI Machine Learning – Manufacturing Dataset**
- [UCI Archive](https://archive.ics.uci.edu/)
- 추천 데이터:
  - Steel Plates Faults Data Set
  - AI4I 2020 Predictive Maintenance Dataset
- 직접 링크:
  - [AI4I 2020 Predictive Maintenance Dataset](https://archive.ics.uci.edu/dataset/601/ai4i+2020+predictive+maintenance+dataset)

Machine, Process, Failure, Event 모델링에 적합

#### (B) 물류/이벤트 구조 이해용 (대안)

**Open Logistics Data**
- [Open Logistics Data GitHub](https://github.com/opentransport/openlogisticsdata)

## 2단계. 온톨로지 편집기 설치 (필수)

### Protégé (사실상 표준)

- [Protégé 공식 사이트](https://protege.stanford.edu/)

**설치**:
- Desktop Protégé (Windows / macOS / Linux)

OWL 작성, Reasoner 실행, 구조 시각화 전부 가능

## 3단계. 트리플 스토어 설치 (지식그래프 DB)

### 옵션 A (가장 안정적, 추천)

**Apache Jena Fuseki**
- [Fuseki 공식 문서](https://jena.apache.org/documentation/fuseki2/)
- 다운로드:
  - [Apache Jena Binaries](https://archive.apache.org/dist/jena/binaries/)

SPARQL endpoint + 로컬 실행 + 경량

### 옵션 B (GUI 중시)

**GraphDB Free**
- [GraphDB Free](https://www.ontotext.com/products/graphdb/graphdb-free/)

GUI 매우 우수, PoC에 적합

## 4단계. RDF/OWL 실습 자료 (바로 따라하기)

### RDF / OWL 기본 문법
- [OWL 2 Primer](https://www.w3.org/TR/owl2-primer/)
- [Turtle 문법](https://www.w3.org/TR/turtle/)

### CSV → RDF 변환 개념
- [R2RML](https://www.w3.org/TR/r2rml/)
- [CSVW (CSV on the Web)](https://csvw.org/)

## 5단계. CSV → RDF 변환 도구

### OpenRefine + RDF Extension (강력 추천)

- [OpenRefine 공식 사이트](https://openrefine.org/)
- [RDF Extension](https://github.com/OpenRefine/OpenRefine/wiki/RDF-Extension)
- 설치 가이드:
  - [OpenRefine 설치 가이드](https://openrefine.org/docs/manual/installing)

비개발자도 RDF 생성 가능 (실무 체감도 높음)

## 6단계. SPARQL 실습

### SPARQL 공식 문서
- [SPARQL 1.1 Query Language](https://www.w3.org/TR/sparql11-query/)

### 실습 예제
- [Apache Jena SPARQL 튜토리얼](https://jena.apache.org/tutorials/sparql.html)
- [RDF SPARQL Query](https://www.w3.org/TR/rdf-sparql-query/)

## 7단계. Reasoner 실습

### Protégé 내 Reasoner
- HermiT (기본 포함)
- ELK

### 이론 참고
- [Protégé Ontology Reasoning](https://protege.stanford.edu/documentation/ontology-reasoning/)

## 8단계. LLM + 온톨로지 연계 실습

### 자연어 → SPARQL 개념
- [Text-to-SPARQL 연구 논문](https://arxiv.org/abs/2304.05390)
- [Ontop](https://github.com/ontop/ontop)

### 프롬프트 설계 참고
- [Prompting Guide](https://www.promptingguide.ai/)

## 9단계. 전체 실습 흐름 체크리스트

- [ ] 1. CSV 다운로드 ✔
- [ ] 2. Class / Property 설계 ✔
- [ ] 3. Protégé로 OWL 작성 ✔
- [ ] 4. OpenRefine으로 RDF 생성 ✔
- [ ] 5. Fuseki / GraphDB에 적재 ✔
- [ ] 6. SPARQL 질의 ✔
- [ ] 7. Reasoner 결과 확인 ✔
- [ ] 8. LLM 질의 실험 ✔

## 10단계. 실습 후 의사결정 자료로 바로 쓰는 산출물

- "온톨로지가 실제로 필요했던 지점"
- "SQL로는 어려웠던 질의"
- "LLM 단독 대비 오류 감소 사례"
- "조직 내 필요한 역할 정의"

---

## 라이선스

이 프로젝트는 학습 및 실습 목적으로 제공됩니다.

