#!/bin/bash

function fetch_roles() {
    roles_url="https://api.github.com/repos/drew138/.dotfiles/contents/roles"
    if command -v curl &> /dev/null; then
        roles_response=$(curl -s "$roles_url")
    elif command -v wget &> /dev/null; then
        roles_response=$(wget -qO- "$roles_url")
    else
        echo "Neither curl nor wget is installed. Exiting."
        exit 1
    fi
    echo "$roles_response" |  \
    grep "name" |  \
    sed -e 's/\"name\":\ \"//' -e 's/\"\,//' -e 's/\ //g' | \
    tr '\n' ' '
}

function select_roles() {
    read -a roles <<< "$(fetch_roles)"
    display_menu "Select the roles you want to install" "${roles[@]}"
}

function create_vault_password_file() {
    echo "$ansible_vault_password" > ~/.vault_pass
}

function remove_vault_password_file() {
    rm ~/.vault_pass ~/extra_vars.yml
}

function run_ansible() {
    local password
    local ansible_vault_password
    password="$1"
    ansible_vault_password="$2"
    {
        echo ---
        ansible-vault encrypt_string "$password" --name 'ansible_become_password' \
        --vault-password-file ~/.vault_pass
        # echo "selected_hosts: localhost"
        echo "selected_roles:"
        echo -e "$selected_roles"
    } >> ~/extra_vars.yml

    repository_url="https://github.com/Drew138/.dotfiles.git"
    ansible-pull -U $repository_url local.yml \
    --vault-password-file ~/.vault_pass
}

function run() {
    local selected_roles
    local password
    local ansible_vault_password

    printf "Please enter your password: "
    read -r -s password
    printf "\n"
    printf "Please enter your ansible vault password: "
    read -r -s ansible_vault_password
    printf "\n"

    select_roles

    (
        create_vault_password_file && (
            run_ansible "$password" "$ansible_vault_password"
        ) && remove_vault_password_file
    ) || remove_vault_password_file
}

function clear_menu() {
    local len="$1"

    for (( i = 0; i <=len; i++)); do
        echo -ne "\033[A"  # Move cursor up one line
        echo -ne "\033[K"  # Clear the line
    done
}

function print_line() {
    local lines_diff
    lines_diff="$1"
    for _ in $(seq 1 "$lines_diff"); do
        echo -ne "\033[A"  # Move cursor up one line
    done
    echo -ne "\033[K"  # Clear the line

    echo -e "$2"  # Print new content

    for _ in $(seq 1 "$lines_diff"); do
        echo -ne "\033[B"  # move the cursor down one line
    done
}

function print_purple() {
    local text
    text=$(cat < /dev/stdin)
    echo -e "\033[35m$text\033[0m"
}

function print_hover() {
    local text
    text=$(cat < /dev/stdin)
    echo -e "\033[38;5;208m > \033[0m$text"
}

function print_non_hover() {
    local text
    text=$(cat < /dev/stdin)
    echo -e "   $text"
}

function print_selected() {
    local text
    text=$(cat < /dev/stdin)
    echo -e "[\033[32m✓\033[0m] $text"
}

function print_non_selected() {
    local text
    text=$(cat < /dev/stdin)
    echo -e "[ ] $text"
}

function cleanup() {
    tput cnorm
    stty echo
}

function display_menu() {
    local title
    local roles
    local position
    local reverse_position
    local len
    local is_selected
    local role

    title="$1"
    roles=("${@:2}")

    stty -echo

    trap cleanup EXIT # restore mouse
    tput civis # hide cursor

    position=0
    reverse_position=${#roles[@]} # used to move cursor up and down
    len=${#roles[@]} # length of the array
    is_selected=("${roles[@]/*/0}") # array of zeros

    echo "$title" | print_purple
    for i in "${!roles[@]}"; do
        role="${roles[$i]}"
        if [ "$i" -eq "$position" ]; then
            echo "$role" | print_non_selected | print_hover
        else
            echo "$role" | print_non_selected | print_non_hover
        fi
    done

    TMP_IFS=$IFS
    while true; do
        IFS=
        # Read one character at a time
        read -rsn1 input

        if [ "$input" = "" ]; then
            break
        fi

        IFS=$TMP_IFS # restore IFS
        # Check for escape sequences (special keys)
        role="${roles[$position]}"
        case "$input" in
            $'\e')
                # Read the next two characters for arrow keys
                read -rsn2 input
                case "$input" in
                    "[A")
                        if [ "${is_selected[$position]}" -eq 0 ]; then
                            current_line=$(echo "$role" | print_non_selected)
                        else
                            current_line=$(echo "$role" | print_selected)
                        fi

                        current_line=$(echo "$current_line" | print_non_hover)
                        print_line "$reverse_position" "$current_line"

                        if [ "$reverse_position" -eq "$len" ]; then
                            reverse_position=1
                        else
                            reverse_position=$((reverse_position + 1))
                        fi


                        if [ "$position" -eq 0 ]; then
                            position=$((len - 1))
                        else
                            position=$((position - 1))
                        fi

                        new_role="${roles[$position]}"
                        if [ "${is_selected[$position]}" -eq 0 ]; then
                            new_line=$(echo "$new_role" | print_non_selected )
                        else
                            new_line=$(echo "$new_role" | print_selected )
                        fi

                        new_line=$(echo "$new_line" | print_hover)
                        print_line "$reverse_position" "$new_line"
                        ;;
                    "[B")
                        if [ "${is_selected[$position]}" -eq 0 ]; then
                            current_line=$(echo "$role" | print_non_selected)
                        else
                            current_line=$(echo "$role" | print_selected)
                        fi

                        current_line=$(echo "$current_line" | print_non_hover)
                        print_line "$reverse_position" "$current_line"

                        if [ "$reverse_position" -eq 1 ]; then
                            reverse_position=$len
                        else
                            reverse_position=$((reverse_position - 1))
                        fi


                        if [ "$position" -eq $((len - 1)) ]; then
                            position=0
                        else
                            position=$((position + 1))
                        fi

                        new_role="${roles[$position]}"
                        if [ "${is_selected[$position]}" -eq 0 ]; then
                            new_line=$(echo "$new_role" | print_non_selected )
                        else
                            new_line=$(echo "$new_role" | print_selected )
                        fi

                        new_line=$(echo "$new_line" | print_hover)
                        print_line "$reverse_position" "$new_line"


                        ;;
                    "[C")
                        line=$(echo "$role" | print_selected | print_hover)
                        print_line "$reverse_position" "$line"
                        is_selected[position]=1
                        ;;
                    "[D")
                        line=$(echo "$role" | print_non_selected | print_hover)
                        print_line "$reverse_position" "$line"
                        is_selected[position]=0
                        ;;
                    *)
                        # Handle other escape sequences if needed
                        ;;
                esac
            ;;
            'k')
                if [ "${is_selected[$position]}" -eq 0 ]; then
                    current_line=$(echo "$role" | print_non_selected)
                else
                    current_line=$(echo "$role" | print_selected)
                fi

                current_line=$(echo "$current_line" | print_non_hover)
                print_line "$reverse_position" "$current_line"

                if [ "$reverse_position" -eq "$len" ]; then
                    reverse_position=1
                else
                    reverse_position=$((reverse_position + 1))
                fi


                if [ "$position" -eq 0 ]; then
                    position=$((len - 1))
                else
                    position=$((position - 1))
                fi

                new_role="${roles[$position]}"
                if [ "${is_selected[$position]}" -eq 0 ]; then
                    new_line=$(echo "$new_role" | print_non_selected )
                else
                    new_line=$(echo "$new_role" | print_selected )
                fi

                new_line=$(echo "$new_line" | print_hover)
                print_line "$reverse_position" "$new_line"
                ;;
            'j')
                if [ "${is_selected[$position]}" -eq 0 ]; then
                    current_line=$(echo "$role" | print_non_selected)
                else
                    current_line=$(echo "$role" | print_selected)
                fi

                current_line=$(echo "$current_line" | print_non_hover)
                print_line "$reverse_position" "$current_line"

                if [ "$reverse_position" -eq 1 ]; then
                    reverse_position=$len
                else
                    reverse_position=$((reverse_position - 1))
                fi


                if [ "$position" -eq $((len - 1)) ]; then
                    position=0
                else
                    position=$((position + 1))
                fi

                new_role="${roles[$position]}"
                if [ "${is_selected[$position]}" -eq 0 ]; then
                    new_line=$(echo "$new_role" | print_non_selected )
                else
                    new_line=$(echo "$new_role" | print_selected )
                fi

                new_line=$(echo "$new_line" | print_hover)
                print_line "$reverse_position" "$new_line"
                ;;
            'l')
                line=$(echo "$role" | print_selected | print_hover)
                print_line "$reverse_position" "$line"
                is_selected[position]=1
                ;;
            'h')
                line=$(echo "$role" | print_non_selected | print_hover)
                print_line "$reverse_position" "$line"
                is_selected[position]=0
                ;;
            *)
                # Handle other escape sequences if needed
                ;;
        esac
    done

    clear_menu "$len"

    selected_roles=""

    for (( i = 0; i <len; i++)); do
        if [ "${is_selected[$i]}" -eq 1 ]; then
            selected_roles+="  - ${roles[$i]}\n"
        fi
    done
}

run
