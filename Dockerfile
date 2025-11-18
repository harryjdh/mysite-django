# 베이스 이미지 선택
FROM python:3.10-slim
# python 출력 버퍼 끄기
ENV PYTHONUNBUFFERED=1
# 작업 디렉토리 설정
WORKDIR /app
# OS 패키지 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*
# requirements 복사후 설치
COPY requirements.txt /app/
# pip 버전 최신화, python 패키지 설치
RUN pip install --upgrade pip && pip install -r requirements.txt
# 전체 소스코드 복사
COPY . /app/
# static 파일 한 곳으로 모으기
RUN python manage.py collectstatic --noinput || true
# 컨테이너 노출 포트
EXPOSE 8000
# 컨테이너 시작시 실행 명령
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
