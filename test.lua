local cargs = require("cargs")
local test = require("u-test")

function string:split()
  words = {}
  for word in self:gmatch("%S+") do
    words[#words+1] = word
  end
  return words
end

test.flag.simple = function ()
  local err, val, idx = cargs.parse_flag("-f", 1, ("-f"):split())
  test.is_nil(err)
  test.is_true(val)
  test.equal(idx, 2)
end

test.flag.fail_prefix = function ()
  local err, val, idx = cargs.parse_flag("-f", 1, ("--f"):split())
  test.is_nil(err)
  test.is_nil(val)
  test.equal(idx, 1)
end

test.flag.fail_suffix = function ()
  local err, val, idx = cargs.parse_flag("-f", 1, ("-frest"):split())
  test.is_nil(err)
  test.is_nil(val)
  test.equal(idx, 1)
end



test.joined.succeed_empty = function ()
  local err, val, idx = cargs.parse_joined("-j=", 1, ("-j="):split())
  test.is_nil(err)
  test.equal(val, "")
  test.equal(idx, 2)
end

test.joined.succeed_value = function ()
  local err, val, idx = cargs.parse_joined("-j=", 1, ("-j=value"):split())
  test.is_nil(err)
  test.equal(val, "value")
  test.equal(idx, 2)
end

test.joined.fail = function ()
  local err, val, idx = cargs.parse_joined("-j=", 1, ("-jvalue"):split())
  test.is_nil(err)
  test.is_nil(val)
  test.equal(idx, 1)
end

test.joined.succeed_empty_rest = function ()
  local err, val, idx = cargs.parse_joined("-j=", 1, ("-j= value"):split())
  test.is_nil(err)
  test.equal(val, "")
  test.equal(idx, 2)
end



test.separate.succeed = function ()
  local err, val, idx = cargs.parse_separate("-s", 1, ("-s val"):split())
  test.is_nil(err)
  test.equal(val, "val")
  test.equal(idx, 3)
end

test.separate.fail_suffix = function ()
  local err, val, idx = cargs.parse_separate("-s", 1, ("-ssuffix val"):split())
  test.is_nil(err)
  test.is_nil(val)
  test.equal(idx, 1)
end

test.separate.err_no_value = function ()
  local err, val, idx = cargs.parse_separate("-s", 1, ("-s"):split())
  test.equal(err, "requires value")
end



test.joined_or_separate.succeed_joined = function ()
  local err, val, idx = cargs.parse_joined_or_separate("-jos", 1, ("-josvalue"):split())
  test.is_nil(err)
  test.equal(val, "value")
  test.equal(idx, 2)
end

test.joined_or_separate.succeed_separate = function ()
  local err, val, idx = cargs.parse_joined_or_separate("-jos", 1, ("-jos value"):split())
  test.is_nil(err)
  test.equal(val, "value")
  test.equal(idx, 3)
end

test.joined_or_separate.err_no_value = function ()
  local err, val, idx = cargs.parse_joined_or_separate("-jos", 1, ("-jos"):split())
  test.equal(err, "requires value")
end



test.option.simple = function ()
  local option = cargs.Option:new('joined', nil, nil, 'o', 'output file') 
  local err, akk, idx = nil, nil, 1
  local args = ("-oasdf"):split()

  err, akk, idx = option:try(akk, idx, args)
  test.is_nil(err)
  test.equal(akk, "asdf")
  test.equal(idx, 2)
end

test.option.fail = function ()
  local option = cargs.Option:new('joined', nil, nil, 'o', 'output file') 
  local err, akk, idx = nil, nil, 1

  local args = ("-asdf"):split()

  err, akk, idx = option:try(akk, idx, args)
  test.is_nil(err)
  test.is_nil(akk)
  test.equal(idx, 1)
end

test.option.combine_default = function ()
  local option = cargs.Option:new('joined', nil, nil, 'o', 'output file') 
  local err, akk, idx = nil, nil, 1

  local args = ("-o1 -o2"):split()
  err, akk, idx = option:try(akk, idx, args)
  test.is_nil(err)
  test.equal(akk, "1")
  test.equal(idx, 2)

  err, akk, idx = option:try(akk, idx, args)
  test.equal(err, "can only be used once")
  test.is_nil(akk)
  test.is_nil(idx)
end

test.option.once = function ()
  local option = cargs.Option:new('joined', 'once', nil, 'o', 'output file') 
  local err, akk, idx = nil, nil, 1

  local args = ("-o1 -o2"):split()

  err, akk, idx = option:try(akk, idx, args)
  test.is_nil(err)
  test.equal(akk, "1")
  test.equal(idx, 2)

  err, akk, idx = option:try(akk, idx, args)
  test.equal(err, "can only be used once")
  test.is_nil(akk)
  test.is_nil(idx)
end

test.option.last = function ()
  local option = cargs.Option:new('joined', 'last', nil, 'o', 'output file') 
  local err, akk, idx = nil, nil, 1

  local args = ("-o1 -o2"):split()

  err, akk, idx = option:try(akk, idx, args)
  test.is_nil(err)
  test.equal(akk, "1")
  test.equal(idx, 2)

  err, akk, idx = option:try(akk, idx, args)
  test.is_nil(err)
  test.equal(akk, "2")
  test.equal(idx, 3)
end


test.option.list = function ()
  local option = cargs.Option:new('joined', 'list', nil, 'o', 'output file') 
  local err, akk, idx = nil, nil, 1

  local args = ("-o1 -o2"):split()

  err, akk, idx = option:try(akk, idx, args)
  test.is_nil(err)
  test.is_table(akk)
  test.equal(#akk, 1)
  test.equal(akk[1], '1')
  test.equal(idx, 2)

  err, akk, idx = option:try(akk, idx, args)
  test.is_nil(err)
  test.is_table(akk)
  test.equal(#akk, 2)
  test.equal(akk[1], '1')
  test.equal(akk[2], '2')
  test.equal(idx, 3)
end

test.app.parse = function ()
  local app = cargs.App:new("cc", "random compiler", "<inputs>")
  app:add_option(cargs.Option:new('flag', 'last', {'-'}, 'c', nil, 'Only perform compile step'))
  app:add_option(cargs.Option:new('joined', 'last', {'-'}, 'O', nil, 'Optimization level', '<number>'))
  app:add_option(cargs.Option:new('separate', 'once', {'-'}, 'xclang', nil, 'Pass <arg> to the compiler', '<arg>'))
  app:add_option(cargs.Option:new('joined_or_separate', 'once', {'-'}, 'o', nil, 'Output file', '<file>'))

  args = ("-c -O1 file1 -xclang someargument -obinary file2 -- -notanoption"):split()
  options, arguments = app:parse(args)
  test.is_table(options)
  test.is_table(arguments)

  test.equal(options['c'], true)
  test.equal(options['O'], '1')
  test.equal(options['xclang'], 'someargument')
  test.equal(options['o'], 'binary')

  test.equal(#arguments, 3)
  test.equal(arguments[1], 'file1')
  test.equal(arguments[2], 'file2')
  test.equal(arguments[3], '-notanoption')
end

test.summary()

