t=require("ds18b20")
t.setup(4)
addrs=t.addrs()
-- Total DS18B20 numbers, assume it is 2
print(table.getn(addrs))
-- The first DS18B20
print(t.readNumber(addrs[1]))
--print(t.readNumber(addrs[1],t.F))
--print(t.readNumber(addrs[1],t.K))
-- The second DS18B20
print(t.readNumber(addrs[2]))
--print(t.readNumber(addrs[2],t.F))
--print(t.readNumber(addrs[2],t.K))
-- Just read
print(t.readNumber())
-- Just read as fahrenheit
-- Read as values
t1, t2 = t.readNumber(addrs[2])
print(t1)
-- Don't forget to release it after use
t = nil
ds18b20 = nil
package.loaded["ds18b20"]=nil