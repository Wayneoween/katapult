# Only a single Transform is executed per step argument
# Transforms are matched from bottom (first) to top (last)


# Enables nested docstrings (""") by allowing to use triple single quotes. This
# Transform turns them back into triple double quotes.
Transform /^.*'''.*$/ do |string|
  string.gsub /'''/, '"""'
end
