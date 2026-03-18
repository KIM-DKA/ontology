
def get_llm():
    """사내 LLM -> Ollama 순서로 자동 선택"""
    try:
        from langchain_openai import ChatOpenAI
        llm = ChatOpenAI(base_url="http://localhost:11434/v1", model="qwen2.5:32b")
