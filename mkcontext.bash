#% for key, value in context.items() %#
#% if True %#export {{key.upper()}}="{{value}}"#% endif %#
#% endfor %#