#!/bin/bash
# 
# ubuntu 22.04 기준
#

# 함수: 사용자에게 계속 진행할지 묻기
ask_continue() {
    local message="$1"
    echo -e "\n=== $message ==="
    read -p "계속 진행하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "설치를 중단합니다."
        exit 1
    fi
}

echo "Ubuntu 초기 설정 스크립트를 시작합니다."
echo "각 단계별로 설치 여부를 확인합니다."

# 1단계: 시스템 업데이트
ask_continue "1단계: 시스템 업데이트 (apt update && apt upgrade)"
apt update && apt upgrade -y
echo "✅ 시스템 업데이트 완료"

# 2단계: shell 환경 설정
ask_continue "2단계: Shell 환경 설정 (alias, export 등)"
echo "alias l='ls -alF'"                >> ~/.bashrc && . ~/.bashrc
echo "export TIME_STYLE=long-iso"       >> ~/.bashrc && . ~/.bashrc
echo 'HISTTIMEFORMAT="%Y-%m-%d %H:%M "' >> ~/.bashrc && . ~/.bashrc
echo "✅ Shell 환경 설정 완료"

# 3단계: vim 에디터 설치
ask_continue "3단계: Vim 에디터 설치"
apt update
apt install vim -y
select-editor
#[ -f /usr/bin/vim.tiny ] && update-alternatives --set editor /usr/bin/vim.tiny
#[ -f /usr/bin/vim.basic ] && update-alternatives --set editor /usr/bin/vim.basic
echo "✅ Vim 에디터 설치 완료"

# 4단계: 추가 패키지 설치
ask_continue "4단계: 추가 패키지 설치 (ping, ftp, telnet, whois, dnsutils, rsync)"
apt install iputils-ping ftp telnet whois dnsutils rsync -y
echo "✅ 추가 패키지 설치 완료"

# 5단계: 타임존 설정
ask_continue "5단계: 타임존 설정 (Asia/Seoul)"
timedatectl set-timezone Asia/Seoul
echo "✅ 타임존 설정 완료"

# 6단계: locale 확인
ask_continue "6단계: 현재 설치된 locale 확인"
locale -a
echo "✅ Locale 확인 완료"

# 7단계: 영어 locale 설정
ask_continue "7단계: 영어 locale 설정 (en_US.UTF-8)"
update-locale lang=en_US.UTF-8  # /etc/default/locale
locale-gen en_US.UTF-8
echo "✅ 영어 locale 설정 완료"

# 8단계: 한국어 locale 설치 및 설정
ask_continue "8단계: 한국어 locale 설치 및 설정"
apt install fonts-nanum language-pack-ko -y
update-locale lang=ko_KR.UTF-8
locale-gen ko_KR.UTF-8
dpkg-reconfigure locales
locale
echo "✅ 한국어 locale 설정 완료"

# 9단계: 환경변수 설정
ask_continue "9단계: 환경변수 설정 (/etc/environment.d/locale.conf)"
echo "LANG=ko_KR.UTF-8" | tee -a /etc/environment.d/locale.conf
echo "LC_ALL=ko_KR.UTF-8" | tee -a /etc/environment/locale.conf

echo "LANG=en_US.UTF-8"   | tee -a /etc/environment.d/locale.conf
echo "LC_ALL=en_US.UTF-8" | tee -a /etc/environment.d/locale.conf
echo "✅ 환경변수 설정 완료"

# 10단계: 최종 locale 확인
ask_continue "10단계: 최종 locale 확인"
locale
echo "✅ 최종 locale 확인 완료"

echo -e "\n🎉 모든 설정이 완료되었습니다!"
echo "시스템을 재부팅하는 것을 권장합니다."