# 단계별 실행 가이드

## ✅ 0단계. 완료됨
- [x] 실습 시나리오 고정 (제조/공정/자산 구조)
- [x] 핵심 엔티티 정의: Product – Process – Machine – Location – Event

---

## 📥 1단계. 실습용 공개 데이터 다운로드

### 할 일 목록:

#### 1-1. 기본 구조 이해용 (소규모 · 필수)
- [ ] W3C OWL 가이드 읽기: https://www.w3.org/TR/owl-guide/
- [ ] Part-Whole 온톨로지 예제 확인: https://www.w3.org/2001/sw/BestPractices/OEP/SimplePartWhole/
- [ ] 예제 파일 다운로드 및 구조 파악

**실행 방법:**
```bash
# data 폴더에 예제 저장
mkdir -p data/examples/w3c
# 브라우저에서 예제 다운로드 후 저장
```

#### 1-2. 실제 데이터 다운로드 (권장)
- [ ] AI4I 2020 Predictive Maintenance Dataset 다운로드
  - 링크: https://archive.ics.uci.edu/dataset/601/ai4i+2020+predictive+maintenance+dataset
  - 저장 위치: `data/main/ai4i2020/`
- [ ] 데이터 구조 파악 (CSV 파일 열어서 컬럼 확인)
- [ ] 데이터 샘플 확인 (몇 개 행 읽어보기)

**실행 방법:**
```bash
# 데이터 저장 폴더 생성
mkdir -p data/main/ai4i2020

# Python으로 데이터 확인 (선택)
python -c "import pandas as pd; df = pd.read_csv('data/main/ai4i2020/ai4i2020.csv'); print(df.head()); print(df.columns)"
```

---

## 🛠️ 2단계. 온톨로지 편집기 설치

### 할 일 목록:
- [ ] Protégé 다운로드 및 설치
  - 링크: https://protege.stanford.edu/
  - macOS: .dmg 파일 다운로드 후 설치
- [ ] Protégé 실행 확인
- [ ] 기본 인터페이스 익히기

**실행 방법:**
```bash
# macOS의 경우
# 1. 브라우저에서 https://protege.stanford.edu/ 접속
# 2. Download → Desktop Protégé 다운로드
# 3. 다운로드한 .dmg 파일 실행하여 설치
# 4. Applications에서 Protégé 실행
```

---

## 💾 3단계. 트리플 스토어 설치

### 할 일 목록:

#### 옵션 A: Apache Jena Fuseki (추천)
- [ ] Apache Jena 다운로드
  - 링크: https://archive.apache.org/dist/jena/binaries/
  - 최신 버전 apache-jena-fuseki-*.tar.gz 다운로드
- [ ] 압축 해제 및 설치
- [ ] Fuseki 서버 실행 테스트

**실행 방법:**
```bash
# 다운로드 폴더로 이동
cd ~/Downloads

# 압축 해제 (버전은 다를 수 있음)
tar -xzf apache-jena-fuseki-*.tar.gz

# 프로젝트 폴더로 이동
cd /Users/dk/Desktop/file/ontology

# tools 폴더 생성 및 이동
mkdir -p tools
mv ~/Downloads/apache-jena-fuseki-* tools/jena-fuseki

# Fuseki 실행
cd tools/jena-fuseki
./fuseki-server --update --mem /ds
```

#### 옵션 B: GraphDB Free (GUI 선호 시)
- [ ] GraphDB Free 다운로드
  - 링크: https://www.ontotext.com/products/graphdb/graphdb-free/
- [ ] 설치 및 실행

---

## 📚 4단계. RDF/OWL 문법 학습

### 할 일 목록:
- [ ] OWL 2 Primer 읽기: https://www.w3.org/TR/owl2-primer/
- [ ] Turtle 문법 학습: https://www.w3.org/TR/turtle/
- [ ] 간단한 예제 작성해보기

**실행 방법:**
```bash
# 예제 파일 생성
cat > data/examples/simple_example.ttl << 'EOF'
@prefix ex: <http://example.org/ontology#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .

ex:Machine a rdfs:Class .
ex:Process a rdfs:Class .
ex:hasProcess a rdf:Property ;
    rdfs:domain ex:Machine ;
    rdfs:range ex:Process .
EOF
```

---

## 🔄 5단계. CSV → RDF 변환 도구 설치

### 할 일 목록:

#### 옵션 A: OpenRefine (GUI)
- [ ] OpenRefine 다운로드 및 설치
  - 링크: https://openrefine.org/
- [ ] RDF Extension 설치
  - 링크: https://github.com/OpenRefine/OpenRefine/wiki/RDF-Extension

#### 옵션 B: Python (프로그래밍)
- [ ] Python 라이브러리 설치

**실행 방법:**
```bash
# Python 가상환경 생성 (선택)
python3 -m venv venv
source venv/bin/activate

# 필수 라이브러리 설치
pip install rdflib owlready2 pandas

# requirements.txt 생성
pip freeze > requirements.txt
```

---

## 🎯 6단계. 온톨로지 설계 및 작성

### 할 일 목록:
- [ ] 다운로드한 데이터 분석 (컬럼, 관계 파악)
- [ ] Class 설계 (Machine, Process, Event, Location, Product)
- [ ] Property 설계 (hasProcess, locatedAt, produces 등)
- [ ] Protégé로 OWL 파일 작성
- [ ] 기본 온톨로지 저장 (`ontology/manufacturing.owl`)

**실행 방법:**
1. Protégé 실행
2. File → New → Create a new OWL ontology
3. Classes 탭에서 클래스 추가
4. Object Properties 탭에서 속성 추가
5. File → Save As → `ontology/manufacturing.owl`

---

## 🔧 7단계. CSV → RDF 변환

### 할 일 목록:
- [ ] CSV 데이터를 RDF로 변환
- [ ] 변환된 RDF 파일 저장 (`data/rdf/manufacturing_data.ttl`)

**실행 방법 (Python):**
```bash
# 변환 스크립트 작성
cat > script/csv_to_rdf.py << 'EOF'
import pandas as pd
from rdflib import Graph, Namespace, Literal, URIRef
from rdflib.namespace import RDF, RDFS

# 여기에 변환 로직 작성
# ...
EOF

# 실행
python script/csv_to_rdf.py
```

---

## 💾 8단계. 트리플 스토어에 데이터 적재

### 할 일 목록:
- [ ] Fuseki 서버 실행
- [ ] 데이터셋 생성
- [ ] RDF 파일 업로드
- [ ] 데이터 적재 확인

**실행 방법:**
```bash
# Fuseki 서버 실행 (백그라운드)
cd tools/jena-fuseki
./fuseki-server --update --mem /ds &

# 브라우저에서 http://localhost:3030 접속
# 데이터셋 생성 및 RDF 파일 업로드
```

---

## 🔍 9단계. SPARQL 질의 실습

### 할 일 목록:
- [ ] 기본 SPARQL 쿼리 작성
- [ ] Fuseki 웹 UI에서 쿼리 실행
- [ ] Python으로 SPARQL 쿼리 실행

**실행 방법:**
```bash
# SPARQL 쿼리 예제 파일 생성
cat > queries/basic_queries.sparql << 'EOF'
# 모든 Machine 조회
SELECT ?machine WHERE {
    ?machine a :Machine .
}

# Machine과 Process 관계 조회
SELECT ?machine ?process WHERE {
    ?machine :hasProcess ?process .
}
EOF

# Python으로 실행
python script/sparql_query.py
```

---

## 🧠 10단계. Reasoner 실행

### 할 일 목록:
- [ ] Protégé에서 Reasoner 실행 (HermiT 또는 ELK)
- [ ] 추론 결과 확인
- [ ] 새로운 관계/클래스 확인

**실행 방법:**
1. Protégé에서 온톨로지 열기
2. Reasoner → HermiT 선택
3. Reasoner → Start reasoner
4. 추론된 결과 확인

---

## 🐍 11단계. Python으로 온톨로지 프로그래밍 (선택)

### 할 일 목록:
- [ ] RDFLib로 온톨로지 읽기/쓰기
- [ ] owlready2로 온톨로지 프로그래밍
- [ ] Python 스크립트 작성

**실행 방법:**
```bash
# 예제 스크립트 작성
cat > script/ontology_python.py << 'EOF'
from rdflib import Graph

g = Graph()
g.parse("ontology/manufacturing.owl")
# ... 작업 수행
EOF

python script/ontology_python.py
```

---

## 📊 12단계. 결과 정리 및 문서화

### 할 일 목록:
- [ ] 온톨로지가 실제로 필요했던 지점 정리
- [ ] SQL로는 어려웠던 질의 사례 작성
- [ ] ML/최적화 확장 가능 포인트 정리
- [ ] 필요한 역할 정의 문서화

**실행 방법:**
```bash
# 결과 문서 작성
cat > docs/results.md << 'EOF'
# 실습 결과 정리

## 온톨로지가 실제로 필요했던 지점
...

## SQL로는 어려웠던 질의
...

## ML/최적화 확장 가능 포인트
...
EOF
```

---

## 🚀 다음 단계 추천

1. **지금 바로 시작**: 1단계 데이터 다운로드
2. **병렬 작업 가능**: 2단계(Protégé 설치)와 3단계(Fuseki 설치) 동시 진행
3. **학습 병행**: 4단계(RDF/OWL 문법)는 다른 단계와 병행 가능

---

## 📝 체크리스트 요약

- [x] 1단계: 데이터 다운로드
- [x] 2단계: Protégé 설치
- [x] 3단계: Fuseki 설치
- [ ] 4단계: RDF/OWL 문법 학습
- [ ] 5단계: 변환 도구 설치
- [ ] 6단계: 온톨로지 설계 및 작성
- [ ] 7단계: CSV → RDF 변환
- [ ] 8단계: 트리플 스토어 적재
- [ ] 9단계: SPARQL 질의
- [ ] 10단계: Reasoner 실행
- [ ] 11단계: Python 프로그래밍 (선택)
- [ ] 12단계: 결과 정리

