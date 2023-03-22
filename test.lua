local ffi = require("ffi")

ffi.cdef([[
  typedef struct uv_mutex_t uv_mutex_t;
  int uv_mutex_init(uv_mutex_t *handle);
  void uv_mutex_destroy(uv_mutex_t *handle);
  int uv_mutex_trylock(uv_mutex_t *handle);
  void uv_mutex_unlock(uv_mutex_t *handle);

  uint64_t uv_mutex_size();
  uv_mutex_t *uv_mutex_new(char *addr);
]])

_ = ffi.load("zig-out/lib/libmain.so", true)
local C = ffi.C

local function main()
  local mutex_raw = ffi.new("char[?]", C.uv_mutex_size())
  local mutex = C.uv_mutex_new(mutex_raw)
  print("init", C.uv_mutex_init(mutex))
  print("trylock#1", C.uv_mutex_trylock(mutex))
  print("trylock#2", C.uv_mutex_trylock(mutex))
  -- todo: coredump on unlocking an un-acquired lock
  C.uv_mutex_unlock(mutex)
  -- todo: coredump when lock has not been unlocked
  C.uv_mutex_destroy(mutex)
end

main()
