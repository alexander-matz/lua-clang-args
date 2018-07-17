# cargs

A library that implements argument parsing suitable for writing clang/gcc
compatible wrappers in lua.
I was unable to find an existing library due to the mess that is the clang/gcc
interface.
Some options start with '-', some start with '--'. Some options have the value
directly follow the name in the same argument (-O<1/2/3>,  -std=<standard>),
others have an optional space (-I <dir>, -I<dir>).
This library is inspired by the way clang parses arguments, but implementes a
greatly simplified version.

## Example

```lua
local cargs = require 'cargs'

local app = cargs.App:new("cc", "random compiler", "<inputs>")

app:add_option(cargs.Option:new('flag', 'last', {'-'}, 'c', nil, 'Only perform compile step'))
app:add_option(cargs.Option:new('joined', 'last', {'-'}, 'O', nil, 'Optimization level', '<number>'))
app:add_option(cargs.Option:new('separate', 'once', {'-'}, 'xclang', nil, 'Pass <arg> to the compiler', '<arg>'))
app:add_option(cargs.Option:new('joined_or_separate', 'once', {'-'}, 'o', nil, 'Output file', '<file>'))

local options, arguments = app:parse()

if options['c'] then
  disable_assemble()
  disable_link()
end
set_optimization(tonumber(options['O']) or 0)
for _, file in ipairs(arguments) do
  process(file)
end

```

## Docs

- `cargs.App:new(name, description, metavar) -> App` Create a new command line parser.
  - `name` Name of the application (shown in help text).
  - `description` A short one-line description of the application (shown in
    help text).
  - `metavar` Representation of remaining arguments in help text.

- `App:add_option(option) -> nil` Add a new option to the parser.
- `App:parse(args|nil) -> options, arguments` Parse the command line arguments
  passed in args (or use globally available command line arguments).
  Return the options as a string-index table and remaining arguments as an
  array-like table.
- `App:help() -> nil` Show help.

- `cargs.Option:new(type, merge, prefixes, pattern, alias, help, metavar) -> Option` Create a new option. 
  - `type` Type of the option. One of `'flag'`, `'joined'`, `'separate'`, `'joined_or_separate'`.
  - `merge` Handling of multiple occurences of the option. One of `'flag'`,
    `'joined'`, `'joined_or_separate'`.
  - `prefixes` List of possible prefixes, defaults to `{'-', '--'}`.
  - `pattern` How to specifiy the option (follow the prefix).
  - `alias` How the option is stored after parsing. Defaults to `pattern`. Can
    be used to provide multiple patterns for the same option. E.g. `-I` without
    alias and `-isystem` with alias `I` are then both stored in `options['I']`.
  - `help` A help text explaining the option.
  - `metavar` How the value of the option is represented in the help text.

## License & libraries

MIT

cargs uses the fantastic [u-test](https://github.com/IUdalov/u-test) library for unit testing, also licensed under MIT.
