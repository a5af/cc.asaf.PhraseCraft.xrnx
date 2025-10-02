# Test Fixes

## Issues Found in CI (Run #18192416170)

### Test Results: 37 total, 33 passed, 4 failed

## Failures Fixed

### 1. Mock doesn't support setting `selected_phrase = nil` (3 tests)

**Issue:**
- `get_phrase_info - should return nil when no phrase selected`
- `build_context_prompt - should return original prompt when no phrase selected`
- `has_selected_phrase - should return false when no phrase selected`

**Root Cause:**
The `renoise.song()` function returned a new table each time, so setting `song.selected_phrase = nil` didn't persist to the mock state.

**Fix:**
Changed `spec/mock_renoise.lua` to use a metatable proxy pattern:
```lua
song = function()
  return setmetatable({}, {
    __index = function(t, k)
      if k == "selected_phrase" then
        return mock_renoise.selected_phrase
      end
      return nil
    end,
    __newindex = function(t, k, v)
      if k == "selected_phrase" then
        mock_renoise.selected_phrase = v
      end
    end
  })
end
```

Now assignments to `song.selected_phrase` properly update the shared mock state.

### 2. Prompt history not cleared between tests (1 test)

**Issue:**
- `prompt history - should not add empty prompts`
- Expected 0 prompts, got 2 (leftovers from previous test)

**Root Cause:**
`config.prompt_history` is a module-level table that persists across tests. Previous tests added prompts that weren't cleared.

**Fix:**
Added history clearing to `spec/config_spec.lua` before_each:
```lua
before_each(function()
  config.initialize_preferences()
  config.prompt_history = {}  -- Clear history
end)
```

### 3. Mock state not reset between tests

**Issue:**
Potential for test pollution across test suites.

**Fix:**
Added before_each to `spec/phrase_utils_spec.lua`:
```lua
before_each(function()
  mock_renoise.reset()
end)
```

This ensures each test starts with a clean phrase mock.

## Expected Result

All 37 tests should now pass:
- ✓ 11 phrase_utils tests
- ✓ 26 config tests

## Verification

These fixes will be verified by CI on push.
