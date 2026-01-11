FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy docs source
COPY mkdocs.yml .
COPY docs/ docs/

# Build static site
RUN mkdocs build

# Use nginx to serve
FROM nginx:alpine
COPY --from=0 /app/site /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
