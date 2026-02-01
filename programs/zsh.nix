{
  lib,
  config,
  pkgs,
  ...
}:
let

in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      strategy = [
        "history"
      ];
    };
    syntaxHighlighting.enable = true;

    # Zsh options
    defaultKeymap = "emacs";

    autocd = true;

    historySubstringSearch.enable = true;

    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreAllDups = true;
      extended = true;
      share = true;
      expireDuplicatesFirst = true;
    };

    # Completion options (enableCompletion = true handles the autoload)
    # Completion styling moved to initContent

    completionInit = ''
      autoload -U compinit
      compinit -C -d ${config.xdg.cacheHome}/zsh/zcompdump
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "ansible"
        "podman"
        "fzf"
        "git"
        "git-auto-fetch"
        "gnu-utils"
        "helm"
        "history-substring-search"
        "kubectl"
        "rsync"
        "sudo"
        "terraform"
        "tig"
        "vi-mode"
        "web-search"
        "vim-interaction"
        "history"
      ];
      extraConfig = "";
      custom = "${config.home.homeDirectory}/.oh-my-zsh/custom/";
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
    ];

    # Local variables
    localVariables = {
      WORDCHARS = "*?_-~=!#$%^(){}<>"; # zsh default minus . [ ] / & ; \ so they break words
    };

    # Shell aliases
    shellAliases = {
      # Zen Browser — open with profile picker
      zen = "open -a 'Zen Browser' --args --ProfileManager";

      # Basic aliases
      cp = "cp -i";
      df = "duf"; # Use duf instead of df
      free = "free -m";
      vim = "nvim";

      # Git
      gitu = "git add . && git commit && git push";

      # OpenTofu/Terraform
      tf = "tofu";

      # VPN
      vpnup = "nmcli connection up vpn --ask";
      vpndown = "nmcli connection down vpn";

      # OpenShift/kubectl
      op = "oc project";
      oc = "kubectl"; # Use kubectl as oc (OpenShift CLI not installed)

      # PowerShell container
      pwaz = "podman run -it -v homevol:/root --rm docker.io/venc0r/pwsh";

      # Azure DevOps PR creation
      azdopr = "az repos pr create | yq \".repository.webUrl + \\\"/pullrequest/\\\" + .pullRequestId\"";

      # JFrog
      jf = "jfrog";

      # Azure account switcher
      aza = "az account list --query '[].name' -o tsv | fzf | xargs -I {} az account set --subscription \"{}\"";


      # Fun
      nano = "curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash";
    };

    initContent =
      let
        zshOptions = lib.mkBefore ''
          # Homebrew (macOS Apple Silicon)
          [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

          # Zsh shell options
          setopt correct                    # Auto correct mistakes
          setopt extendedglob               # Extended globbing
          setopt nocaseglob                 # Case insensitive globbing
          setopt rcexpandparam              # Array expansion with parameters
          setopt nocheckjobs                # Don't warn about running processes when exiting
          setopt numericglobsort            # Sort filenames numerically when it makes sense
          setopt nobeep                     # No beep
        '';

        zshConfigEarlyInit = lib.mkOrder 500 ''
          # p10k instant prompt must be first — before any output or slow init
          if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          source $HOME/.p10k.zsh
        '';

        fastCompinit = lib.mkOrder 560 ''
          compinit() {
            local -a args
            args=(''${@/-i/-C})
            args=(''${args/-u/-C})
            unfunction compinit
            autoload -U compinit
            compinit ''${args}
          }
        '';

        keybindings = lib.mkOrder 550 ''
          # Word navigation and editing
          bindkey '^[[7~' beginning-of-line        # Home key
          bindkey '^[[H' beginning-of-line         # Home key
          bindkey '^[[8~' end-of-line              # End key
          bindkey '^[[F' end-of-line               # End key
          bindkey '^[[2~' overwrite-mode           # Insert key
          bindkey '^[[3~' delete-char              # Delete key
          bindkey '^[[C' forward-char              # Right key
          bindkey '^[[D' backward-char             # Left key
          bindkey '^[Oc' forward-word              # Ctrl+Right
          bindkey '^[Od' backward-word             # Ctrl+Left
          bindkey '^[[1;5D' backward-word          # Ctrl+Left (alternate)
          bindkey '^[[1;5C' forward-word           # Ctrl+Right (alternate)
          bindkey '^H' backward-kill-word          # Ctrl+Backspace
          bindkey '^[[Z' undo                      # Shift+Tab
        '';

        customFunctions = ''
          # Fix fzf-history-widget keybinding in Vi mode
          # The vi-mode plugin overwrites the default binding
          bindkey -M viins '^R' fzf-history-widget
          bindkey -M vicmd '^R' fzf-history-widget

          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
          zstyle ':completion:*' rehash true
          zstyle ':completion:*' accept-exact '*(N)'
          zstyle ':completion:*' use-cache on
          zstyle ':completion:*' cache-path ${config.xdg.cacheHome}/zsh

          autoload -U +X bashcompinit && bashcompinit
          complete -o nospace -C ${pkgs.vault}/bin/vault vault

          _gen_completion() {
            local cmd=$1 file=$2
            if [[ ! -f "$file" || "$file" -ot "$(command -v $cmd)" ]]; then
              mkdir -p "$(dirname "$file")"
              ''${@:3} > "$file"
            fi
            source "$file"
          }
          _gen_completion gh    ${config.xdg.cacheHome}/zsh/completion_gh    ${pkgs.gh}/bin/gh completion -s zsh
          _gen_completion tkn   ${config.xdg.cacheHome}/zsh/completion_tkn   ${pkgs.tektoncd-cli}/bin/tkn completion zsh
          _gen_completion stern ${config.xdg.cacheHome}/zsh/completion_stern ${pkgs.stern}/bin/stern --completion zsh

          # ============================================================================
          # CUSTOM FUNCTIONS
          # ============================================================================

          # Quick cheat sheet lookup
          wtf() { ${pkgs.curl}/bin/curl https://cheat.sh/$1 }

          # Get Kubernetes API versions (for Helm compatibility checks)
          getApiVersions() {
            tmp=$(${pkgs.coreutils}/bin/mktemp -d)
            ${pkgs.coreutils}/bin/mkdir -p "''${tmp}/templates" && pushd "''${tmp}" > /dev/null

            ${pkgs.coreutils}/bin/cat << YAML >> Chart.yaml
          apiVersion: v2
          name: pipelines
          version: 0.1.0
          YAML

            ${pkgs.coreutils}/bin/cat << YAML >> templates/cm.yaml
          apiVersion: v1
          kind: ConfigMap
          metadata:
            name: test
          data:
            key: {{ .Capabilities.APIVersions }}
          YAML

            ${pkgs.kubernetes-helm}/bin/helm install test --dry-run .| ${pkgs.coreutils}/bin/tail -n2 | ${pkgs.yq-go}/bin/yq '.key.[]' | ${pkgs.gnused}/bin/sed 's/\([a-zA-Z0-9/.]*\)/--api-versions=\1/g'
            popd > /dev/null
            ${pkgs.coreutils}/bin/rm -rf ''${tmp}
          }

          # Azure Container Apps helpers
          rtzx() {
            export RG=$1
          }

          rtz() {
            local func=$1
            shift 1
            case "$func" in
              "logs") local app=$1
                shift 1
                az containerapp logs show -n $app -g $RG $@
              ;;
              "exec") local app=$1
                shift 1
                az containerapp exec -n $app -g $RG --command $@
              ;;
              *) az containerapp --help
              ;;
            esac
          }

          # OpenCode session browser
          sessions() {
            local days_ago=''${1:-0}
            local target_date=$(${pkgs.coreutils}/bin/date -d "$days_ago days ago" +%Y-%m-%d)
            ${pkgs.findutils}/bin/find ~/.local/share/opencode/storage/session -name "ses_*.json" -type f -exec sh -c 'file_date=$(date -d @$(${pkgs.jq}/bin/jq -r ".time.updated / 1000" "$1") +%Y-%m-%d); if [ "$file_date" = "'"$target_date"'" ]; then ${pkgs.jq}/bin/jq -r "\"[\((.time.updated / 1000) | strftime(\"%H:%M\"))] \(.directory) | \(.title)\"" "$1"; fi' _ {} \; | ${pkgs.coreutils}/bin/sort -rn
          }

          # ============================================================================
          # WORK-SPECIFIC FUNCTIONS (Kubernetes/Tekton/Infrastructure)
          # ============================================================================

          # Kubernetes cluster switcher and workspace configurator
          cl() {
            case "$1" in
              n100) subdomain="n100"
                cluster_name="n100"
                workspaces=('infrastructure' 'argocd-infra' 'vault')
                ;;
              nsc) subdomain="nsc"
                cluster_name="nsc"
                workspaces=('argocd-infra' 'vault')
                ;;
              *) echo "Usage >> cl n100|nsc << " && return 1
                ;;
            esac

            ${pkgs.kubectl}/bin/kubectl config use-context "''${cluster_name}"

            export KUBE_TOKEN=$(${pkgs.yq-go}/bin/yq ".users[] | select(.name == \"''${cluster_name}\") | .user.token" "''${HOME}/.kube/config")
            export KUBE_HOST=$(${pkgs.yq-go}/bin/yq ".clusters[] | select(.name == \"''${cluster_name}\") | .cluster.server" "''${HOME}/.kube/config")
            export KUBE_INSECURE="true"
            export TF_VAR_cloud="''${cluster_name}"

            unset VAULT_ADDR
            export VAULT_ADDR="https://openbao.''${subdomain}.v3nc.org"
            ${pkgs.coreutils}/bin/ln -sf "''${HOME}/.vault-token-''${cluster_name}" "''${HOME}/.vault-token"

            export AWS_ACCESS_KEY_ID=$(${pkgs.rbw}/bin/rbw get garage.n100.v3nc.org --field terraform_access_key)
            export AWS_SECRET_ACCESS_KEY=$(${pkgs.rbw}/bin/rbw get garage.n100.v3nc.org --field terraform_secret_key)
            export VAULT_TOKEN=$(${pkgs.rbw}/bin/rbw get openbao-''${cluster_name})

            IaC="''${HOME}/Documents/git/jma/venc0r/IaC"
            if [[ ''${USER} == "jma" ]]; then
              IaC="''${HOME}/Documents/git/gitea/devops/IaC"
            fi

            if [[ $(pwd) != "''${IaC}" ]]; then
              popme=$(pwd)
              pushd "''${IaC}/terraform" > /dev/null
            fi
            for d in "''${workspaces[@]}"; do
              pushd "''${IaC}/terraform/''${d}" > /dev/null
              ${pkgs.opentofu}/bin/tofu init -reconfigure -upgrade > /dev/null
              ${pkgs.opentofu}/bin/tofu workspace select "''${cluster_name}" || echo "failed to select workspace on ''${IaC}/terraform/''${d}"
              popd > /dev/null
            done

            if [[ -n "''${popme}" ]]; then
              popd > /dev/null || cd "''${popme}"
            fi
          }

          # Run Renovate job in Kubernetes
          runreno() {
            ${pkgs.kubectl}/bin/kubectl delete job renovateme -n renovate --context ''${2:-hcp-oidc}
            if [[ $# -eq 0 ]]; then
              ${pkgs.kubectl}/bin/kubectl create job --from cj/renovate -n renovate renovateme --context ''${2:-hcp-oidc}
              ${pkgs.stern}/bin/stern -n renovate --context ''${2:-hcp-oidc} renovateme-
            else
              ${pkgs.kubectl}/bin/kubectl get cj renovate -o yaml -n renovate --context ''${2:-hcp-oidc} |\
                ${pkgs.yq-go}/bin/yq .spec.jobTemplate |\
                ${pkgs.yq-go}/bin/yq ".spec.template.spec.containers[0].env += {\"name\": \"RENOVATE_AUTODISCOVER_FILTER\", \"value\": \"''${1}\"}" |\
                ${pkgs.yq-go}/bin/yq ".spec.template.spec.containers[0].env += {\"name\": \"LOG_LEVEL\", \"value\": \"DEBUG\"}" |\
                ${pkgs.yq-go}/bin/yq '.metadata.name = "renovateme"'|\
                ${pkgs.yq-go}/bin/yq '.kind = "Job"' |\
                ${pkgs.yq-go}/bin/yq '.apiVersion = "batch/v1"' |\
                ${pkgs.kubectl}/bin/kubectl apply -n renovate --context ''${2:-hcp-oidc} -f -
                ${pkgs.stern}/bin/stern -n renovate --context ''${2:-hcp-oidc} renovateme-
            fi
          }

          # Unseal OpenBao/Vault
          unseal() {
            case "$1" in
              n100)
                local limit="n100"
                local workspace_name="n100"
                ;;
              os)
                local limit="openstack"
                local workspace_name="openstack"
                ;;
              ws)
                local limit="wavestack"
                local workspace_name="wavestack"
                ;;
              *) echo "Usage >> unseal os|ws|n100 << " && return 1
                ;;
            esac
            local tags="openbao-unseal"
            tknPipelineRunAnsible -p cluster-setup.yml -t ''${tags} -l ''${limit} -w ''${workspace_name} -tf terraform
          }

          # Patch management
          patch() {
            case "$1" in
              archlinux)
                local playbook="archlinux-setup.yml"
                local limit="archlinux"
              ;;
              os)
                local playbook="cluster-setup.yml"
                local limit="arch-$1"
                local workspace_name="openstack"
              ;;
              ws)
                local playbook="cluster-setup.yml"
                local limit="arch-$1"
                local workspace_name="wavestack"
              ;;
              *)
                echo "Usage >> unseal os|ws|archlinux << " && return 1
              ;;
            esac
            tknPipelineRunAnsible -p ''${playbook} -l ''${limit} -w ''${workspace_name}
          }

          # Tekton PipelineRun: Patchday
          tknPipelineRunPatchday() {
            case "$1" in
              os)
                local workspace_name="openstack"
              ;;
              ws)
                local workspace_name="wavestack"
            esac

            local tmp="$(${pkgs.coreutils}/bin/mktemp).yml"
            ${pkgs.coreutils}/bin/cat << EOF >> ''${tmp}
          spec:
            accessModes:
              - ReadWriteOnce
            volumeMode: Filesystem
            resources:
              requests:
                storage: 100Mi
          EOF

            ${pkgs.tektoncd-cli}/bin/tkn pipeline start -c n100 patchday \
              --param git_url=ssh://git@git.v3nc.org:2223/devOops/IaC.git \
              --param workspace_name=''${workspace_name} \
              --workspace name=sources,volumeClaimTemplateFile=''${tmp} \
              --workspace name=ssh-directory,secret=git-ssh-credential \
              --workspace name=patchlist,config=patchlist \
              --namespace tekton-pipelines \
              --showlog

            ${pkgs.coreutils}/bin/rm ''${tmp}
          }

          # Tekton PipelineRun: OpenTofu
          tknPipelineRunTofu() {
            set -x
            case "$1" in
              os)
                local workspace_name="openstack"
              ;;
              ws)
                local workspace_name="wavestack"
              ;;
              n100)
                local workspace_name="n100"
              ;;
              *)
                echo "no known workspace"
                return 1
            esac

            local path=$2
            local tmp="$(${pkgs.coreutils}/bin/mktemp).yml"
            ${pkgs.coreutils}/bin/cat << EOF >> ''${tmp}
          spec:
            accessModes:
              - ReadWriteOnce
            volumeMode: Filesystem
            resources:
              requests:
                storage: 100Mi
          EOF

            ${pkgs.tektoncd-cli}/bin/tkn pipeline start -c n100 tofu \
              --param git_url=ssh://git@git.v3nc.org:2223/devOops/IaC.git \
              --param path=''${path} \
              --param tf_action=plan \
              --param workspace_name=''${workspace_name} \
              --workspace name=sources,volumeClaimTemplateFile=''${tmp} \
              --workspace name=ssh-directory,secret=git-ssh-credential \
              --workspace name=plans,claimName=tofu \
              --namespace tekton-pipelines \
              --showlog

            ${pkgs.coreutils}/bin/rm ''${tmp}
          }

          # Tekton PipelineRun: IaC
          tknPipelineRunIaC() {
            case "$1" in
              os)
                local workspace_name="openstack"
                local playbook="cluster-setup.yml"
              ;;
              ws)
                local workspace_name="wavestack"
                local playbook="cluster-setup.yml"
            esac

            local tmp="$(${pkgs.coreutils}/bin/mktemp).yml"
            ${pkgs.coreutils}/bin/cat << EOF >> ''${tmp}
          spec:
            accessModes:
              - ReadWriteOnce
            volumeMode: Filesystem
            resources:
              requests:
                storage: 100Mi
          EOF

            ${pkgs.tektoncd-cli}/bin/tkn pipeline start -c n100 tofu \
              --param git_url=ssh://git@git.v3nc.org:2223/devOops/IaC.git \
              --param path=terraform \
              --param tf_action=plan \
              --param workspace_name=''${workspace_name} \
              --workspace name=sources,volumeClaimTemplateFile=''${tmp} \
              --workspace name=ssh-directory,secret=git-ssh-credential \
              --workspace name=plans,claimName=tofu \
              --namespace tekton-pipelines \
              --showlog

            ${pkgs.coreutils}/bin/rm ''${tmp}
          }

          # Tekton PipelineRun: Ansible
          tknPipelineRunAnsible() {
            while [ "$#" -gt 0 ]; do
              case "$1" in
                -p)
                  playbook="$2"
                  shift 2
                ;;
                -t)
                  tags="$2"
                  shift 2
                ;;
                -w)
                  workspace_name="$2"
                  shift 2
                ;;
                -l)
                  limit="$2"
                  shift 2
                ;;
                -tf)
                  tf_path="$2"
                  shift 2
                ;;
              esac
            done

            local tmp="$(${pkgs.coreutils}/bin/mktemp).yml"
            ${pkgs.coreutils}/bin/cat << EOF >> ''${tmp}
          spec:
            accessModes:
              - ReadWriteOnce
            volumeMode: Filesystem
            resources:
              requests:
                storage: 100Mi
          EOF

            ${pkgs.tektoncd-cli}/bin/tkn pipeline start -c n100 ansible \
              --param git_url=ssh://git@git.v3nc.org:2223/devOops/IaC.git \
              --param git_ref=main \
              --param path=ansible \
              --param playbook=''${playbook} \
              --param limit=''${limit} \
              --param tags=''${tags} \
              --param workspace_name=''${workspace_name} \
              --param tf_path=''${tf_path} \
              --param secret=ansible \
              --workspace name=sources,volumeClaimTemplateFile=''${tmp} \
              --workspace name=ssh-directory,secret=git-ssh-credential \
              --namespace tekton-pipelines \
              --showlog

            ${pkgs.coreutils}/bin/rm ''${tmp}
          }
        '';

        zshConfig = lib.mkOrder 1000 "# Zsh configuration loaded";
      in
      lib.mkMerge [
        zshOptions
        zshConfigEarlyInit
        fastCompinit
        keybindings
        customFunctions
        zshConfig
      ];
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";

    # Colored man pages
    LESS_TERMCAP_mb = "$(printf '\e[01;32m')";
    LESS_TERMCAP_md = "$(printf '\e[01;32m')";
    LESS_TERMCAP_me = "$(printf '\e[0m')";
    LESS_TERMCAP_se = "$(printf '\e[0m')";
    LESS_TERMCAP_so = "$(printf '\e[01;47;34m')";
    LESS_TERMCAP_ue = "$(printf '\e[0m')";
    LESS_TERMCAP_us = "$(printf '\e[01;36m')";
    LESS = "-R";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/bin/scripts"
    "$HOME/.local/bin/ps1"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.krew/bin"
    "$HOME/.local/share/gem/ruby/3.3.0/bin"
  ];
}
