#!/usr/bin/env bash

# ==============================================================================
# CYBER_VARVAR: THE B-CORP BREACH - EXTENDED EDITION
# A Cyberpunk Terminal RPG
# Developed by: Senior Linux Developer for VARVARCHEREPAHOVICH
# ==============================================================================

# --- НАСТРОЙКИ ЦВЕТОВ (ANSI ESCAPE CODES) ---
C_RESET='\e[0m'
C_BOLD='\e[1m'
C_DIM='\e[2m'
C_RED='\e[1;31m'
C_GREEN='\e[1;32m'
C_YELLOW='\e[1;33m'
C_BLUE='\e[1;34m'
C_MAGENTA='\e[1;35m'
C_CYAN='\e[1;36m'
C_WHITE='\e[1;37m'
C_BG_RED='\e[41m'
C_BG_GREEN='\e[42m'

# --- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ИГРОКА ---
PLAYER_NAME="User"
LEVEL=1
EXP=0
MAX_EXP=100

HP=100
MAX_HP=100

MONEY=0
INVENTORY="Телефон"
CHAPTER=1
CORE_PASSWORD=""
ATM_HACKS=0
STALKER_NAME="Неизвестный"

# Боевые статы
ATK_BASE=10
DEF_BASE=0
WEAPON_NAME="Кулаки"
ARMOR_NAME="Старая куртка"

# --- ФУНКЦИЯ ПЕЧАТИ ТЕКСТА (ЭФФЕКТ ПЕЧАТАЮЩЕЙ МАШИНКИ) ---
type_text() {
    local text="$1"
    local delay="${2:-0.002}" # Ускорил для больших текстов
    
    echo -e "$text" | while IFS= read -r line; do
        for (( i=0; i<${#line}; i++ )); do
            echo -en "${line:$i:1}"
            sleep "$delay"
        done
        echo ""
    done
}

# --- ВЫВОД СТАТУСА ---
print_status() {
    echo -e "${C_CYAN}==============================================================================${C_RESET}"
    echo -e " ${C_BOLD}ИМЯ:${C_RESET} ${C_YELLOW}$PLAYER_NAME${C_RESET} | ${C_BOLD}УРОВЕНЬ:${C_RESET} ${C_MAGENTA}$LEVEL${C_RESET} (${EXP}/${MAX_EXP} XP) | ${C_BOLD}HP:${C_RESET} ${C_RED}${HP}/${MAX_HP}${C_RESET} | ${C_BOLD}КРЕДИТЫ:${C_RESET} ${C_GREEN}$MONEY ₿${C_RESET}"
    echo -e " ${C_BOLD}ОРУЖИЕ:${C_RESET} $WEAPON_NAME (Урон: $ATK_BASE) | ${C_BOLD}БРОНЯ:${C_RESET} $ARMOR_NAME (Защита: $DEF_BASE)"
    echo -e " ${C_BOLD}ИНВЕНТАРЬ:${C_RESET} ${C_WHITE}${INVENTORY}${C_RESET}"
    echo -e "${C_CYAN}==============================================================================${C_RESET}"
}

# --- ЛЕВЕЛАП ---
check_levelup() {
    if [[ $EXP -ge $MAX_EXP ]]; then
        LEVEL=$((LEVEL + 1))
        EXP=$((EXP - MAX_EXP))
        MAX_EXP=$((MAX_EXP + 50))
        MAX_HP=$((MAX_HP + 20))
        HP=$MAX_HP
        ATK_BASE=$((ATK_BASE + 2))
        echo ""
        type_text "${C_BG_GREEN}${C_WHITE} НОВЫЙ УРОВЕНЬ! ТЕПЕРЬ ТЫ УРОВЕНЬ $LEVEL! ЗДОРОВЬЕ ВОССТАНОВЛЕНО И УВЕЛИЧЕНО. ${C_RESET}"
        sleep 2
    fi
}

# --- СИСТЕМА СОХРАНЕНИЙ ---
save_game() {
    echo ""
    echo -n -e "${C_MAGENTA}Введите номер слота для сохранения (1-5): ${C_RESET}"
    read -r slot
    
    if ! [[ "$slot" =~ ^[1-5]$ ]]; then
        type_text "${C_YELLOW}Неверный слот. Сохраняю в слот 1 по умолчанию.${C_RESET}"
        slot=1
    fi
    
    local target_save="save_${slot}.txt"
    
    # Записываем все переменные
    cat <<EOF > "$target_save"
HP=$HP
MAX_HP=$MAX_HP
LEVEL=$LEVEL
EXP=$EXP
MAX_EXP=$MAX_EXP
MONEY=$MONEY
INVENTORY="$INVENTORY"
CHAPTER=$CHAPTER
CORE_PASSWORD=$CORE_PASSWORD
ATM_HACKS=$ATM_HACKS
ATK_BASE=$ATK_BASE
DEF_BASE=$DEF_BASE
WEAPON_NAME="$WEAPON_NAME"
ARMOR_NAME="$ARMOR_NAME"
EOF
    
    echo ""
    type_text "${C_BG_GREEN}${C_WHITE} [СИСТЕМА] Прогресс успешно сохранен в $target_save ${C_RESET}"
    sleep 1
}

load_game() {
    clear_screen
    echo -e "${C_CYAN}--- ДОСТУПНЫЕ СОХРАНЕНИЯ ---${C_RESET}"
    
    local saves_found=0
    for f in save_*.txt; do
        if [[ -f "$f" ]]; then
            echo -e "${C_YELLOW}- $f${C_RESET}"
            saves_found=1
        fi
    done

    if [[ $saves_found -eq 0 ]]; then
        echo ""
        type_text "${C_BG_RED}${C_WHITE} [ОШИБКА] Файлы сохранений не найдены! ${C_RESET}"
        sleep 2
        main_menu
        return
    fi

    echo ""
    echo -n -e "${C_MAGENTA}Введите номер слота для загрузки: ${C_RESET}"
    read -r slot
    
    local target_save="save_${slot}.txt"

    if [[ -f "$target_save" ]]; then
        source "$target_save"
        type_text "${C_BG_GREEN}${C_WHITE} [СИСТЕМА] Сохранение $target_save загружено! ${C_RESET}"
        sleep 2
        route_chapter
    else
        echo ""
        type_text "${C_BG_RED}${C_WHITE} [ОШИБКА] Файл $target_save не найден! ${C_RESET}"
        sleep 2
        main_menu
    fi
}

# --- ОЧИСТКА ЭКРАНА ---
clear_screen() {
    clear
}

# --- ASCII АРТЫ ---
draw_logo() {
    echo -e "${C_CYAN}"
    cat << "EOF"
  ____ __   __ ____  _____  ____  _     _  ___   ____  _     _  ___   ____  
 / ___|\ \ / /| __ )| ____||  _ \| |   | |/ _ \ |  _ \| |   | |/ _ \ |  _ \ 
| |     \ V / |  _ \|  _|  | |_) | |   | | /_\ \| |_) | |   | | /_\ \| |_) |
| |___   | |  | |_) | |___ |  _ < \ \_/ /|  _  ||  _ < \ \_/ /|  _  ||  _ < 
 \____|  |_|  |____/|_____||_| \_\ \___/ |_| |_||_| \_\ \___/ |_| |_||_| \_\
EOF
    echo -e "${C_MAGENTA}                 >>> EXTENDED EDITION <<<${C_RESET}"
    echo ""
}

draw_city() {
    echo -e "${C_BLUE}"
    cat << "EOF"
         _._._._._._._._._._._._._._._._._
         |___|___|___|___|___|___|___|___|
         |_|___|___|___|___|___|___|___|_|
         |___|___|___|___|___|___|___|___|
         |_|___|___|___|___|___|___|___|_|
          /   _   \             /   _   \
         /   / \   \           /   / \   \
        /___/   \___\         /___/   \___\
EOF
    echo -e "${C_RESET}"
}

draw_gun() {
    echo -e "${C_DIM}"
    cat << "EOF"
      +--^----------,--------,-----,--------^-,
      | |||||||||   `--------'     |          O
      `+---------------------------^----------|
        `\_,-------, _________________________|
          / XXXXXX /`|     /
         / XXXXXX /  `\   /
        / XXXXXX /\______(
       / XXXXXX /
      / XXXXXX /
     (________(
EOF
    echo -e "${C_RESET}"
}

draw_ripperdoc() {
    echo -e "${C_GREEN}"
    cat << "EOF"
          .----.
         /      \
        |  O  O  |
       ==|  _\_  |==
         \  ---  /
          `----`
      [CYBER-CLINIC]
EOF
    echo -e "${C_RESET}"
}

# --- ФЕЙКОВАЯ ЗАГРУЗКА ---
fake_boot() {
    clear_screen
    echo -e "${C_GREEN}Инициализация систем Матрицы...${C_RESET}"
    sleep 0.5
    echo -e "${C_GREEN}Загрузка нейроинтерфейса версии 4.2...${C_RESET}"
    sleep 0.3
    echo -e "${C_CYAN}Подключение скрытых сетей Даркнета... ОК${C_RESET}"
    sleep 0.2
    echo -e "${C_YELLOW}Синхронизация биометрики... ОК${C_RESET}"
    sleep 0.8
    echo -e "${C_GREEN}Все системы в норме. Добро пожаловать, $PLAYER_NAME.${C_RESET}"
    sleep 1.5
}

# --- РОУТИНГ ГЛАВ (ДЛЯ ЗАГРУЗКИ) ---
route_chapter() {
    case $CHAPTER in
        1) location_apartment ;;
        2) location_apartment ;;
        3) location_darknet ;;
        4) location_bcorp_perimeter ;;
        5) location_bcorp_core ;;
        6) endings_hub ;;
        *) main_menu ;;
    esac
}

# ==============================================================================
# БОЕВАЯ СИСТЕМА
# ==============================================================================
combat_sequence() {
    local enemy_name="$1"
    local enemy_max_hp="$2"
    local enemy_hp="$2"
    local enemy_atk="$3"
    local enemy_xp="$4"
    local enemy_money="$5"
    
    clear_screen
    echo -e "${C_BG_RED}${C_WHITE} БОЙ НАЧАЛСЯ! ВРАГ: $enemy_name ${C_RESET}"
    sleep 1
    
    while [[ $HP -gt 0 && $enemy_hp -gt 0 ]]; do
        echo -e "${C_CYAN}--------------------------------------------------${C_RESET}"
        echo -e "${C_GREEN}Твое здоровье: $HP/$MAX_HP${C_RESET} | ${C_RED}Здоровье врага ($enemy_name): $enemy_hp/$enemy_max_hp${C_RESET}"
        echo -e "${C_CYAN}--------------------------------------------------${C_RESET}"
        echo "1) Атаковать ($WEAPON_NAME)"
        echo "2) Использовать Стимулятор (Восстановит 50 HP)"
        echo "3) Сбежать (Шанс 50%)"
        echo -n -e "${C_MAGENTA}Твой ход> ${C_RESET}"
        read -r combat_choice
        
        case $combat_choice in
            1)
                # Расчет урона игрока
                local dmg=$(( ATK_BASE + RANDOM % 5 ))
                enemy_hp=$((enemy_hp - dmg))
                type_text "${C_YELLOW}Ты бьешь врага! Нанесено $dmg урона.${C_RESET}"
                ;;
            2)
                if [[ "$INVENTORY" == *"Стимулятор"* ]]; then
                    HP=$((HP + 50))
                    if [[ $HP -gt $MAX_HP ]]; then HP=$MAX_HP; fi
                    INVENTORY="${INVENTORY/Стимулятор/}" # Удаляем 1 стимулятор (очень простая реализация)
                    INVENTORY=$(echo "$INVENTORY" | sed 's/,,/,/g' | sed 's/^,//' | sed 's/,$//')
                    if [[ -z "$INVENTORY" ]]; then INVENTORY="Пусто"; fi
                    type_text "${C_GREEN}Ты вколол стимулятор. HP восстановлено!${C_RESET}"
                else
                    type_text "${C_RED}У тебя нет Стимуляторов! Ты теряешь ход!${C_RESET}"
                fi
                ;;
            3)
                local escape_chance=$(( RANDOM % 100 ))
                if [[ $escape_chance -gt 50 ]]; then
                    type_text "${C_CYAN}Тебе удалось скрыться в переулках!${C_RESET}"
                    sleep 2
                    return 2 # Код побега
                else
                    type_text "${C_RED}Враг перекрыл путь к отступлению!${C_RESET}"
                fi
                ;;
            *)
                type_text "${C_RED}Мимо кнопок! Ты теряешь ход!${C_RESET}"
                ;;
        esac
        
        sleep 1
        
        # Ход врага
        if [[ $enemy_hp -gt 0 ]]; then
            local e_dmg=$(( enemy_atk + RANDOM % 4 - DEF_BASE ))
            if [[ $e_dmg -le 0 ]]; then e_dmg=1; fi # Минимальный урон
            HP=$((HP - e_dmg))
            type_text "${C_RED}$enemy_name атакует тебя! Получено $e_dmg урона.${C_RESET}"
            sleep 1
        fi
    done
    
    if [[ $HP -le 0 ]]; then
        game_over "Убит в уличной драке врагом: $enemy_name."
        return 0
    else
        type_text "${C_BG_GREEN}${C_WHITE} ПОБЕДА! Враг $enemy_name повержен. ${C_RESET}"
        type_text "${C_GREEN}Получено: $enemy_xp EXP и $enemy_money ₿${C_RESET}"
        EXP=$((EXP + enemy_xp))
        MONEY=$((MONEY + enemy_money))
        check_levelup
        sleep 2
        return 1 # Код победы
    fi
}

# ==============================================================================
# ИГРОВЫЕ ЛОКАЦИИ
# ==============================================================================

# --- КВАРТИРА ---
location_apartment() {
    clear_screen
    print_status

    type_text "${C_DIM}Твоя безопасная зона. Здесь работает терминал и можно восстановить силы.${C_RESET}"

    if [[ "$INVENTORY" != *"Zero_Contact"* ]]; then
        type_text "${C_CYAN}[ВХОДЯЩИЙ СИГНАЛ]${C_RESET}"
        type_text "${C_YELLOW}Zero:${C_RESET} ${C_WHITE}Просыпайся, $PLAYER_NAME. Нам нужно взломать B-Corp.${C_RESET}"
        type_text "${C_YELLOW}Zero:${C_RESET} ${C_WHITE}Для начала нужны кредиты. Иди в Трущобы или ломани банкомат внизу.${C_RESET}"
        INVENTORY="Zero_Contact"
        echo ""
    fi

    while true; do
        echo -e "${C_GREEN}Куда отправимся?${C_RESET}"
        echo "1) Сесть за терминал (Взлом банкомата, осталось: $((3 - ${ATM_HACKS:-0})) )"
        echo "2) Выйти в Трущобы (Фиксер, Драки, Улица)"
        echo "3) Открыть браузер Даркнета"
        echo "4) Лечь спать (Восстановить HP)"
        echo "5) Сохранить игру"
        echo "6) В Главное меню"
        echo -n -e "${C_MAGENTA}root@home:~# ${C_RESET}"
        read -r choice

        case $choice in
            1)
                if [[ ${ATM_HACKS:-0} -ge 3 ]]; then
                    type_text "${C_YELLOW}Банкомат отключен от сети. Больше отсюда не вытащить.${C_RESET}"
                else
                    mini_game_atm
                fi
                ;;
            2)
                location_slums
                return
                ;;
            3)
                location_darknet
                return
                ;;
            4)
                type_text "${C_DIM}Ты падаешь на кровать... Силы восстановлены!${C_RESET}"
                HP=$MAX_HP
                sleep 2
                location_apartment
                return
                ;;
            5) save_game ;;
            6) main_menu; return ;;
            *) type_text "${C_RED}Команда не распознана.${C_RESET}" ;;
        esac
    done
}

# --- ТРУЩОБЫ (НОВАЯ ЛОКАЦИЯ) ---
location_slums() {
    clear_screen
    print_status
    draw_city
    
    type_text "${C_DIM}Грязные улицы Нео-Москвы. Здесь пахнет неоном, дождем и дешевой лапшой.${C_RESET}"
    type_text "${C_DIM}Тут можно подзаработать или лишиться головы.${C_RESET}"

    while true; do
        echo -e "${C_CYAN}--- ТРУЩОБЫ ---${C_RESET}"
        echo "1) Найти Фиксера Джо (Магазин Оружия)"
        echo "2) Пойти к Риппердоку (Кибер-Клиника)"
        echo "3) Искать неприятности в подворотнях (Гринд EXP/Денег)"
        echo "4) Вернуться в квартиру"
        
        echo -n -e "${C_MAGENTA}street> ${C_RESET}"
        read -r slum_choice

        case $slum_choice in
            1)
                clear_screen
                type_text "${C_YELLOW}Фиксер Джо:${C_RESET} ${C_WHITE}Чего надо, киберпанк? Пушки стоят денег.${C_RESET}"
                echo "1) Купить Термо-Катану (100 ₿) [+15 Урон]"
                echo "2) Купить Пистолет 'Умник' (250 ₿) [+30 Урон]"
                echo "3) Уйти"
                read -r w_choice
                if [[ $w_choice -eq 1 ]]; then
                    if [[ $MONEY -ge 100 && "$WEAPON_NAME" != *"Катана"* && "$WEAPON_NAME" != *"Пистолет"* ]]; then
                        MONEY=$((MONEY - 100))
                        WEAPON_NAME="Термо-Катана"
                        ATK_BASE=$((ATK_BASE + 15))
                        type_text "${C_GREEN}Ты купил Термо-Катану!${C_RESET}"
                    else
                        type_text "${C_RED}Не хватает денег или пушка уже круче!${C_RESET}"
                    fi
                elif [[ $w_choice -eq 2 ]]; then
                    if [[ $MONEY -ge 250 && "$WEAPON_NAME" != *"Пистолет"* ]]; then
                        MONEY=$((MONEY - 250))
                        WEAPON_NAME="Пистолет 'Умник'"
                        ATK_BASE=$((ATK_BASE + 30))
                        type_text "${C_GREEN}Ты купил Пистолет!${C_RESET}"
                    else
                        type_text "${C_RED}Не хватает денег!${C_RESET}"
                    fi
                fi
                sleep 2
                clear_screen
                print_status
                ;;
            2)
                location_ripperdoc
                return
                ;;
            3)
                local enc=$(( RANDOM % 3 ))
                if [[ $enc -eq 0 ]]; then
                    combat_sequence "Уличный Гопник" 40 5 25 30
                elif [[ $enc -eq 1 ]]; then
                    combat_sequence "Синдицированный Бандит" 70 12 40 50
                else
                    combat_sequence "Кибер-Псих (Мини-босс)" 150 20 100 150
                fi
                
                # Проверка жив ли игрок после боя
                if [[ $HP -le 0 ]]; then return; fi 
                
                clear_screen
                print_status
                ;;
            4)
                location_apartment
                return
                ;;
            *) type_text "${C_RED}Мимо.${C_RESET}" ;;
        esac
    done
}

# --- КЛИНИКА РИППЕРДОКА (НОВАЯ ЛОКАЦИЯ) ---
location_ripperdoc() {
    clear_screen
    print_status
    draw_ripperdoc
    
    type_text "${C_YELLOW}Доктор Зет:${C_RESET} ${C_WHITE}Присаживайся в кресло. Что будем резать сегодня?${C_RESET}"

    while true; do
        echo -e "${C_CYAN}--- КИБЕР-КЛИНИКА ---${C_RESET}"
        echo "1) Подкожная броня 'Кевлар-М' (150 ₿) [+10 Защита]"
        echo "2) Нейро-ускоритель (200 ₿) [+50 Макс HP]"
        echo "3) Полное лечение (20 ₿)"
        echo "4) Выйти на улицу"
        
        echo -n -e "${C_MAGENTA}doc> ${C_RESET}"
        read -r doc_choice

        case $doc_choice in
            1)
                if [[ $MONEY -ge 150 && "$ARMOR_NAME" != *"Кевлар"* ]]; then
                    MONEY=$((MONEY - 150))
                    ARMOR_NAME="Броня 'Кевлар-М'"
                    DEF_BASE=$((DEF_BASE + 10))
                    type_text "${C_GREEN}Доктор вшил тебе броню. Стало больнее, но безопаснее.${C_RESET}"
                else
                    type_text "${C_RED}Нет денег или уже установлено!${C_RESET}"
                fi
                sleep 2
                clear_screen
                print_status
                ;;
            2)
                if [[ $MONEY -ge 200 && "$INVENTORY" != *"Нейро-ускоритель"* ]]; then
                    MONEY=$((MONEY - 200))
                    MAX_HP=$((MAX_HP + 50))
                    HP=$MAX_HP
                    if [[ "$INVENTORY" == "Пусто" ]]; then INVENTORY="Нейро-ускоритель"; else INVENTORY="$INVENTORY, Нейро-ускоритель"; fi
                    type_text "${C_GREEN}Нейро-ускоритель установлен! Жизнь бьет ключом.${C_RESET}"
                else
                    type_text "${C_RED}Нет денег или уже установлено!${C_RESET}"
                fi
                sleep 2
                clear_screen
                print_status
                ;;
            3)
                if [[ $MONEY -ge 20 && $HP -lt $MAX_HP ]]; then
                    MONEY=$((MONEY - 20))
                    HP=$MAX_HP
                    type_text "${C_GREEN}Доктор залатал твои раны.${C_RESET}"
                elif [[ $HP -eq $MAX_HP ]]; then
                    type_text "${C_YELLOW}Ты и так здоров как бык.${C_RESET}"
                else
                    type_text "${C_RED}Нет кредитов!${C_RESET}"
                fi
                sleep 2
                clear_screen
                print_status
                ;;
            4)
                location_slums
                return
                ;;
            *) type_text "${C_RED}Мимо.${C_RESET}" ;;
        esac
    done
}


# --- ВЗЛОМ БАНКОМАТА ---
mini_game_atm() {
    clear_screen
    print_status
    type_text "${C_CYAN}>>> ИНИЦИАЛИЗАЦИЯ УЯЗВИМОСТИ БАНКОМАТА B-CORP <<<${C_RESET}"
    type_text "${C_DIM}Система требует пин-код администратора. Тебе нужно угадать число от 1 до 100.${C_RESET}"
    
    local secret=$(( RANDOM % 100 + 1 ))
    local attempts=7
    local won=0

    while [[ $attempts -gt 0 ]]; do
        echo -e "${C_YELLOW}Осталось попыток: $attempts${C_RESET}"
        echo -n -e "${C_GREEN}Введите число (1-100): ${C_RESET}"
        read -r guess

        if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
            type_text "${C_RED}Ошибка ввода! Вводите только числа!${C_RESET}"
            continue
        fi

        if [[ $guess -eq $secret ]]; then
            won=1
            break
        elif [[ $guess -lt $secret ]]; then
            type_text "${C_CYAN}[СИСТЕМА]${C_RESET} Искомое число больше, чем $guess."
        else
            type_text "${C_CYAN}[СИСТЕМА]${C_RESET} Искомое число меньше, чем $guess."
        fi
        
        ((attempts--))
    done

    if [[ $won -eq 1 ]]; then
        type_text "${C_BG_GREEN}${C_WHITE} ДОСТУП РАЗРЕШЕН. ИДЕТ ПЕРЕВОД СРЕДСТВ... ${C_RESET}"
        type_text "${C_GREEN}+100 ₿ и +20 EXP${C_RESET}"
        MONEY=$((MONEY + 100))
        EXP=$((EXP + 20))
        ATM_HACKS=$((ATM_HACKS + 1))
        CHAPTER=2
        check_levelup
        sleep 2
        
        if [[ $ATM_HACKS -eq 1 ]]; then
            echo ""
            type_text "${C_RED}$STALKER_NAME:${C_RESET} ${C_WHITE}Неплохо сработано. Но ты слишком неосторожен... Я видел всё.${C_RESET}"
            sleep 2
            clear_screen
            type_text "${C_YELLOW}Zero:${C_RESET} ${C_WHITE}Отлично. Теперь иди в Даркнет и купи Nmap_Pro и 0day_Exploit.${C_RESET}"
            sleep 2
        fi
    else
        type_text "${C_BG_RED}${C_WHITE} ДОСТУП ЗАПРЕЩЕН. СИСТЕМА БЛОКИРУЕТСЯ. ${C_RESET}"
        HP=$((HP - 20))
        type_text "${C_RED}-20 HP (Электрический разряд!)${C_RESET}"
        if [[ $HP -le 0 ]]; then
            game_over "Тебя убило током от защитной системы банкомата."
            return
        fi
        sleep 2
    fi
}

# --- ДАРКНЕТ ---
location_darknet() {
    CHAPTER=3
    clear_screen
    print_status
    
    echo -e "${C_MAGENTA}"
    cat << "EOF"
  ___  ___  ___  _   _  _  _  ____  ____ 
 |   \|   \| _ \| | / /| \| || __ ||_  _|
 | |) | - <|  _/| |/ / | .` ||  __|  ||  
 |___/|_|\_|_|  |___/  |_|\_||____|  ||  
         ТЕНЕВОЙ РЫНОК
EOF
    echo -e "${C_RESET}"

    while true; do
        print_status
        echo -e "${C_CYAN}--- ТОВАРЫ В ПРОДАЖЕ ---${C_RESET}"
        echo "1) Nmap_Pro (Цена: 50 ₿) - Сканер уязвимостей сетей B-Corp."
        echo "2) 0day_Exploit (Цена: 150 ₿) - Инструмент для проникновения."
        echo "3) Стимулятор в инвентарь (Цена: 30 ₿) - Лечит в бою."
        echo "4) База паролей B-Corp (Цена: 10 ₿) - Слитые пароли."
        echo "5) Выйти из сети (Вернуться в квартиру)"
        echo "6) [СЮЖЕТ] Начать взлом корпорации B-Corp"
        
        echo -n -e "${C_MAGENTA}darknet> ${C_RESET}"
        read -r shop_choice

        case $shop_choice in
            1)
                if [[ "$INVENTORY" == *"Nmap_Pro"* ]]; then
                    type_text "${C_YELLOW}Этот софт у тебя уже есть.${C_RESET}"
                elif [[ $MONEY -ge 50 ]]; then
                    MONEY=$((MONEY - 50))
                    if [[ "$INVENTORY" == "Пусто" || "$INVENTORY" == "Телефон" || "$INVENTORY" == "Zero_Contact" ]]; then
                        INVENTORY="Nmap_Pro"
                    else
                        INVENTORY="$INVENTORY, Nmap_Pro"
                    fi
                    type_text "${C_GREEN}Транзакция успешна. Nmap_Pro загружен.${C_RESET}"
                else
                    type_text "${C_RED}Недостаточно кредитов!${C_RESET}"
                fi
                sleep 1.5
                clear_screen
                ;;
            2)
                if [[ "$INVENTORY" == *"0day_Exploit"* ]]; then
                    type_text "${C_YELLOW}Этот эксплойт у тебя уже есть.${C_RESET}"
                elif [[ $MONEY -ge 150 ]]; then
                    MONEY=$((MONEY - 150))
                    if [[ -z "$INVENTORY" || "$INVENTORY" == "Пусто" ]]; then
                        INVENTORY="0day_Exploit"
                    else
                        INVENTORY="$INVENTORY, 0day_Exploit"
                    fi
                    type_text "${C_GREEN}Транзакция успешна. 0day_Exploit загружен.${C_RESET}"
                else
                    type_text "${C_RED}Недостаточно кредитов!${C_RESET}"
                fi
                sleep 1.5
                clear_screen
                ;;
            3)
                if [[ $MONEY -ge 30 ]]; then
                    MONEY=$((MONEY - 30))
                    if [[ -z "$INVENTORY" || "$INVENTORY" == "Пусто" ]]; then
                        INVENTORY="Стимулятор"
                    else
                        INVENTORY="$INVENTORY, Стимулятор"
                    fi
                    type_text "${C_GREEN}Дрон доставил Стимулятор.${C_RESET}"
                else
                    type_text "${C_RED}Недостаточно кредитов!${C_RESET}"
                fi
                sleep 1.5
                clear_screen
                ;;
            4)
                if [[ "$INVENTORY" == *"B-Corp_Passwords"* ]]; then
                    type_text "${C_YELLOW}Эта база данных уже у тебя на диске.${C_RESET}"
                elif [[ $MONEY -ge 10 ]]; then
                    MONEY=$((MONEY - 10))
                    if [[ -z "$INVENTORY" || "$INVENTORY" == "Пусто" ]]; then
                        INVENTORY="B-Corp_Passwords"
                    else
                        INVENTORY="$INVENTORY, B-Corp_Passwords"
                    fi
                    type_text "${C_GREEN}Файл получен. Мастер-пароль от Ядра: $CORE_PASSWORD${C_RESET}"
                    sleep 1
                else
                    type_text "${C_RED}Недостаточно кредитов!${C_RESET}"
                fi
                sleep 2
                clear_screen
                ;;
            5)
                location_apartment
                return
                ;;
            6)
                if [[ "$INVENTORY" == *"Nmap_Pro"* && "$INVENTORY" == *"0day_Exploit"* ]]; then
                    type_text "${C_YELLOW}Zero:${C_RESET} ${C_WHITE}Отлично. Арсенал готов. Давай снесем их файрвол.${C_RESET}"
                    sleep 2
                    location_bcorp_perimeter
                    return
                else
                    type_text "${C_RED}Zero:${C_RESET} ${C_WHITE}Ты с ума сошел? Без Nmap_Pro и 0day_Exploit они сожрут тебя заживо. Купи софт!${C_RESET}"
                    sleep 2
                    clear_screen
                fi
                ;;
            *)
                type_text "${C_RED}Ошибка ввода.${C_RESET}"
                ;;
        esac
    done
}

# --- ПЕРИМЕТР B-CORP ---
location_bcorp_perimeter() {
    CHAPTER=4
    clear_screen
    print_status

    type_text "${C_DIM}Ты находишься перед виртуальным периметром серверов B-Corp.${C_RESET}"
    type_text "${C_RED}$STALKER_NAME:${C_RESET} ${C_WHITE}Продолжай, $PLAYER_NAME. Я иду за тобой по пятам прямо в их ядро.${C_RESET}"
    echo ""
    type_text "${C_CYAN}[СИСТЕМА] Активирован Nmap_Pro... Сканирование открытых портов...${C_RESET}"
    sleep 1
    type_text "${C_CYAN}[СИСТЕМА] Обнаружены следующие уязвимости:${C_RESET}"
    echo "  - Port 21 (FTP)"
    echo "  - Port 22 (SSH)"
    echo "  - Port 8080 (Web-Admin)"
    echo "  - Port 9999 (Скрытая синхронизация ядра B-Corp)"

    local scanned=0
    while [[ $scanned -eq 0 ]]; do
        echo -n -e "${C_MAGENTA}Выберите порт для атаки: ${C_RESET}"
        read -r port_choice

        case $port_choice in
            21)
                type_text "${C_RED}Ловушка! FTP-сервер отправил вредоносный код тебе в ответ.${C_RESET}"
                HP=$((HP - 30))
                type_text "${C_RED}-30 HP${C_RESET}"
                if [[ $HP -le 0 ]]; then game_over "Убит ответным кибер-ударом B-Corp."; return; fi
                ;;
            22)
                type_text "${C_YELLOW}SSH закрыт 4096-битным ключом. Твои мощности здесь бессильны.${C_RESET}"
                ;;
            8080)
                type_text "${C_RED}Сработала система WAF. Замечена подозрительная активность.${C_RESET}"
                HP=$((HP - 15))
                type_text "${C_RED}-15 HP${C_RESET}"
                if [[ $HP -le 0 ]]; then game_over "Тебя вычислил отдел безопасности."; return; fi
                ;;
            9999)
                type_text "${C_GREEN}БИНГО! Порт 9999 открыт. 0day_Exploit успешно запущен.${C_RESET}"
                sleep 1
                type_text "${C_BG_GREEN}${C_WHITE} [УСПЕХ] ПЕРИМЕТР ПРОРВАН. ДОСТУП К ЯДРУ ПОЛУЧЕН. ${C_RESET}"
                scanned=1
                sleep 2
                location_bcorp_core
                return
                ;;
            *)
                type_text "${C_RED}Такой порт не обнаружен.${C_RESET}"
                ;;
        esac
    done
}

# --- ВЗЛОМ ЯДРА B-CORP ---
location_bcorp_core() {
    CHAPTER=5
    clear_screen
    print_status
    
    echo -e "${C_RED}"
    cat << "EOF"
  /$$$$$$   /$$$$$$  /$$$$$$$  /$$$$$$$$
 /$$__  $$/$$__ $$| $$__  $$| $$_____/
| $$ \__/|$$  \ $$| $$ \$$| $$      
| $$     |$$  | $$| $$$$$$$/| $$$$$   
| $$     |$$  | $$| $$__  $$| $$__/   
| $$  $$| $$ |$$| $$ \$$| $$      
|  $$$$$$/|  $$$$$$/| $$ |$$| $$$$$$$$
 \______/  \______/ |__/  |__/|________/
EOF
    echo -e "${C_RESET}"

    type_text "${C_DIM}Ты внутри. Вокруг тебя терабайты корпоративных секретов.${C_RESET}"
    type_text "${C_YELLOW}Zero:${C_RESET} ${C_WHITE}Ищи базу данных по проекту 'Blackout'.${C_RESET}"
    sleep 1
    type_text "${C_RED}$STALKER_NAME:${C_RESET} ${C_WHITE}Спасибо, что открыл мне дверь, $PLAYER_NAME. Теперь эти данные наши.${C_RESET}"
    echo ""
    type_text "${C_CYAN}[СИСТЕМА] Обнаружена база данных 'Project Blackout'. Требуется мастер-пароль.${C_RESET}"
    
    if [[ "$INVENTORY" == *"B-Corp_Passwords"* ]]; then
        echo ""
        type_text "${C_GREEN}[ИНВЕНТАРЬ] Из купленной в Даркнете базы: 'Мастер-пароль: $CORE_PASSWORD'${C_RESET}"
        echo ""
    fi

    local core_attempts=5
    local core_hacked=0

    while [[ $core_attempts -gt 0 ]]; do
        echo -e "${C_YELLOW}Осталось попыток: $core_attempts${C_RESET}"
        echo -n -e "${C_MAGENTA}Введите 4 цифры пароля: ${C_RESET}"
        read -r pass_guess

        if [[ "$pass_guess" == "$CORE_PASSWORD" ]]; then
            type_text "${C_BG_GREEN}${C_WHITE} ПАРОЛЬ ПРИНЯТ. ИДЕТ КОПИРОВАНИЕ ДАННЫХ... ${C_RESET}"
            core_hacked=1
            break
        else
            type_text "${C_BG_RED}${C_WHITE} ПАРОЛЬ ОТКЛОНЕН. ЗАЩИТНЫЕ СИСТЕМЫ АТАКУЮТ! ${C_RESET}"
            HP=$((HP - 25))
            type_text "${C_RED}-25 HP${C_RESET}"
            if [[ $HP -le 0 ]]; then
                game_over "Система безопасности поджарила твои нейроинтерфейсы."
                return
            fi
        fi
        ((core_attempts--))
    done

    if [[ $core_hacked -eq 1 ]]; then
        type_text "${C_GREEN}Данные успешно скачаны на твой локальный накопитель.${C_RESET}"
        sleep 2
        endings_hub
    else
        game_over "Система навсегда заблокировала базу данных. Миссия провалена."
    fi
}

# --- РАЗВЯЗКА (КОНЦОВКИ) ---
endings_hub() {
    CHAPTER=6
    clear_screen
    print_status

    type_text "${C_DIM}Ты отключаешься от сети B-Corp. Данные у тебя.${C_RESET}"
    type_text "${C_DIM}Проект 'Blackout' — это план отключения энергии в бедных секторах города для геноцида.${C_RESET}"
    echo ""
    type_text "${C_YELLOW}Zero:${C_RESET} ${C_WHITE}$PLAYER_NAME! Передай данные мне, мы сольем их в сеть и уничтожим корпорацию!${C_RESET}"
    sleep 1
    type_text "${C_CYAN}[ВХОДЯЩИЙ ЗВОНОК: НЕИЗВЕСТНЫЙ НОМЕР]${C_RESET}"
    type_text "${C_RED}Служба безопасности B-Corp:${C_RESET} ${C_WHITE}$PLAYER_NAME. Мы знаем твой IP. Удали эти данные, и мы переведем тебе 10,000,000 ₿.${C_RESET}"
    sleep 1
    type_text "${C_RED}$STALKER_NAME:${C_RESET} ${C_WHITE}Или же... отдай их мне. Мы вдвоем станем королями этого города. Решай с умом, мой друг.${C_RESET}"
    echo ""
    
    echo -e "${C_GREEN}Сделай свой выбор:${C_RESET}"
    echo "1) Отдать данные Zero (Путь сопротивления)"
    echo "2) Продать данные B-Corp (Путь корпората)"
    echo "3) Отдать данные Неизвестному ($STALKER_NAME) (Путь теневого владыки)"
    
    while true; do
        echo -n -e "${C_MAGENTA}Твой выбор> ${C_RESET}"
        read -r end_choice

        case $end_choice in
            1)
                clear_screen
                type_text "${C_GREEN}Ты отправляешь архив Zero.${C_RESET}"
                type_text "${C_YELLOW}Zero:${C_RESET} ${C_WHITE}Ты настоящий герой. Завтра этот город будет свободным.${C_RESET}"
                type_text "${C_RED}$STALKER_NAME:${C_RESET} ${C_WHITE}Ты сделал плохой выбор, $PLAYER_NAME. Мы еще встретимся.${C_RESET}"
                echo ""
                type_text "${C_BG_GREEN}${C_WHITE} КОНЦОВКА 1: ОСВОБОДИТЕЛЬ СЕТИ ${C_RESET}"
                sleep 3
                exit 0
                ;;
            2)
                clear_screen
                type_text "${C_RED}Ты стираешь логи и передаешь ключи B-Corp.${C_RESET}"
                type_text "${C_YELLOW}Zero:${C_RESET} ${C_WHITE}Ты предатель! Они убьют нас всех!${C_RESET}"
                type_text "${C_DIM}Связь с Zero обрывается. На твой счет поступает 10,000,000 ₿.${C_RESET}"
                echo ""
                type_text "${C_BG_RED}${C_WHITE} КОНЦОВКА 2: ЦЕПНОЙ ПЕС КОРПОРАЦИИ ${C_RESET}"
                sleep 3
                exit 0
                ;;
            3)
                clear_screen
                type_text "${C_MAGENTA}Ты передаешь все доступы Неизвестному.${C_RESET}"
                type_text "${C_RED}$STALKER_NAME:${C_RESET} ${C_WHITE}Великолепно. Теперь B-Corp и Zero уничтожат друг друга, а мы заберем всё.${C_RESET}"
                type_text "${C_DIM}Ты становишься невидимым кардиналом цифрового мира.${C_RESET}"
                echo ""
                type_text "${C_BG_MAGENTA}${C_WHITE} КОНЦОВКА 3: ЦИФРОВОЙ КОРОЛЬ ${C_RESET}"
                sleep 3
                exit 0
                ;;
            *)
                type_text "${C_RED}Делай выбор, времени нет!${C_RESET}"
                ;;
        esac
    done
}

# --- ЭКРАН СМЕРТИ (GAME OVER) ---
game_over() {
    local reason="$1"
    clear_screen
    echo -e "${C_BG_RED}${C_WHITE} ИГРА ОКОНЧЕНА ${C_RESET}"
    echo -e "${C_RED}Причина: $reason${C_RESET}"
    echo ""
    type_text "${C_RED}$STALKER_NAME:${C_RESET} ${C_WHITE}Какое разочаровывающее поражение...${C_RESET}"
    sleep 2
    echo "Нажмите Enter, чтобы вернуться в главное меню..."
    read -r
    main_menu
}

# --- ГЛАВНОЕ МЕНЮ (MAIN MENU) ---
main_menu() {
    clear_screen
    draw_logo
    
    echo -e "${C_GREEN}1. Новая игра${C_RESET}"
    echo -e "${C_YELLOW}2. Загрузить игру${C_RESET}"
    echo -e "${C_RED}3. Выход${C_RESET}"
    echo ""
    
    while true; do
        echo -n -e "${C_MAGENTA}Выбор> ${C_RESET}"
        read -r choice
        
        case $choice in
            1)
                HP=100
                MAX_HP=100
                LEVEL=1
                EXP=0
                MAX_EXP=100
                MONEY=0
                ATK_BASE=10
                DEF_BASE=0
                WEAPON_NAME="Кулаки"
                ARMOR_NAME="Старая куртка"
                INVENTORY="Телефон"
                CHAPTER=1
                CORE_PASSWORD=$(( RANDOM % 9000 + 1000 ))
                ATM_HACKS=0
                fake_boot
                location_apartment
                break
                ;;
            2)
                load_game
                break
                ;;
            3)
                clear_screen
                echo -e "${C_CYAN}Отключение от матрицы... До связи, $PLAYER_NAME.${C_RESET}"
                exit 0
                ;;
            *)
                echo -e "${C_RED}Ошибка. Выберите 1, 2 или 3.${C_RESET}"
                ;;
        esac
    done
}

# ==============================================================================
# ЗАПУСК ИГРЫ
# ==============================================================================
if ! command -v sleep &> /dev/null; then
    echo "Критическая ошибка: команда sleep не найдена в системе."
    exit 1
fi

main_menu