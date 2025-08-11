#!/bin/bash

# Rocky Linux 초기설정 스크립트
# 각 단계마다 진행여부를 확인합니다

echo "=== Rocky Linux 초기설정 스크립트 ==="
echo "각 단계마다 진행여부를 선택할 수 있습니다."
echo ""

# 함수: 사용자 확인
confirm_step() {
    local step_name="$1"
    local step_desc="$2"
    
    echo ""
    echo "--- $step_name ---"
    echo "$step_desc"
    read -p "이 단계를 실행하시겠습니까? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        echo "건너뜁니다."
        return 1
    fi
}

# 1. 시스템 업데이트 및 기본 패키지 설치
if confirm_step "1. 시스템 업데이트 및 기본 패키지 설치" "시스템을 최신 상태로 업데이트하고 기본 패키지들을 설치합니다."; then
    echo "시스템 업데이트 중..."
    dnf update -y
    echo "기본 패키지 설치 중..."
    dnf install git curl zip -y
    dnf install net-tools curl qemu-guest-agent -y
    dnf install cloud-utils-growpart -y
    dnf clean all
    echo "완료되었습니다."
fi

# 2. sudoers 설정
if confirm_step "2. sudoers 설정" "wheel 그룹 사용자에게 sudo 권한을 부여합니다."; then
    echo "sudoers 설정 중..."
    echo "%wheel ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/10-sudoers
    echo "완료되었습니다."
fi

# 3. 셸 환경 설정
if confirm_step "3. 셸 환경 설정" "bashrc에 유용한 별칭과 환경변수를 추가합니다."; then
    echo "셸 환경 설정 중..."
    echo "alias l='ls -alF'"                >> ~/.bashrc && . ~/.bashrc
    echo "export TIME_STYLE=long-iso"       >> ~/.bashrc && . ~/.bashrc
    echo 'HISTTIMEFORMAT="%Y-%m-%d %H:%M "' >> ~/.bashrc && . ~/.bashrc
    echo "완료되었습니다."
fi

# 4. DNF 설정
if confirm_step "4. DNF 설정" "DNF 패키지 매니저의 성능을 향상시키는 설정을 적용합니다."; then
    echo "DNF 설정 중..."
    echo "fastestmirror=True"  | sudo tee -a /etc/dnf/dnf.conf
    echo "installonly_limit=3" | sudo tee -a /etc/dnf/dnf.conf
    echo "완료되었습니다."
fi

# 5. 언어 및 로케일 설정
if confirm_step "5. 언어 및 로케일 설정" "영어 로케일과 한국 시간대를 설정합니다."; then
    echo "언어 및 로케일 설정 중..."
    localectl set-locale LANG=en_US.UTF-8
    timedatectl set-timezone Asia/Seoul
    echo "완료되었습니다."
fi

# 6. 방화벽 비활성화
if confirm_step "6. 방화벽 비활성화" "firewalld 서비스를 비활성화합니다."; then
    echo "방화벽 비활성화 중..."
    sudo systemctl disable --now firewalld
    echo "완료되었습니다."
fi

# 7. SELinux 비활성화
if confirm_step "7. SELinux 비활성화" "SELinux를 비활성화하고 즉시 적용합니다."; then
    echo "SELinux 비활성화 중..."
    sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
    echo "SELinux 상태 확인:"
    sestatus
    echo "완료되었습니다."
fi

echo ""
echo "=== 모든 설정이 완료되었습니다 ==="
echo "일부 설정은 시스템 재부팅 후 적용됩니다."
read -p "시스템을 재부팅하시겠습니까? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "시스템을 재부팅합니다..."
    sudo reboot
else
    echo "수동으로 재부팅하시면 됩니다."
fi