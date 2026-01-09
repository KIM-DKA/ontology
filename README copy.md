
---

## Environment

- **Language**: Python (3.10.12)
- **Database**: PostgreSQL (14.7)
- **Development Tools**: Visual Studio Code, Git, DBeaver, Drawio, Docker, Airflow

## Development Standard

- **Code Style**: PEP 8, SQL Style Guide for Data Intelligence Team
- **Code Review**: GitHub Pull Requests
- **Git Convention**: Git Convention for Data Intelligence Team
- **Branched**: main(maintain), develop(maintain), feature(temporary), hotfix(temporary)
- **Merge Style**:
  - Push `feature` branch to the `develop` branch as `Rebase and Merge`
  - Push `hotfix` branch to the `develop` branch as `Rebase and Merge`
  - Push `develop` branch to the `main` branch as `Merge and Commit`
  
- **CI/CD**: GitHub Actions


## Installation 

- **git repository** 

```
git clone https://github.com/KIM-DKA/ocean_yard.git
```

- **Direcrory** 

```
cd ocean_yard 
```
--- 
## Virtual Enviroment Setting

- conda env list 출력

```
conda env list 
```

- Create virtual Enviroments 
```
conda create -n 'ocean_yard_env' python=3.10.12
```

- activate virtual env 
```
conda activate ocean_yard_env
```

- Export Env yaml Setttings

```
 conda env export> environment.yaml
```

- Import Env yaml Setttings
```
conda env create -f environment.yaml
```

- Project Packages Install 
```
pip install -r requirements.txt
```
--- 

## Create Env Shell Script

프로젝트 PATH는 `senvironment.sh`에 `PYTHONPATH` 저장

- `environment.sh` Shell 스크립트 파일 작성 및 아래 내용 기입

```bash 
#!/bin/zsh
# PYTHONPATH 설정
export PYTHONPATH="/path/to/your_project/src:$PYTHONPATH"
```
- Shell Script 실행권한 부여 

```bash 
chmod +x environment.sh
```
- Shell Script 실행

```bash 
source /path/to/environment.sh
```

--- 
## 가상환경 Activate시 자동으로 PATH 설정 (Optional)

- Create actitavte 
```bash
mkdir -p ~/miniconda3/envs/ocean_yard_env/etc/conda/activate.d
```

- Create env_vars Shell Scripts
```bash 
touch ~/miniconda3/envs/ocean_yard_env/etc/conda/activate.d/env_vars.sh
```

- Insert Your PYTHONPATH in Shell Script 
```bash
#!/bin/sh
export PYTHONPATH="path/to/src:$PYTHONPATH"
```

--- 

## Git Branch Name Convention 

- **Feature Branches** 
    - 새로운 기능 개발을 위한 브랜치
    - feature/[issue번호]-[동사]-[기능명]
    - 예시: feature/1-add-dbconnector

- **Documents Branches**
    - 문서관련 파일 전부
    - docs/[issue번호]-[동사]-[기능명]
    - 예시: docs/2-add-readme-yaml

- **Hotfix Branches** 
    - 디버깅 및 수정 
    - hotfix/[issue이슈번호]-[동사]-[버그명]
    - 예시: hotfix/3-fix-googleapi-key

## Commit Message Convention 

```
git commit -m '[Feat(#9)] Add DBHandler.py'
git commit -m '[Docs(#8)] Add README.md and config.yaml'
```