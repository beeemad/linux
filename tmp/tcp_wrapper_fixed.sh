#!/bin/bash

# TCP Wrapper 설정 스크립트
# 실행 전 root 권한 확인 필요

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "이 스크립트는 root 권한으로 실행해야 합니다."
    echo "sudo $0"
    exit 1
fi

# 백업 생성
echo "기존 설정 파일 백업 중..."
cp /etc/hosts.allow /etc/hosts.allow.backup.$(date +%Y%m%d_%H%M%S)
cp /etc/hosts.deny /etc/hosts.deny.backup.$(date +%Y%m%d_%H%M%S)

# hosts.allow 설정
echo "hosts.allow 설정 중..."
cat > /etc/hosts.allow <<EOF
# 허용할 IP 주소들
ALL : 211.115.202.205
ALL : 211.115.202.240
ALL : 211.115.202.239
EOF

# hosts.deny 설정 (sshd만 차단)
echo "hosts.deny 설정 중..."
cat > /etc/hosts.deny <<EOF
# SSH 접근 차단 (허용된 IP 제외)
sshd : ALL
EOF

echo "TCP Wrapper 설정이 완료되었습니다."
echo "백업 파일:"
echo "  - /etc/hosts.allow.backup.*"
echo "  - /etc/hosts.deny.backup.*"

# 설정 확인
echo ""
echo "현재 설정 확인:"
echo "=== /etc/hosts.allow ==="
cat /etc/hosts.allow
echo ""
echo "=== /etc/hosts.deny ==="
cat /etc/hosts.deny 