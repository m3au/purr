#!/usr/bin/env bats
# unit_obfuscate.bats - Unit tests for obfuscate_key function

load test_helper

@test "obfuscate_key: short string returns as-is" {
  local result
  result=$(obfuscate_key "short")
  [ "$result" = "short" ]
}

@test "obfuscate_key: very short string returns as-is" {
  local result
  result=$(obfuscate_key "ab")
  [ "$result" = "ab" ]
}

@test "obfuscate_key: long string is obfuscated" {
  local result
  result=$(obfuscate_key "ghp_abcdefghijklmnopqrstuvwxyz1234567890")
  [ "$result" != "ghp_abcdefghijklmnopqrstuvwxyz1234567890" ]
  [[ "$result" =~ ^ghp_ ]]
  [[ "$result" =~ 7890$ ]]
}

@test "obfuscate_key: shows first 4 and last 4 characters" {
  local result
  local input="abcdefghijklmnopqrstuvwxyz"
  result=$(obfuscate_key "$input")
  
  local first_four="${input:0:4}"
  local last_four="${input: -4}"
  
  [[ "$result" =~ ^${first_four} ]]
  [[ "$result" =~ ${last_four}$ ]]
}

@test "obfuscate_key: middle is obfuscated with stars" {
  local result
  result=$(obfuscate_key "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  
  # Should have first 4: ABCD, stars in middle, last 4: WXYZ
  [[ "$result" =~ ^ABCD\*+WXYZ$ ]]
}

@test "obfuscate_key: handles exactly 8 characters" {
  local result
  result=$(obfuscate_key "12345678")
  # With 8 chars, it should return as-is (4*2 = 8)
  [ "$result" = "12345678" ]
}

@test "obfuscate_key: handles 9 characters" {
  local result
  result=$(obfuscate_key "123456789")
  # Should show first 4, one star, last 4
  [[ "$result" =~ ^1234\*6789$ ]]
}

@test "obfuscate_key: handles empty string" {
  local result
  result=$(obfuscate_key "")
  [ "$result" = "" ]
}
