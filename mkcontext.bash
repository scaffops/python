#% for key in mkcontext -%##% if False -%#
# shellcheck disable=SC1083,SC1036,SC1088
#%- endif %#
export {{key.upper()}}
{{key.upper()}}=$(cat <<- 'EOF'
{{"\t"}}{{context[key]}}
EOF
)
#%- endfor %#