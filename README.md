# github-actions-playground
sandbox for verifying actions workflow

## testing workflow

### install act
```
brew install act
```

### start docker daemon on your pc

### initial setup
```
$ act
INFO[0000] Using docker host 'unix:///var/run/docker.sock', and daemon socket 'unix:///var/run/docker.sock' 
WARN  ⚠ You are using Apple M-series chip and you have not specified container architecture, you might encounter issues while running act. If so, try running it with '--container-architecture linux/amd64'. ⚠  
? Please choose the default image you want to use with act:
  - Large size image: ca. 17GB download + 53.1GB storage, you will need 75GB of free disk space, snapshots of GitHub Hosted Runners without snap and pulled docker images
  - Medium size image: ~500MB, includes only necessary tools to bootstrap actions and aims to be compatible with most actions
  - Micro size image: <200MB, contains only NodeJS required to bootstrap actions, doesn't work with all actions
<snip>
[mockup-terraform-plan-on-pull-request/get_targets]   ✅  Success - Main organize and convert diff list to json
[mockup-terraform-plan-on-pull-request/get_targets] Cleaning up container for job get_targets
[mockup-terraform-plan-on-pull-request/get_targets] 🏁  Job succeeded
```

### list workflows
```
❯ act -l
Stage  Job ID       Job name     Workflow name                          Workflow file              Events      
0      get_targets  get_targets  mockup-terraform-plan-on-pull-request  _mock_terraform_plan.yaml  pull_request
```

### test specified workflow
```
act --container-architecture linux/amd64 -j <job_name>
```
