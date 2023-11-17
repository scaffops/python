git init
git add .
git commit -m "Initial commit"
gh repo create {{ cookiecutter.repo_name }} --{{ cookiecutter.visibility }} --source=./ --remote=upstream
git remote add origin https://github.com/{{ cookiecutter.github_username }}/{{ cookiecutter.repo_name }}.git
git push -u origin master
