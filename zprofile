if [[ $OSTYPE == darwin* ]] \
  && [[ $(ulimit -n) != unlimited ]] \
  && (( $(ulimit -n) < 65536 )) \
  && { [[ $(ulimit -Hn) == unlimited ]] || (( $(ulimit -Hn) >= 65536 )); }; then
  # Raise the per-process file-descriptor limit for login shells, allowing tools
  # that keep many files open to avoid exhausting macOS's default limit.
  ulimit -n 65536
fi
