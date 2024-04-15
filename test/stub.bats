#!/usr/bin/env bats

@test "stub test" {
  run echo "stub test"
  [[ $status -eq 0 ]]
}
