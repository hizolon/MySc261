-- sosite
-- Эквivalent of the deobfuscated invZ script
-- Реально это демо-набор: factorial, fibonacci, факторизация,
-- XOR-строка, base64-подобное кодирование и таблица-контейнер.

local bit32 = bit32 or bit
local bxor  = bit32.bxor
local band  = bit32.band
local rshift = bit32.rshift
local lshift = bit32.lshift
local btest = bit32.btest

-- ===== 1. XOR-шифрование строк =====
local function xor_string(s, key)
    local out = {}
    for i = 1, #s do
        local a = string.byte(s, i)
        local b = string.byte(key, (i - 1) % #key + 1)
        out[i] = string.char(bxor(a, b) % 256)
    end
    return table.concat(out)
end

-- ===== 2. Кодирование в "base64-подобную" строку =====
local ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+-;<=>?@^_`{|}~"
local function encode_baseN(data)
    -- Превращаем байты в битовую строку, затем режем по 6 бит
    local bits = {}
    for i = 1, #data do
        local byte = string.byte(data, i)
        for b = 7, 0, -1 do
            bits[#bits + 1] = band(rshift(byte, b), 1)
        end
    end
    local out = {}
    for i = 1, #bits, 6 do
        local v = 0
        for j = 0, 5 do
            v = lshift(v, 1) + (bits[i + j] or 0)
        end
        out[#out + 1] = ALPHABET:sub(v + 1, v + 1)
    end
    return table.concat(out)
end

local function decode_baseN(str)
    local bits = {}
    for i = 1, #str do
        local idx = ALPHABET:find(str:sub(i, i), 1, true) - 1
        for b = 5, 0, -1 do
            bits[#bits + 1] = band(rshift(idx, b), 1)
        end
    end
    local out = {}
    for i = 1, #bits, 8 do
        local v = 0
        for j = 0, 7 do
            v = lshift(v, 1) + (bits[i + j] or 0)
        end
        out[#out + 1] = string.char(v)
    end
    return table.concat(out)
end

-- ===== 3. Факториал =====
local function factorial(n)
    if n < 0 then return nil end
    local result = 1
    for i = 2, n do
        result = result * i
    end
    return result
end

-- Рекурсивный вариант (использовался в обфускаторе)
local function factorial_rec(n)
    if n <= 1 then return 1 end
    return n * factorial_rec(n - 1)
end

-- ===== 4. Числа Фибоначчи =====
local function fibonacci(n)
    if n < 0 then return nil end
    if n == 0 then return 0 end
    if n == 1 then return 1 end
    local a, b = 0, 1
    for _ = 2, n do
        a, b = b, a + b
    end
    return b
end

-- Рекурсивный вариант
local function fibonacci_rec(n)
    if n <= 1 then return n end
    return fibonacci_rec(n - 1) + fibonacci_rec(n - 2)
end

-- ===== 5. Проверка простоты / факторизация =====
local function is_prime(n)
    if n < 2 then return false end
    if n % 2 == 0 then return n == 2 end
    local i = 3
    while i * i <= n do
        if n % i == 0 then return false end
        i = i + 2
    end
    return true
end

local function factorize(n)
    local factors = {}
    local d = 2
    while d * d <= n do
        while n % d == 0 do
            factors[#factors + 1] = d
            n = n / d
        end
        d = d + 1
    end
    if n > 1 then factors[#factors + 1] = n end
    return factors
end

-- ===== 6. Сумма / произведение таблицы =====
local function sum(t)
    local s = 0
    for _, v in ipairs(t) do s = s + v end
    return s
end

local function product(t)
    local p = 1
    for _, v in ipairs(t) do p = p * v end
    return p
end

-- ===== 7. "Контейнер" — таблица с полями, как в оригинале =====
local function make_container(e, f, g, i, o, m)
    return {
        [0x2d07] = e,   -- поле e
        [0x44cd] = f,   -- поле f
        [0xe648] = g,   -- поле g
        [0x6841] = i,   -- поле i
        [0xbb5]  = o,   -- поле o
        [0x8da3] = m,   -- поле m
        [0x996e] = 0,
        [0x2ac9] = 0,
    }
end

-- ===== 8. Демонстрация (то, что реально делает скрипт при запуске) =====
local function main()
    print("=== invZ demo ===")

    -- Факториалы
    for n = 0, 10 do
        print(string.format("factorial(%d) = %d", n, factorial(n)))
    end

    -- Фибоначчи
    for n = 0, 15 do
        print(string.format("fib(%d) = %d", n, fibonacci(n)))
    end

    -- Простые числа до 50
    local primes = {}
    for n = 2, 50 do
        if is_prime(n) then primes[#primes + 1] = n end
    end
    print("primes <= 50: " .. table.concat(primes, ", "))

    -- Факторизация
    local num = 360
    local fac = factorize(num)
    print(string.format("factorize(%d) = %s", num, table.concat(fac, " * ")))
    print(string.format("  check: product = %d, sum = %d", product(fac), sum(fac)))

    -- XOR-строка
    local secret = xor_string("Hello, Lua!", "key")
    print("xor('Hello, Lua!', 'key') = " .. encode_baseN(secret))

    -- Контейнер
    local c = make_container(1, 2, 3, 4, 5, 6)
    print("container.e = " .. c[0x2d07])
    print("container.m = " .. c[0x8da3])
end

main()
