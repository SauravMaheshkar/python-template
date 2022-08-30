# Use an alpine image
FROM ubuntu:22.04 AS builder

# metainformation
LABEL version="0.0.1"
LABEL maintainer="Saurav Maheshkar"

# Helpers
ARG DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Essential Installs
RUN apt-get update && apt-get install -y --no-install-recommends \
		build-essential \
		gcc \
		gfortran \
		libopenblas-dev \
		python3.10 \
		python3-pip \
		python3.10-dev \
		python3.10-venv \
		&& apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip3.10 install --no-cache-dir --upgrade pip setuptools wheel isort
RUN pip3.10 install --no-cache-dir -r requirements.txt

RUN find /opt/venv/lib/ -follow -type f -name '*.a' -delete \
    && find /opt/venv/lib/ -follow -type f -name '*.pyc' -delete \
    && find /opt/venv/lib/ -follow -type f -name '*.txt' -delete \
    && find /opt/venv/lib/ -follow -type f -name '*.mc' -delete \
    && find /opt/venv/lib/ -follow -type f -name '*.js.map' -delete \
    && find /opt/venv/lib/ -name '*.c' -delete \
    && find /opt/venv/lib/ -name '*.pxd' -delete \
    && find /opt/venv/lib/ -follow -type f -name '*.md' -delete \
    && find /opt/venv/lib/ -follow -type f -name '*.png' -delete \
    && find /opt/venv/lib/ -follow -type f -name '*.jpg' -delete \
    && find /opt/venv/lib/ -follow -type f -name '*.jpeg' -delete \
    && find /opt/venv/lib/ -name '*.pyd' -delete \
    && find /opt/venv/lib/ -name '__pycache__' | xargs rm -r

# Runner Image
FROM ubuntu:22.04 AS runner
RUN apt update && apt install -y --no-install-recommends \
		python3.10 \
		python3-pip \
		python3.10-dev \
		python3.10-venv \
		&& apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN useradd --create-home user
WORKDIR /home/user
USER user

ENTRYPOINT ["/bin/bash"]
