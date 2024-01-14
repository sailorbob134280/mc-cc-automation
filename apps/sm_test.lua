-- Adjust package.path to include the 'statemachine.lua' path
package.path = package.path .. ";./lib/lua-state-machine/?.lua"
package.path = package.path .. ";../lib/lua-state-machine/?.lua"

local machine = require('statemachine')

local fsm = machine.create({
  initial = 'hungry',
  events = {
    { name = 'eat',  from = 'hungry',                                to = 'satisfied' },
    { name = 'eat',  from = 'satisfied',                             to = 'full'      },
    { name = 'eat',  from = 'full',                                  to = 'sick'      },
    { name = 'rest', from = {'hungry', 'satisfied', 'full', 'sick'}, to = 'hungry'    },
}})

print(fsm.current) -- hungry
fsm:eat()
print(fsm.current) -- hungry
