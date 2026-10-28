# IDEA Lab — isolated sister of improve-swarm
# Tests IDEA-class hypotheses inside a disposable Python venv.
# No network at run time. Host mounts inbox/outbox only.

FROM python:3.12-slim-bookworm

LABEL org.wpai.system="idea-lab" \
      org.wpai.sister_of="improve-swarm" \
      org.wpai.purpose="falsify-or-support IDEA hypotheses in isolation"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    WPAI_IDEA_LAB=1 \
    VIRTUAL_ENV=/opt/idea-lab/venv \
    PATH="/opt/idea-lab/venv/bin:$PATH"

WORKDIR /opt/idea-lab

# Build venv once into the image (reproducible isolation)
RUN python -m venv /opt/idea-lab/venv

COPY requirements.txt /opt/idea-lab/requirements.txt
RUN /opt/idea-lab/venv/bin/pip install --upgrade pip \
    && /opt/idea-lab/venv/bin/pip install -r /opt/idea-lab/requirements.txt

COPY python /opt/idea-lab/python

# Non-root user
RUN useradd --create-home --uid 10001 labuser \
    && mkdir -p /lab/inbox /lab/outbox /lab/work \
    && chown -R labuser:labuser /lab /opt/idea-lab

USER labuser
WORKDIR /lab

# Default: process inbox batch written by host
ENTRYPOINT ["/opt/idea-lab/venv/bin/python", "-m", "python.lab_runner"]
CMD ["--inbox", "/lab/inbox", "--outbox", "/lab/outbox", "--work", "/lab/work"]
