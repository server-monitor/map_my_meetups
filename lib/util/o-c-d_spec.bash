
main_o_c_d_spec() {
  local max="${1-4}"
  local count=0

  for ((count=0; count < max; count++)) {
    rspec || break
  }

  printf '%s\n\n' "Performed '$count' tests out of '$max'."
}

main_o_c_d_spec "$@"
