# Guardyn Quick Reference - Performance Testing

## 🚀 Запуск Performance Тестов

### Рекомендуемый способ (wrapper с Nix)

```bash
./k6-test.sh            # Combined test (auth + messaging)
./k6-test.sh auth       # Auth service only
./k6-test.sh messaging  # Messaging service only
```

**Что делает wrapper**:
- ✅ Автоматически входит в Nix окружение
- ✅ Проверяет доступность k6
- ✅ Настраивает port-forwarding
- ✅ Запускает тесты
- ✅ Очищает ресурсы при выходе

### Альтернатива (manual Nix shell)

```bash
# 1. Войти в Nix окружение
nix --extra-experimental-features 'nix-command flakes' develop

# 2. Запустить тесты
./run-performance-tests.sh            # Combined
./run-performance-tests.sh auth       # Auth only
./run-performance-tests.sh messaging  # Messaging only

# 3. Выйти
exit
```

## 📊 Целевые метрики

- **Virtual Users**: 50 concurrent
- **Duration**: 5 минут
- **P95 Latency**: < 200ms
- **Success Rate**: > 95%

## 🧪 E2E Тесты

```bash
./run-e2e-tests.sh  # Все 8 E2E тестов
```

## 📈 Observability

```bash
# Grafana
kubectl port-forward -n observability svc/kube-prometheus-stack-grafana 3000:80
# Open http://localhost:3000

# Prometheus
kubectl port-forward -n observability svc/prometheus-kube-prometheus-stack-prometheus 9090:9090
# Open http://localhost:9090
```

## 🐛 Troubleshooting

### k6 not found
**Решение**: Используйте `./k6-test.sh` вместо `./run-performance-tests.sh`

### Port already in use
```bash
pkill -f "port-forward"
```

### Services not running
```bash
kubectl get pods -n apps
kubectl logs -n apps -l app=messaging-service
```

## 📚 Документация

- **Testing Guide**: `docs/TESTING_GUIDE.md`
- **Observability Guide**: `docs/OBSERVABILITY_GUIDE.md`
- **Performance README**: `backend/crates/e2e-tests/performance/README.md`
