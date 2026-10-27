--[[
    ABV_Delta.lua — Roblox/Luau-эквивалент скрипта из АБВ.txt
    Совместим с Delta Executor (buffer, bit32, loadstring, getfenv, coroutine).

    ВАЖНО:
    - Это VM-интерпретатор, а не сам «инвиз». Payload зашит в PACKED_DATA.
    - Запуск незнакомых обфусцированных скриптов может быть опасен.
    - Использование инжекторов нарушает ToS Roblox.
]]

-- ============================================================================
-- 1. БАЗОВЫЕ УТИЛИТЫ
-- ============================================================================
local bit32   = bit32
local bxor    = bit32.bxor
local band    = bit32.band
local bor     = bit32.bor
local bnot    = bit32.bnot
local lshift  = bit32.lshift
local rshift  = bit32.rshift
local lrotate = bit32.lrotate
local rrotate = bit32.rrotate

-- ============================================================================
-- 2. БУФЕР
--    В Luau есть нативный buffer; fallback — на строках.
-- ============================================================================
local Buf = {}
Buf.__index = Buf

function Buf.new(size)
    if buffer and buffer.create then
        return setmetatable({ h = buffer.create(size or 0), size = size or 0 }, Buf)
    end
    return setmetatable({ h = string.rep("\0", size or 0), size = size or 0 }, Buf)
end

function Buf.fromString(s)
    if buffer and buffer.fromstring then
        return setmetatable({ h = buffer.fromstring(s), size = #s }, Buf)
    end
    return setmetatable({ h = s, size = #s }, Buf)
end

function Buf:toString()
    if buffer and buffer.tostring then return buffer.tostring(self.h) end
    return self.h
end

function Buf:len()
    if buffer and buffer.len then return buffer.len(self.h) end
    return #self.h
end

function Buf:readU8(o)
    if buffer and buffer.readu8 then return buffer.readu8(self.h, o) end
    return string.byte(self.h, o + 1) or 0
end

function Buf:readI8(o)
    if buffer and buffer.readi8 then return buffer.readi8(self.h, o) end
    return string.unpack("i1", self.h, o + 1)
end

function Buf:readU16(o)
    if buffer and buffer.readu16 then return buffer.readu16(self.h, o) end
    return string.unpack("<I2", self.h, o + 1)
end

function Buf:readU32(o)
    if buffer and buffer.readu32 then return buffer.readu32(self.h, o) end
    return string.unpack("<I4", self.h, o + 1)
end

function Buf:readI32(o)
    if buffer and buffer.readi32 then return buffer.readi32(self.h, o) end
    return string.unpack("<i4", self.h, o + 1)
end

function Buf:readF32(o)
    if buffer and buffer.readf32 then return buffer.readf32(self.h, o) end
    return string.unpack("<f", self.h, o + 1)
end

function Buf:readF64(o)
    if buffer and buffer.readf64 then return buffer.readf64(self.h, o) end
    return string.unpack("<d", self.h, o + 1)
end

function Buf:readString(o, n)
    if buffer and buffer.readstring then return buffer.readstring(self.h, o, n) end
    return self.h:sub(o + 1, o + n)
end

function Buf:writeU8(o, v)
    if buffer and buffer.writeu8 then return buffer.writeu8(self.h, o, v) end
    self.h = self.h:sub(1, o) .. string.char(v % 256) .. self.h:sub(o + 2)
end

function Buf:writeU32(o, v)
    if buffer and buffer.writeu32 then return buffer.writeu32(self.h, o, v) end
    self.h = self.h:sub(1, o) .. string.pack("<I4", v) .. self.h:sub(o + 5)
end

function Buf:writeF32(o, v)
    if buffer and buffer.writef32 then return buffer.writef32(self.h, o, v) end
    self.h = self.h:sub(1, o) .. string.pack("<f", v) .. self.h:sub(o + 5)
end

function Buf:writeF64(o, v)
    if buffer and buffer.writef64 then return buffer.writef64(self.h, o, v) end
    self.h = self.h:sub(1, o) .. string.pack("<d", v) .. self.h:sub(o + 9)
end

function Buf:copy(dstOff, src, srcOff, n)
    if buffer and buffer.copy then return buffer.copy(self.h, dstOff, src.h, srcOff, n) end
    local chunk = src.h:sub(srcOff + 1, srcOff + n)
    self.h = self.h:sub(1, dstOff) .. chunk .. self.h:sub(dstOff + n + 1)
end

function Buf:fill(off, val, n)
    if buffer and buffer.fill then return buffer.fill(self.h, off, val, n) end
    self.h = self.h:sub(1, off) .. string.rep(string.char(val), n) .. self.h:sub(off + n + 1)
end

-- ============================================================================
-- 3. ДЕКОДЕРЫ
-- ============================================================================
local ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+-;<=>?@^_`{|}~"

local function xorString(s, key)
    local out = table.create(#s)
    for i = 1, #s do
        out[i] = string.char(bxor(s:byte(i), key:byte((i - 1) % #key + 1)) % 256)
    end
    return table.concat(out)
end

local function decodeBaseN(data)
    local bits = table.create(#data * 8)
    for i = 1, #data do
        local b = data:byte(i)
        for k = 7, 0, -1 do
            bits[#bits + 1] = band(rshift(b, k), 1)
        end
    end
    local out = table.create(math.floor(#bits / 6))
    for i = 1, #bits, 6 do
        local v = 0
        for j = 0, 5 do v = lshift(v, 1) + (bits[i + j] or 0) end
        out[#out + 1] = ALPHABET:sub(v + 1, v + 1)
    end
    return table.concat(out)
end

-- ============================================================================
-- 4. СОСТОЯНИЕ VM
-- ============================================================================
local function newState(program)
    return {
        pc        = 0,
        stack     = {},
        constants = {},
        globals   = {},
        upvalues  = {},
        varargs   = {},
        program   = program,
        closed    = false,
    }
end

-- ============================================================================
-- 5. ОПКОДЫ
-- ============================================================================
local Ops = {}

function Ops.LOADK(s, a)      s.stack[#s.stack + 1] = s.constants[a] end
function Ops.LOADNIL(s)      s.stack[#s.stack + 1] = nil end
function Ops.MOVE(s, d, src) s.stack[d] = s.stack[src] end
function Ops.ADD(s, a, b)    s.stack[#s.stack + 1] = (s.stack[a] or 0) + (s.stack[b] or 0) end
function Ops.SUB(s, a, b)    s.stack[#s.stack + 1] = (s.stack[a] or 0) - (s.stack[b] or 0) end
function Ops.MUL(s, a, b)    s.stack[#s.stack + 1] = (s.stack[a] or 0) * (s.stack[b] or 0) end
function Ops.DIV(s, a, b)    s.stack[#s.stack + 1] = (s.stack[a] or 0) / (s.stack[b] or 0) end
function Ops.BAND(s, a, b)   s.stack[#s.stack + 1] = band(s.stack[a], s.stack[b]) end
function Ops.BXOR(s, a, b)   s.stack[#s.stack + 1] = bxor(s.stack[a], s.stack[b]) end
function Ops.BOR(s, a, b)    s.stack[#s.stack + 1] = bor(s.stack[a], s.stack[b]) end
function Ops.BNOT(s, a)      s.stack[#s.stack + 1] = bnot(s.stack[a]) end
function Ops.LSHIFT(s, a, b) s.stack[#s.stack + 1] = lshift(s.stack[a], s.stack[b]) end
function Ops.RSHIFT(s, a, b) s.stack[#s.stack + 1] = rshift(s.stack[a], s.stack[b]) end
function Ops.LROT(s, a, b)   s.stack[#s.stack + 1] = lrotate(s.stack[a], s.stack[b]) end
function Ops.RROT(s, a, b)   s.stack[#s.stack + 1] = rrotate(s.stack[a], s.stack[b]) end
function Ops.NOT(s, a)       s.stack[#s.stack + 1] = not s.stack[a] end
function Ops.LEN(s, a)       s.stack[#s.stack + 1] = #s.stack[a] end
function Ops.GETTABLE(s, d, src, key) s.stack[d] = s.stack[src][s.stack[key]] end
function Ops.SETTABLE(s, src, key, val) s.stack[src][s.stack[key]] = s.stack[val] end
function Ops.JMP(s, t)       s.pc = t end
function Ops.JMPIF(s, c, t)  if s.stack[c] then s.pc = t end end
function Ops.JMPIFNOT(s, c, t) if not s.stack[c] then s.pc = t end end

function Ops.CALL(s, fnIdx, argStart, argCount, retCount)
    local fn = s.stack[fnIdx]
    local args = table.create(argCount)
    for i = 0, argCount - 1 do args[i + 1] = s.stack[argStart + i] end
    local ok, result = pcall(fn, table.unpack(args))
    if not ok then s.closed = true; s.error = result; return end
    s.stack[#s.stack + 1] = result
end

function Ops.RETURN(s, idx) s.closed = true; s.returnValue = s.stack[idx] end
function Ops.NEWTABLE(s)    s.stack[#s.stack + 1] = {} end

function Ops.CLOSURE(s, fnIdx)
    local proto = s.constants[fnIdx]
    s.stack[#s.stack + 1] = function(...) return VM.execute(proto, { ... }) end
end

-- ============================================================================
-- 6. ГЛАВНЫЙ ЦИКЛ VM
-- ============================================================================
local VM = {}

function VM.execute(program, args)
    local s = newState(program)
    s.varargs = args or {}

    while not s.closed do
        local opcode = s.program:readU8(s.pc); s.pc = s.pc + 1
        local a = s.program:readU8(s.pc);      s.pc = s.pc + 1
        local b = s.program:readU8(s.pc);      s.pc = s.pc + 1
        local c = s.program:readU8(s.pc);      s.pc = s.pc + 1

        local handler = Ops[opcode]
        if not handler then
            s.closed = true
            s.error = "unknown opcode: " .. tostring(opcode)
            break
        end

        local ok, err = pcall(handler, s, a, b, c)
        if not ok then s.closed = true; s.error = err; break end
    end

    return s.returnValue, s.error
end

function VM.unpack(packedData, xorKey)
    local xored = xorString(packedData, xorKey)
    local decoded = decodeBaseN(xored)
    return Buf.fromString(decoded)
end

function VM.run(packedData, xorKey)
    local program = VM.unpack(packedData, xorKey)
    return VM.execute(program)
end

-- ============================================================================
-- 7. PAYLOAD
--    Сюда вставьте содержимое строки `gt` из АБВ.txt (без обрамляющих [[ ]]).
--    В оригинале это выглядит так:
--      gt=[=[LPH:Ut8fiK^!UE K[Q$c"d.qaaCN"...]=]
--    Вставьте только внутренность (между =[ и ]=).
-- ============================================================================
local PACKED_DATA = [==[
-- ВСТАВЬТЕ СЮДА СОДЕРЖИМОЕ СТРОКИ gt ИЗ АБВ.txt
-- (всё, что находится между [[= и =]])
]==]

-- Ключ XOR. В WeAreDevs-обфускаторах он собирается из таблицы Vt
-- и соседних констант. Здесь — приблизительный ключ из Vt;
-- если payload не декодируется, замените на точный (см. примечание ниже).
local XOR_KEY = "[UD^H 4<;cIJWGQU:Q&l1%s=@kV?%=`@$WkPP8-UD (N8_:>BM"

-- ============================================================================
-- 8. ЗАПУСК
-- ============================================================================
local function main()
    if #PACKED_DATA < 100 then
        warn("[ABV] PACKED_DATA не заполнен — вставьте строку gt из АБВ.txt")
        return
    end

    print("[ABV] декодирование payload...")
    local ok, result, err = pcall(VM.run, PACKED_DATA, XOR_KEY)

    if not ok then
        warn("[ABV] ошибка декодирования: " .. tostring(result))
        return
    end

    if err then
        warn("[ABV] ошибка VM: " .. tostring(err))
    else
        print("[ABV] payload выполнен успешно")
    end

    return result
end

-- Запуск в защищённом потоке, чтобы не уронить клиент
task.spawn(function()
    local ok, err = pcall(main)
    if not ok then
        warn("[ABV] fatal: " .. tostring(err))
    end
end)
