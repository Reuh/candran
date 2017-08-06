-- started: 2008-04-12 by Shmuel Zeigerman
-- license: public domain

local ipairs,pairs,setfenv,tonumber,loadstring,type =
  ipairs,pairs,setfenv,tonumber,loadstring,type
local tinsert, tconcat = table.insert, table.concat

local function commonerror (msg)
  return nil, ("[cmdline]: " .. msg)
end

local function argerror (msg, numarg)
  msg = msg and (": " .. msg) or ""
  return nil, ("[cmdline]: bad argument #" .. numarg .. msg)
end

local function iderror (numarg)
  return argerror("ID not valid", numarg)
end

local function idcheck (id)
  return id:match("^[%a_][%w_]*$") and true
end

--[[------------------------------------------------------------------------
Syntax:
  t_out = getparam(t_in [,options] [,params])

Parameters:
  t_in:   table - list of string arguments to be processed in order
          (usually it is the `arg' table created by the Lua interpreter).

     * if an argument begins with $, the $ is skipped and the rest is inserted
       into the array part of the output table.

     * if an argument begins with -, the rest is a sequence of variables
       (separated by commas or semicolons) that are all set to true;
            example: -var1,var2  --> var1,var2 = true,true

     * if an argument begins with !, the rest is a Lua chunk;
            example: !a=(40+3)*5;b=20;name="John";window={w=600,h=480}

     * if an argument contains =, then it is an assignment in the form
       var1,...=value (no space is allowed around the =)
         * if value begins with $, the $ is skipped, the rest is a string
                 example: var1,var2=$         --> var1,var2 = "",""
                 example: var1,var2=$125      --> var1,var2 = "125","125"
                 example: var1,var2=$$125     --> var1,var2 = "$125","$125"
         * if value is convertible to number, it is a number
                 example: var1,var2=125       --> var1,var2 = 125,125
         * otherwise it is a string
                 example: name=John           --> name = "John"

     * if an argument neither begins with one of the special characters (-,!,$),
       nor contains =, it is inserted as is into the array part of the output
       table.

  options (optional): a list of names of all command-line options and parameters
     permitted in the application; used to check that each found option
     is valid; no checks are done if not supplied.

  params (optional): a list of names of all command-line parameters required
     by the application; used to check that each required parameter is present;
     no checks are done if not supplied.

Returns:
  On success: the output table, e.g. { [1]="./myfile.txt", name="John", age=40 }
  On error: nil followed by error message string.

--]]------------------------------------------------------------------------
return function(t_in, options, params)
  local t_out = {}
  for i,v in ipairs(t_in) do
    local prefix, command = v:sub(1,1), v:sub(2)
    if prefix == "$" then
      tinsert(t_out, command)
    elseif prefix == "-" then
      for id in command:gmatch"[^,;]+" do
        if not idcheck(id) then return iderror(i) end
        t_out[id] = true
      end
    elseif prefix == "!" then
      local f, err = loadstring(command)
      if not f then return argerror(err, i) end
      setfenv(f, t_out)()
    elseif v:find("=") then
      local ids, val = v:match("^([^=]+)%=(.*)") -- no space around =
      if not ids then return argerror("invalid assignment syntax", i) end
      val = val:sub(1,1)=="$" and val:sub(2) or tonumber(val) or val
      for id in ids:gmatch"[^,;]+" do
        if not idcheck(id) then return iderror(i) end
        t_out[id] = val
      end
    else
      tinsert(t_out, v)
    end
  end
  if options then
    local lookup, unknown = {}, {}
    for _,v in ipairs(options) do lookup[v] = true end
    for k,_ in pairs(t_out) do
      if lookup[k]==nil and type(k)=="string" then tinsert(unknown, k) end
    end
    if #unknown > 0 then
      return commonerror("unknown options: " .. tconcat(unknown, ", "))
    end
  end
  if params then
    local missing = {}
    for _,v in ipairs(params) do
      if t_out[v]==nil then tinsert(missing, v) end
    end
    if #missing > 0 then
      return commonerror("missing parameters: " .. tconcat(missing, ", "))
    end
  end
  return t_out
end
