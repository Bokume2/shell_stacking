#!/bin/bash
set -eu

usage() {
  cat <<EOF >&2

An esolang interpreter inplemented as a shell script.

Usage:
  $0 [options] [-f] <source file>

Options:
  -h, --help          Print this message then exit
  -e <code>           Run <code> instead of source file

EOF
  exit $1
}

readonly LF=$'\n'

ord() {
  printf "%d" \'"$1"
}

chr() {
  local hex=$(printf "%x" "$1")
  printf "\U${hex}"
}

run() {
  local pc=0
  local -a stack
  local stack_size=0
  local -a heap

  local ibuf=""
  local popped

  local tmp
  local tmp2
  local depth

  push() {
    stack[$((stack_size++))]=$1
  }
  pop() {
    if [ $stack_size -eq 0 ]; then
      popped=0
    else
      stack_size=$((--stack_size))
      popped=${stack[$stack_size]}
    fi
  }

  while [ "$pc" -lt "${#1}" ]; do
    local cmd="${1:$pc:1}"
    case "$cmd" in
    #push charcode
    [A-Za-z] )
      push $(ord "$cmd")
      ;;
    #push the number
    [0-9] )
      push $cmd
      ;;
    #add
    "+" )
      pop
      tmp=$popped
      pop
      push $((popped+tmp))
      ;;
    #subtract
    "-" )
      pop
      tmp=$popped
      pop
      push $((popped-tmp))
      ;;
    #multiply
    "*" )
      pop
      tmp=$popped
      pop
      push $((popped*tmp))
      ;;
    #devide
    "/" )
      pop
      tmp=$popped
      pop
      push $((popped/tmp))
      ;;
    #modulo
    "%" )
      pop
      tmp=$popped
      pop
      push $((popped%tmp))
      ;;
    #less than
    "<" )
      pop
      tmp=$popped
      pop
      if [ $popped -lt $tmp ]; then
        push 1
      else
        push 0
      fi
      ;;
    #greater than
    ">" )
      pop
      tmp=$popped
      pop
      if [ $popped -gt $tmp ]; then
        push 1
      else
        push 0
      fi
      ;;
    #is positive
    "?" )
      pop
      if [ $popped -gt 0 ]; then
        push 1
      else
        push 0
      fi
      ;;
    #not
    "!" )
      pop
      if [ $popped -eq 0 ]; then
        push 1
      else
        push 0
      fi
      ;;
    #dup
    ":" )
      pop
      tmp=$popped
      push $tmp
      push $tmp
      ;;
    #swap
    "\\" )
      pop
      tmp=$popped
      pop
      tmp2=$popped
      push $tmp
      push $tmp2
      ;;
    #push size
    "#" )
      push $stack_size
      ;;
    #store to heap
    "^" )
      pop
      tmp=$popped
      pop
      heap[$tmp]=$popped
      ;;
    #restore from heap
    "~" )
      pop
      tmp=$popped
      push ${heap[$tmp]:=0}
      ;;
    #input(char)
    "," )
      while [ -z "$ibuf" ]; do
        IFS="" read ibuf
      done
      push $(ord "${ibuf:0:1}")
      ibuf="${ibuf:1}"
      ;;
    #input(number)
    "|" )
      tmp=""
      local pattern="^(-?[0-9]+).*"
      while [[ ! "$tmp" =~ $pattern ]]; do
        read tmp
      done
      push ${BASH_REMATCH[1]}
      ;;
    #output(char)
    "." )
      pop
      chr $popped
      ;;
    #output(number)
    "_" )
      pop
      printf "%d" $popped
      ;;
    #trash
    "$" )
      pop
      tmp=$popped
      ;;
    #loop start
    "[" )
      pop
      if [ $popped -eq 0 ]; then
        depth=1
        while [ $depth -gt 0 ]; do
          pc=$((pc+1))
          if [ $pc -ge ${#1} ];then
            echo >&2
            echo "Syntax Error: Too many '['"
            return 1
          fi
          if [ "${1:$pc:1}" = "[" ]; then
            depth=$((depth+1))
          elif [ "${1:$pc:1}" = "]" ]; then
            depth=$((depth-1))
          fi
        done
      fi
      ;;
    #loop end
    "]" )
      depth=1
      while [ $depth -gt 0 ]; do
        pc=$((pc-1))
        if [ $pc -lt 0 ];then
          echo >&2
          echo "Syntax Error: Too many ']'"
          return 1
        fi
        if [ "${1:$pc:1}" = "[" ]; then
          depth=$((depth-1))
        elif [ "${1:$pc:1}" = "]" ]; then
          depth=$((depth+1))
        fi
      done
      pc=$((pc-1))
      ;;
    #if start
    "(" )
      pop
      if [ $popped -eq 0 ]; then
        depth=1
        while [ $depth -gt 0 ]; do
          pc=$((pc+1))
          if [ $pc -ge ${#1} ];then
            echo >&2
            echo "Syntax Error: Too many '('"
            return 1
          fi
          if [ "${1:$pc:1}" = "(" ]; then
            depth=$((depth+1))
          elif [ "${1:$pc:1}" = ")" ]; then
            depth=$((depth-1))
          fi
        done
      fi
      ;;
    #if end
    ")" )
      # nothing to do
      ;;
    #exit
    "@" )
      return
      ;;
    * )
      ;;
    esac
    pc=$((pc+1))
  done
}

if [ "$#" -eq 0 ]; then 
  usage 0
fi

code=""
for opt; do
  case "$opt" in
  "-h" | "--help" )
    usage 0
    ;;
  "-e" )
    if [ "$#" -lt 2 ]; then
      echo "Error: Pass a code after -e option." >&2
      usage 1
    fi
    code="$2"
    break
    ;;
  "-f" )
    if [ "$#" -lt 2 ]; then
      echo "Error: Pass source file's path after -f option." >&2
      usage 1
    fi
    break
    ;;
  esac
done

if [ -z "$code" ]; then
  if [ "$#" -eq 1 -a -f "$1" ]; then
    code="$(cat "$1")"
  elif [ "$#" -eq 0 ]; then
    echo "Error: Pass source file or code." >&2
    usage 1
  else
    echo "Error: Cannot find ${1} as a file." >&2
    usage 1
  fi
fi

run "$code" || exit $?
