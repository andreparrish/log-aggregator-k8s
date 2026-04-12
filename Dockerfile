#FROM golang:1.22-alpine AS builder
FROM golang:1.26.2-alpine AS builder

WORKDIR /app

## Copy go.mod and go.sum into the "builder" container. Choose:
##
## Cross-Platform Approach:
##  Pro: Copies go.mod and go.sum in a single Docker layer.
##  Con: Breaks build when go.sum is not created after "go mod tidy"
##   creates go.mod.
#
#COPY go.mod go.sum ./
#
## Unix-y Approach:
## Pro: On Unix-like systems, a nonexistent go.sum does not break the build.
## Con: The go.sum copy requires its own Docker layer.
## 1. Copy go.mod first (always exists)
COPY go.mod ./

# 2. The go.sum file may not exist if there are not external 
# dependencies. Attempt to copy go.sum, but ignore if it doesn't exist
# The '|| true' ensures the build continues even if cp fails
RUN cp go.sum ./ 2>/dev/null || true

# 3. Copy the rest of the source code
COPY . .

# 4. Download dependencies (safe to run even if go.sum is missing)
RUN go mod download

# 5. Build
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o aggregator ./cmd/aggregator

# ============================================
# Stage 2: Run
# ============================================
FROM alpine:3.19

# Install ca-certificates and tzdata
RUN apk --no-cache add ca-certificates tzdata

# Set timezone
ENV TZ=UTC

# Create non-root user
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -D appuser

# Set working directory to /app (standard convention)
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/aggregator .

# Ensure the binary is executable
RUN chmod +x aggregator

# Change ownership to non-root user
RUN chown appuser:appgroup aggregator

# Switch to non-root user
USER appuser

# Default command
CMD ["./aggregator"]
