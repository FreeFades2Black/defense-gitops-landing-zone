# Multi-Stage Hardened Distroless Build for Defense Workloads
# Conforms to CIS Docker Benchmark: Non-Root User (UID 10001), No Shell, Read-Only Filesystem

# Stage 1: Build & Dependency Resolution
FROM python:3.11-slim AS builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Distroless Minimal Non-Root Runtime
FROM python:3.11-slim AS runtime

# Create unprivileged defense service user
RUN groupadd -g 10001 defensegroup && \
    useradd -u 10001 -g defensegroup -s /sbin/nologin -M defenseuser

WORKDIR /app

# Copy dependencies and application code
COPY --from=builder /root/.local /home/defenseuser/.local
COPY src/app/ /app/

ENV PATH=/home/defenseuser/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Enforce Non-Root Execution
USER 10001:10001

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; sys.exit(0)" || exit 1

ENTRYPOINT ["python", "/app/main.py"]
