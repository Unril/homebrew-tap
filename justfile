# Format workflow YAML, markdown, and Ruby formula
format:
    prettier --write '.github/**/*.yml' '*.md'
    rufo Formula/; test $? -le 3
