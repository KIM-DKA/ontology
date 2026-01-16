# 단계별 실행 가이드 (Python 우선)

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

## 🐍 2단계. Python 라이브러리 설치

### 할 일 목록:
- [ ] Python 가상환경 생성
- [ ] 필수 라이브러리 설치 (rdflib, owlready2, pandas)
- [ ] 설치 확인

**실행 방법:**
```bash
# Python 가상환경 생성 (선택, 권장)
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# 또는
# venv\Scripts\activate  # Windows

# 필수 라이브러리 설치
pip install rdflib owlready2 pandas

# 설치 확인
python -c "import rdflib; import owlready2; import pandas; print('All libraries installed successfully')"

# requirements.txt 생성
pip freeze > requirements.txt
```

**주요 라이브러리:**
- **rdflib**: RDF/OWL 파싱, SPARQL 쿼리
- **owlready2**: OWL 온톨로지 프로그래밍
- **pandas**: CSV 데이터 처리

---

## 📚 3단계. RDF/OWL 문법 학습 (병행 가능)

### 할 일 목록:
- [ ] OWL 2 Primer 읽기: https://www.w3.org/TR/owl2-primer/
- [ ] Turtle 문법 학습: https://www.w3.org/TR/turtle/
- [ ] TERMINOLOGY.md 참고 (용어 정리)

**간단한 예제 작성해보기:**
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

## 🎯 4단계. Python으로 온톨로지 설계 및 작성

### 할 일 목록:
- [ ] 다운로드한 데이터 분석 (컬럼, 관계 파악)
- [ ] Class 설계 (Machine, Process, Event, Location, Product)
- [ ] Property 설계 (hasProcess, locatedAt, produces 등)
- [ ] Python으로 TBox(스키마) 작성
- [ ] TTL 파일로 저장

**실행 방법 (Python):**

```bash
# 온톨로지 설계 스크립트 작성
cat > script/create_ontology.py << 'EOF'
from rdflib import Graph, Namespace, Literal, URIRef
from rdflib.namespace import RDF, RDFS, OWL

# 그래프 생성
g = Graph()

# 네임스페이스 정의
ex = Namespace("http://example.org/ontology#")
g.bind("ex", ex)

# 클래스 정의
g.add((ex.Machine, RDF.type, OWL.Class))
g.add((ex.Process, RDF.type, OWL.Class))
g.add((ex.Event, RDF.type, OWL.Class))
g.add((ex.Location, RDF.type, OWL.Class))
g.add((ex.Product, RDF.type, OWL.Class))

# 속성 정의
hasProcess = ex.hasProcess
g.add((hasProcess, RDF.type, OWL.ObjectProperty))
g.add((hasProcess, RDFS.domain, ex.Machine))
g.add((hasProcess, RDFS.range, ex.Process))

locatedAt = ex.locatedAt
g.add((locatedAt, RDF.type, OWL.ObjectProperty))
g.add((locatedAt, RDFS.domain, ex.Machine))
g.add((locatedAt, RDFS.range, ex.Location))

produces = ex.produces
g.add((produces, RDF.type, OWL.ObjectProperty))
g.add((produces, RDFS.domain, ex.Process))
g.add((produces, RDFS.range, ex.Product))

# 저장
g.serialize("ontology/manufacturing.ttl", format="turtle")
print("Ontology saved to ontology/manufacturing.ttl")
EOF

# 실행
mkdir -p ontology
python script/create_ontology.py
```

**참고:**
- `PRACTICAL_GUIDE.md`의 클래스/속성 설계 참고
- 조선 도메인: PROJ_NO, BLK_NO, WSTG_CODE, JIG_CODE 등

---

## 🔧 5단계. CSV → RDF 변환

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

# 온톨로지 로드
g = Graph()
g.parse("ontology/manufacturing.ttl", format="turtle")

# 네임스페이스
ex = Namespace("http://example.org/ontology#")

# CSV 읽기
df = pd.read_csv('data/main/ai4i2020/ai4i2020.csv')

# CSV를 RDF로 변환
for idx, row in df.iterrows():
    # 예시: Machine 인스턴스 생성
    machine_uri = URIRef(f"{ex}machine_{row.get('machine_id', idx)}")
    g.add((machine_uri, RDF.type, ex.Machine))
    
    # 속성 추가 (예시)
    if 'temperature' in row:
        g.add((machine_uri, ex.hasTemperature, Literal(row['temperature'])))
    
    # ... 추가 변환 로직

# 저장
g.serialize("data/rdf/manufacturing_data.ttl", format="turtle")
print("RDF data saved to data/rdf/manufacturing_data.ttl")
EOF

# 실행
mkdir -p data/rdf
python script/csv_to_rdf.py
```

---

## 💾 6단계. 트리플 스토어 설치

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

# Fuseki 실행 테스트
cd tools/jena-fuseki
./fuseki-server --update --mem /ds
# 브라우저에서 http://localhost:3030 접속 확인
```

#### 옵션 B: GraphDB Free (GUI 선호 시)
- [ ] GraphDB Free 다운로드
  - 링크: https://www.ontotext.com/products/graphdb/graphdb-free/
- [ ] 설치 및 실행

---

## 💾 7단계. 트리플 스토어에 데이터 적재

### 할 일 목록:
- [ ] Fuseki 서버 실행
- [ ] 데이터셋 생성
- [ ] RDF 파일 업로드 (Python 또는 웹 UI)
- [ ] 데이터 적재 확인

**실행 방법:**

**방법 1: Python으로 업로드 (권장)**
```bash
cat > script/load_to_fuseki.py << 'EOF'
from rdflib import Graph
from SPARQLWrapper import SPARQLWrapper, POST, BASIC

# Fuseki 서버 URL
fuseki_url = "http://localhost:3030/ds"

# RDF 파일 로드
g = Graph()
g.parse("ontology/manufacturing.ttl", format="turtle")
g.parse("data/rdf/manufacturing_data.ttl", format="turtle")

# SPARQL Update로 데이터 적재
sparql = SPARQLWrapper(fuseki_url + "/update")
sparql.setMethod(POST)
sparql.setQuery(f"""
INSERT DATA {{
    {g.serialize(format="nt").decode()}
}}
""")

try:
    sparql.query()
    print("Data loaded successfully!")
except Exception as e:
    print(f"Error: {e}")
EOF

# 실행 (Fuseki 서버가 실행 중이어야 함)
pip install SPARQLWrapper
python script/load_to_fuseki.py
```

**방법 2: 웹 UI로 업로드**
```bash
# Fuseki 서버 실행 (백그라운드)
cd tools/jena-fuseki
./fuseki-server --update --mem /ds &

# 브라우저에서 http://localhost:3030 접속
# 1. 데이터셋 선택 또는 생성
# 2. "Upload files" 클릭
# 3. TTL 파일 선택하여 업로드
```

---

## 🔍 8단계. SPARQL 질의 실습

### 할 일 목록:
- [ ] 기본 SPARQL 쿼리 작성
- [ ] Fuseki 웹 UI에서 쿼리 실행
- [ ] Python으로 SPARQL 쿼리 실행

**실행 방법:**

**SPARQL 쿼리 예제:**
```bash
# SPARQL 쿼리 예제 파일 생성
cat > queries/basic_queries.sparql << 'EOF'
# 모든 Machine 조회
PREFIX ex: <http://example.org/ontology#>

SELECT ?machine WHERE {
    ?machine a ex:Machine .
}

# Machine과 Process 관계 조회
SELECT ?machine ?process WHERE {
    ?machine ex:hasProcess ?process .
}
EOF
```

**Python으로 실행:**
```bash
cat > script/sparql_query.py << 'EOF'
from SPARQLWrapper import SPARQLWrapper, JSON

# Fuseki SPARQL 엔드포인트
sparql = SPARQLWrapper("http://localhost:3030/ds/query")

# 쿼리 실행
query = """
PREFIX ex: <http://example.org/ontology#>

SELECT ?machine WHERE {
    ?machine a ex:Machine .
}
LIMIT 10
"""

sparql.setQuery(query)
sparql.setReturnFormat(JSON)
results = sparql.query().convert()

# 결과 출력
for result in results["results"]["bindings"]:
    print(result["machine"]["value"])
EOF

python script/sparql_query.py
```

**Fuseki 웹 UI에서 실행:**
- 브라우저에서 http://localhost:3030 접속
- "Query" 탭 클릭
- 쿼리 입력 후 실행

---

## 🧠 9단계. Reasoner 실행

### 할 일 목록:
- [ ] Python으로 Reasoner 실행 (rdflib 또는 owlready2)
- [ ] 추론 결과 확인
- [ ] 새로운 관계/클래스 확인

**실행 방법:**

**방법 1: owlready2로 추론 (권장)**
```bash
cat > script/reasoner_test.py << 'EOF'
from owlready2 import *

# 온톨로지 로드
onto = get_ontology("file://ontology/manufacturing.ttl").load()

# Reasoner 실행 (HermiT)
sync_reasoner_pellet(onto, infer_property_values=True, infer_data_property_values=True)

# 추론 결과 확인
print("Inferred classes:")
for cls in onto.classes():
    print(f"  {cls}")

# 추론된 인스턴스 확인
print("\nInferred instances:")
for inst in onto.individuals():
    print(f"  {inst} is a {inst.is_a}")
EOF

python script/reasoner_test.py
```

**방법 2: Fuseki에서 추론 (서버 재시작 필요)**
```bash
# Fuseki를 추론 모드로 실행
cd tools/jena-fuseki
./fuseki-server --update --mem --inference /ds

# 또는 설정 파일에서 추론 엔진 지정
# fuseki-config.ttl 파일 생성 필요
```

**방법 3: Protégé에서 확인 (선택)**
- Protégé에서 온톨로지 열기
- Reasoner → HermiT 선택
- Reasoner → Start reasoner
- 추론된 결과 확인

---

## 🛠️ 부록: Protégé 사용 (선택)

### Protégé가 필요한 경우:
- 시각적으로 온톨로지 구조 확인
- Reasoner 결과를 GUI로 확인
- 온톨로지 검증 및 디버깅

### 설치 및 사용:
- [ ] Protégé 다운로드 및 설치
  - 링크: https://protege.stanford.edu/
- [ ] Python으로 만든 TTL 파일을 Protégé에서 열기
- [ ] 시각화 및 검증

**실행 방법:**
```bash
# macOS의 경우
# 1. 브라우저에서 https://protege.stanford.edu/ 접속
# 2. Download → Desktop Protégé 다운로드
# 3. 다운로드한 .dmg 파일 실행하여 설치
# 4. Applications에서 Protégé 실행
# 5. File → Open → ontology/manufacturing.ttl 선택
```

---

## 📊 10단계. 결과 정리 및 문서화

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
2. **Python 우선**: 2단계 라이브러리 설치 → 4단계 온톨로지 작성
3. **병렬 작업 가능**: 3단계(문법 학습)는 다른 단계와 병행 가능
4. **트리플 스토어**: 6단계 설치 → 7단계 적재 → 8단계 SPARQL

---

## 📝 체크리스트 요약

- [x] 1단계: 데이터 다운로드
- [ ] 2단계: Python 라이브러리 설치
- [ ] 3단계: RDF/OWL 문법 학습 (병행 가능)
- [ ] 4단계: Python으로 온톨로지 설계 및 작성
- [ ] 5단계: CSV → RDF 변환
- [ ] 6단계: 트리플 스토어 설치
- [ ] 7단계: 트리플 스토어 적재
- [ ] 8단계: SPARQL 질의
- [ ] 9단계: Reasoner 실행
- [ ] 10단계: 결과 정리

---

## 💡 팁

- **Python 우선 접근**: Protégé보다 Python이 더 빠르고 자동화 가능
- **TTL 파일 관리**: Git으로 버전관리 가능
- **스크립트 재사용**: CSV → RDF 변환 스크립트는 데이터 업데이트 시 재사용
- **Fuseki 웹 UI**: 데이터 확인 및 디버깅에 유용
