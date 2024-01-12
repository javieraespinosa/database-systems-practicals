FROM python:3-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libmariadb3 libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

CMD [ "streamlit", "hello" ]