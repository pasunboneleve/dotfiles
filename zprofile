MY_ULIMIT=65536

if [[ $(ulimit -n) != unlimited ]] \
  && (( $(ulimit -n) < $MY_ULIMIT )) \
  && { [[ $(ulimit -Hn) == unlimited ]] || (( $(ulimit -Hn) >= $MY_ULIMIT )); }; then
  # Raise the per-process file-descriptor limit for login shells, allowing tools
  # that keep many files open to avoid exhausting the default limit.
  ulimit -n $MY_ULIMIT
fi
