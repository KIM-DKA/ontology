# ontology_env — venv 사용 (Conda 불가 시)

`ontology_env`는 **venv**로 프로젝트 루트에 만들어 두었습니다.  
Conda를 쓰지 않을 때는 아래 순서대로 사용하면 됩니다.

---

## 1. venv 활성화

프로젝트 루트(`ontology/`)에서:

```bash
source ./ontology_env.sh
# 또는
source ./ontology_env/bin/activate
```

프롬프트에 `(ontology_env)` 가 보이면 활성화된 것입니다.

---

## 2. 패키지 설치 (rag-ontology-course 실습용)

활성화한 뒤:

```bash
pip install --upgrade pip
pip install langchain-ollama langchain-openai langchain-community langchain-neo4j faiss-cpu pypdf
```

**`langchain-classic`** 은 Python **3.10 이상**만 지원합니다.  
현재 venv가 **3.9**라면 `langchain-classic` 대신 위 패키지들만 설치하고,  
RAG 체인은 `langchain` + `langchain-community` 등으로 구성하면 됩니다.

---

## 3. Jupyter 커널 등록 (노트북에서 선택용)

```bash
source ./ontology_env.sh
python -m ipykernel install --user --name ontology_env --display-name "Python (ontology_env)"
```

이후 Cursor/VS Code에서 **커널** → **Python (ontology_env)** 를 선택하면 됩니다.

---

## 4. Python 3.10이 필요할 때 (langchain-classic 사용)

회사 PC에 Conda를 쓸 수 없고, **langchain-classic** 을 꼭 써야 한다면  
Python 3.10을 별도로 설치한 뒤 venv를 **3.10으로 다시** 만듭니다.

```bash
# 1) Homebrew로 Python 3.10 설치 (최초 1회)
brew install python@3.10

# 2) 기존 venv 제거 후 3.10으로 새로 생성
cd /Users/dk/Desktop/file/ontology
rm -rf ontology_env
/opt/homebrew/opt/python@3.10/bin/python3.10 -m venv ontology_env

# 3) 활성화 후 패키지 설치
source ./ontology_env.sh
pip install --upgrade pip
pip install langchain-classic langchain-ollama langchain-openai langchain-community langchain-neo4j faiss-cpu pypdf
python -m ipykernel install --user --name ontology_env --display-name "Python (ontology_env)"
```

---

## 확인

```bash
source ./ontology_env.sh
python --version
pip list
```

노트북에서 커널을 **ontology_env**로 선택한 뒤 셀 실행이 되면 정상입니다.
