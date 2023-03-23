local ffi = require("ffi")

ffi.cdef([[
  typedef struct uv_mutex_t uv_mutex_t;
  int uv_mutex_init(uv_mutex_t *handle);
  void uv_mutex_destroy(uv_mutex_t *handle);
  int uv_mutex_trylock(uv_mutex_t *handle);
  void uv_mutex_unlock(uv_mutex_t *handle);

  uint64_t hal_uv_mutex_size();
  uv_mutex_t *hal_uv_mutex_new(char *addr);

  void hal_uv_mutex_create(uintptr_t *addr);
  void hal_uv_mutex_destroy(uintptr_t *addr);
]])

_ = ffi.load("zig-out/lib/libmain.so", true)
local C = ffi.C

local function by_pre_alloc_whole_memory()
  local mutex = {}
  do
    mutex.addr = ffi.new("char[?]", C.hal_uv_mutex_size())
    mutex.ptr = C.hal_uv_mutex_new(mutex.addr)
  end
  print("init", C.uv_mutex_init(mutex.ptr))
  print("trylock#1", C.uv_mutex_trylock(mutex.ptr))
  print("trylock#2", C.uv_mutex_trylock(mutex.ptr))
  C.uv_mutex_unlock(mutex.ptr)
  C.uv_mutex_destroy(mutex.ptr)
end

local function by_pre_alloc_ptr()
  local addr = ffi.new("uintptr_t[1]")
  C.hal_uv_mutex_create(addr)
  local ok, err = pcall(function()
    local mutex = ffi.cast("uv_mutex_t *", addr)
    print("init", C.uv_mutex_init(mutex))
    print("trylock#1", C.uv_mutex_trylock(mutex))
    print("trylock#2", C.uv_mutex_trylock(mutex))
    C.uv_mutex_unlock(mutex)
    C.uv_mutex_destroy(mutex)
  end)
  -- todo: this operation conflicts with uv_mutex_destroy somehow
  --       since we allocate the uv_mutex_t on the libmain side, without calling this,
  --       its memory is surely leaked.
  -- C.hal_uv_mutex_destroy(addr)
  if not ok then error(err) end
end

by_pre_alloc_whole_memory()
