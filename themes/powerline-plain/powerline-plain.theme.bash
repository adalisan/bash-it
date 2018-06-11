#!/usr/bin/env bash

SHELL_SSH_CHAR="⌁ "
SHELL_THEME_PROMPT_COLOR=32
SHELL_SSH_THEME_PROMPT_COLOR=208

VIRTUALENV_CHAR="ⓔ "
VIRTUALENV_THEME_PROMPT_COLOR=25

GEMSET_CHAR="ⓔ "
GEMSET_THEME_PROMPT_COLOR=25

SCM_NONE_CHAR=""
SCM_GIT_CHAR="⎇  "
SCM_GIT_BEHIND_CHAR="↓"
SCM_GIT_AHEAD_CHAR="↑"
SCM_GIT_UNTRACKED_CHAR="?:"
SCM_GIT_UNSTAGED_CHAR="U:"
SCM_GIT_STAGED_CHAR="S:"

if [[ -z "$THEME_SCM_TAG_PREFIX" ]]; then
    SCM_TAG_PREFIX="tag > "
else
    SCM_TAG_PREFIX="$THEME_SCM_TAG_PREFIX"
fi

SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_DIRTY=""

SCM_THEME_PROMPT_COLOR=238
SCM_THEME_PROMPT_CLEAN_COLOR=231
SCM_THEME_PROMPT_DIRTY_COLOR=196
SCM_THEME_PROMPT_STAGED_COLOR=220
SCM_THEME_PROMPT_UNSTAGED_COLOR=166

CWD_THEME_PROMPT_COLOR=240

LAST_STATUS_THEME_PROMPT_COLOR=52

function set_rgb_color {
    if [[ "${1}" != "-" ]]; then
        fg="38;5;${1}"
    fi
    if [[ "${2}" != "-" ]]; then
        bg="48;5;${2}"
        [[ -n "${fg}" ]] && bg=";${bg}"
    fi
    echo -e "\[\033[${fg}${bg}m\]"
}

function powerline_shell_prompt {
    if [[ -n "${SSH_CLIENT}" ]]; then
        SHELL_PROMPT="${bold_white}$(set_rgb_color - ${SHELL_SSH_THEME_PROMPT_COLOR}) ${SHELL_SSH_CHAR}\u@\h ${normal}"
    else
        SHELL_PROMPT="${bold_white}$(set_rgb_color - ${SHELL_THEME_PROMPT_COLOR}) \u ${normal}"
    fi
}

function powerline_virtualenv_prompt {
    local environ=""

    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        environ="conda: $CONDA_DEFAULT_ENV"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        environ=$(basename "$VIRTUAL_ENV")
    fi

    if [[ -n "$environ" ]]; then
        VIRTUALENV_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} ${VIRTUALENV_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}$(set_rgb_color - ${VIRTUALENV_THEME_PROMPT_COLOR}) ${VIRTUALENV_CHAR}$environ ${normal}"
        LAST_THEME_COLOR=${VIRTUALENV_THEME_PROMPT_COLOR}
    else
        VIRTUALENV_PROMPT=""
    fi
}

function powerline_gemset_prompt {
    local gemset=$(rvm-prompt 2>/dev/null)

    if [[ -n "$gemset" ]]; then
        GEMSET_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} ${GEMSET_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}$(set_rgb_color - ${GEMSET_THEME_PROMPT_COLOR}) ${VIRTUALENV_CHAR}$gemset ${normal}"
        LAST_THEME_COLOR=${GEMSET_THEME_PROMPT_COLOR}
    else
        GEMSET_PROMPT=""
    fi
}

function powerline_scm_prompt {
    scm_prompt_vars

    if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
        if [[ "${SCM_DIRTY}" -eq 1 ]]; then
            if [[ -n "${SCM_GIT_STAGED}" ]]; then
                SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_STAGED_COLOR} ${SCM_THEME_PROMPT_COLOR})"
            elif [[ -n "${SCM_GIT_UNSTAGED}" ]]; then
                SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_UNSTAGED_COLOR} ${SCM_THEME_PROMPT_COLOR})"
            else
                SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_DIRTY_COLOR} ${SCM_THEME_PROMPT_COLOR})"
            fi
        else
            SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_CLEAN_COLOR} ${SCM_THEME_PROMPT_COLOR})"
        fi
        if [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]]; then
            local tag=""
            if [[ $SCM_IS_TAG -eq "1" ]]; then
                tag=$SCM_TAG_PREFIX
            fi
            SCM_BRANCH_SHORT="${SCM_BRANCH::14}"
            SCM_PROMPT+=" ${SCM_CHAR}${tag}${SCM_BRANCH_SHORT}${SCM_STATE} "
            [[ -n "${SCM_GIT_AHEAD}" ]] && SCM_PROMPT+="${SCM_GIT_AHEAD} "
            [[ -n "${SCM_GIT_BEHIND}" ]] && SCM_PROMPT+="${SCM_GIT_BEHIND} "
            [[ -n "${SCM_GIT_STAGED}" ]] && SCM_PROMPT+="${SCM_GIT_STAGED} "
            [[ -n "${SCM_GIT_UNSTAGED}" ]] && SCM_PROMPT+="${SCM_GIT_UNSTAGED} "
            [[ -n "${SCM_GIT_UNTRACKED}" ]] && SCM_PROMPT+="${SCM_GIT_UNTRACKED} "
            [[ -n "${SCM_GIT_STASH}" ]] && SCM_PROMPT+="${SCM_GIT_STASH} "
        fi
        SCM_PROMPT="${SCM_PROMPT}${normal}"
    else
        SCM_PROMPT=""
    fi
}

function powerline_cwd_prompt {
    CWD_PROMPT="${THEME_PROMPT_SEPARATOR}${normal}$(set_rgb_color - ${CWD_THEME_PROMPT_COLOR}) \w ${normal}$(set_rgb_color ${CWD_THEME_PROMPT_COLOR} -)${normal}"
}

function powerline_last_status_prompt {
    if [[ "$1" -eq 0 ]]; then
        LAST_STATUS_PROMPT=""
    else
        LAST_STATUS_PROMPT="$(set_rgb_color - ${LAST_STATUS_THEME_PROMPT_COLOR}) ${LAST_STATUS} ${normal}$(set_rgb_color ${LAST_STATUS_THEME_PROMPT_COLOR} -)${THEME_PROMPT_SEPARATOR}${normal}"
    fi
}

function powerline_prompt_command() {
    local LAST_STATUS="$?"

    powerline_shell_prompt
    powerline_virtualenv_prompt
    powerline_gemset_prompt
    powerline_scm_prompt
    powerline_cwd_prompt
    powerline_last_status_prompt LAST_STATUS

    PS1="${SHELL_PROMPT}${GEMSET_PROMPT}${VIRTUALENV_PROMPT}${SCM_PROMPT}${CWD_PROMPT}${LAST_STATUS_PROMPT} "
}

safe_append_prompt_command powerline_prompt_command

