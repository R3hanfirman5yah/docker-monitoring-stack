# Docker Monitoring Stack

Solusi lengkap untuk monitoring logs server dan jaringan di perusahaan Anda dengan Docker, Portainer, Grafana, Loki, dan Prometheus.

## 📋 Daftar Komponen

| Komponen | Port | Fungsi |
|----------|------|--------|
| **Portainer** | 9000, 9443 | Docker Management Dashboard |
| **Grafana** | 3000 | Visualization & Dashboard |
| **Prometheus** | 9090 | Metrics Collection & Time Series DB |
| **Loki** | 3100 | Log Storage & Aggregation |
| **Promtail** | 9080 | Log Collector |
| **Node Exporter** | 9100 | System Metrics |
| **cAdvisor** | 8080 | Container Monitoring |

## 🚀 Instalasi Cepat

### 1. Install Docker Engine

```bash
chmod +x scripts/install-docker.sh
./scripts/install-docker.sh
```

Setelah instalasi, jalankan:
```bash
newgrp docker
```

### 2. Clone Repository

```bash
git clone https://github.com/yourusername/docker-monitoring-stack.git
cd docker-monitoring-stack
```

### 3. Jalankan Stack

```bash
chmod +x scripts/*.sh
./scripts/start-stack.sh
```

## 🔧 Konfigurasi

### Environment Variables

Edit file `.env` untuk konfigurasi:

```env
TZ=Asia/Jakarta
GF_SECURITY_ADMIN_PASSWORD=password_anda
```

### Prometheus Configuration

Edit `config/prometheus/prometheus.yml` untuk menambahkan target monitoring tambahan:

```yaml
scrape_configs:
  - job_name: 'custom-service'
    static_configs:
      - targets: ['192.168.1.100:9100']
```

### Promtail Configuration

Edit `config/promtail/config.yaml` untuk menambahkan log sources:

```yaml
scrape_configs:
  - job_name: custom-logs
    static_configs:
      - targets:
          - localhost
        labels:
          job: custom
          __path__: /var/log/custom-app/*.log
```

## 📊 Akses Services

| Service | URL | Kredensial |
|---------|-----|----------|
| Portainer | http://localhost:9000 | Setup awal |
| Grafana | http://localhost:3000 | admin / admin123 |
| Prometheus | http://localhost:9090 | - |
| Loki | http://localhost:3100 | - |

## 🔍 Monitoring Logs Server

### Logs yang dikumpulkan otomatis:

1. **System Logs** (`/var/log/syslog`)
   - Event sistem umum
   - Process creation/termination
   - Package updates

2. **Auth Logs** (`/var/log/auth.log`)
   - SSH login attempts
   - Sudo commands
   - Authentication failures

3. **Kernel Logs** (`/var/log/kern.log`)
   - Kernel events
   - Hardware issues
   - Network errors

4. **Docker Logs**
   - Container stdout/stderr
   - Docker daemon events

### Query Logs di Grafana

1. Buka Grafana (http://localhost:3000)
2. Go to **Explore** → Select **Loki** datasource
3. Gunakan LogQL queries:

```logql
# Cari auth failures
{job="auth"} |= "Failed password"

# Cari Docker errors
{job="docker"} |= "error"

# Cari SSH connection attempts
{job="auth"} |= "sshd"

# Cari failed sudo commands
{job="auth"} |= "sudo"
```

## 📈 Monitoring Jaringan & Server

### Metrics yang tersedia:

#### CPU Monitoring
```promql
# CPU usage percentage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Per-core CPU usage
rate(node_cpu_seconds_total{mode="system"}[5m]) * 100
```

#### Memory Monitoring
```promql
# Memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Available memory
node_memory_MemAvailable_bytes / 1024 / 1024 / 1024
```

#### Disk Monitoring
```promql
# Disk usage percentage
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100

# Disk I/O read bytes
rate(node_disk_read_bytes_total[5m])
```

#### Network Monitoring
```promql
# Network bytes received
rate(node_network_receive_bytes_total[5m])

# Network bytes sent
rate(node_network_transmit_bytes_total[5m])

# Network errors
node_network_receive_errs_total + node_network_transmit_errs_total
```

#### Container Monitoring
```promql
# Container CPU usage
rate(container_cpu_usage_seconds_total[5m]) * 100

# Container memory usage
container_memory_usage_bytes / 1024 / 1024
```

## 🛑 Menghentikan Stack

```bash
./scripts/stop-stack.sh
```

Untuk menghapus semua data:

```bash
docker compose down -v
```

## 📝 Logs Commands

```bash
# Lihat semua logs
docker compose logs -f

# Lihat logs service spesifik
docker compose logs -f grafana
docker compose logs -f prometheus
docker compose logs -f loki

# Lihat 100 baris terakhir
docker compose logs --tail 100
```

## 🔒 Security Notes

⚠️ **PENTING untuk Production:**

1. **Ubah default password Grafana:**
   ```bash
   docker compose exec grafana grafana-cli admin reset-admin-password newpassword
   ```

2. **Setup Portainer security:**
   - Ubah password admin saat setup awal
   - Enable 2FA jika tersedia
   - Batasi akses network ke port 9000/9443

3. **Firewall Rules:**
   ```bash
   # Allow hanya dari IP internal
   sudo ufw allow from 192.168.1.0/24 to any port 9000
   sudo ufw allow from 192.168.1.0/24 to any port 3000
   sudo ufw allow from 192.168.1.0/24 to any port 9090
   ```

4. **Backup Data:**
   ```bash
   docker run --rm -v monitoring-stack_grafana_data:/data -v $(pwd):/backup \
     ubuntu tar czf /backup/grafana-backup.tar.gz /data
   ```

## 🤝 Monitoring Multiple Servers

### Setup Node Exporter di Server Lain:

**Server yang akan dimonitor:**
```bash
# Install node-exporter
docker run -d \
  --name node-exporter \
  --network host \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /:/rootfs:ro \
  prom/node-exporter:latest \
  --path.procfs=/host/proc \
  --path.sysfs=/host/sys \
  --collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)
```

**Di Prometheus config (`config/prometheus/prometheus.yml`):**
```yaml
scrape_configs:
  - job_name: 'remote-server-1'
    static_configs:
      - targets: ['192.168.1.100:9100']
        labels:
          instance: 'server-1'
```

## 🐛 Troubleshooting

### Containers tidak start
```bash
# Check logs
docker compose logs

# Rebuild images
docker compose down
docker compose pull
docker compose up -d
```

### Loki tidak menerima logs
```bash
# Check Promtail connectivity
docker compose logs promtail

# Restart Promtail
docker compose restart promtail
```

### Prometheus tidak melihat targets
```bash
# Check Prometheus status
curl http://localhost:9090/api/v1/targets

# Verify config syntax
docker compose exec prometheus promtool check config /etc/prometheus/prometheus.yml
```

## 📚 Dokumentasi Tambahan

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Promtail Documentation](https://grafana.com/docs/loki/latest/clients/promtail/)
- [Portainer Documentation](https://docs.portainer.io/)

## 📞 Support & Kontribusi

Jika ada pertanyaan atau saran, silakan buat issue atau discussion di repository ini.

## 📄 License

MIT License - lihat file LICENSE untuk detail

---

**Last Updated:** 2024
**Maintained by:** R3hanfirman5yah
