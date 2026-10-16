# shellcheck shell=bash

set -o errtrace

if [[ -t 2 && -z ${NO_COLOR:-} ]]; then
  _bold=$'\e[1m' _dim=$'\e[2m' _red=$'\e[31m' _green=$'\e[32m' _yellow=$'\e[33m' _blue=$'\e[34m' _reset=$'\e[0m'
else
  _bold='' _dim='' _red='' _green='' _yellow='' _blue='' _reset=''
fi

# all output goes to stderr so stdout stays clean for values and pipes
_step=0 _steps=0

# announces how many steps follow, so step prints [n/total]
steps() { _steps=$1 _step=0; }

step() {
  local counter=''
  if ((_steps > 0)); then
    _step=$((_step + 1))
    counter="[$_step/$_steps] "
  fi
  printf '%s==>%s %s%s%s%s\n' "$_blue$_bold" "$_reset" "$_bold" "$counter" "$*" "$_reset" >&2
}

# runs a command as a step and reports how it went
run_step() {
  local desc=$1 start status=0
  shift
  step "$desc"
  start=$SECONDS
  "$@" || status=$?
  if ((status != 0)); then
    error "$desc failed with exit code $status"
    exit "$_DIE_STATUS"
  fi
  ok "$desc ($((SECONDS - start))s)"
}

info() { printf '%s  ->%s %s\n' "$_dim" "$_reset" "$*" >&2; }
ok() { printf '%s  ok%s %s\n' "$_green$_bold" "$_reset" "$*" >&2; }
warn() { printf '%swarning:%s %s\n' "$_yellow$_bold" "$_reset" "$*" >&2; }
error() { printf '%serror:%s %s\n' "$_red$_bold" "$_reset" "$*" >&2; }

# exit status reserved for die, so the err trap of a parent shell stays quiet
# when a command substitution already reported its own failure
readonly _DIE_STATUS=3

die() {
  error "$@"
  exit "$_DIE_STATUS"
}

_on_err() {
  local status=$1 cmd=$2
  ((status == _DIE_STATUS)) || error "'$cmd' failed with exit code $status"
  exit "$status"
}

trap '_on_err $? "$BASH_COMMAND"' ERR
trap 'printf "\n" >&2; error "interrupted"; exit 130' INT

confirm() {
  local reply
  read -r -p "${_yellow}${_bold}??${_reset} $1 [y/N] " -n 1 reply
  echo >&2
  [[ $reply =~ ^[Yy]$ ]]
}

one_of() {
  local value=$1 choice
  shift
  for choice; do [[ $value == "$choice" ]] && return 0; done
  return 1
}
