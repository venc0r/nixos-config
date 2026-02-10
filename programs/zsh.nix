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
        "completion"
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
        "ssh-agent"
        "sudo"
        "terraform"
        "tig"
        "vi-mode"
        "web-search"
        "vim-interaction"
        "history"
      ];
      extraConfig = ''
        zstyle :omz:plugins:ssh-agent identities id_rsa_venc id_rsa_noris
      '';
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
      WORDCHARS = "\${WORDCHARS//[\\/[&.;]}"; # Don't consider certain characters part of the word
    };

    # Shell aliases
    shellAliases = {
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

      # OpenShift clusters (work-specific)
      ocev = "oc login https://api.os4-eval.tb.noris.de:6443 -u 804450";
      oce = "oc login https://api.os4-ewu.tb.noris.de:6443 -u 804450";
      ocq = "oc login https://api.os4-qsu.tb.noris.de:6443 -u 804450";
      ocp = "oc login https://api.os4-prod.tb.noris.de:6443 -u 804450";

      # Docker login to OpenShift registries (work-specific)
      dcev = "ocev && oc whoami -t | podman login https://default-route-openshift-image-registry.apps.os4-eval.tb.noris.de -u 804450 --password-stdin";
      dce = "oce && oc whoami -t | podman login https://default-route-openshift-image-registry.apps.os4-ewu.tb.noris.de -u 804450 --password-stdin";
      dcq = "ocq && oc whoami -t | podman login https://default-route-openshift-image-registry.apps.os4-qsu.tb.noris.de -u 804450 --password-stdin";
      dcp = "ocp && oc whoami -t | podman login https://default-route-openshift-image-registry.apps.os4-prod.tb.noris.de -u 804450 --password-stdin";

      # OpenShift/kubectl
      op = "oc project";
      oc = "kubectl"; # Use kubectl as oc (OpenShift CLI not installed)

      # PowerShell container
      pwaz = "podman run -it -v homevol:/root --rm docker.io/venc0r/pwsh";

      # Azure DevOps PR creation
      azdopr = "az repos pr create | yq \".repository.webUrl + \\\"/pullrequest/\\\" + .pullRequestId\"";

      # JFrog
      jf = "jfrog";

      # Fun
      nano = "curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash";
    };

    initContent =
      let
        zshOptions = lib.mkBefore ''
          # Zsh shell options
          setopt correct                    # Auto correct mistakes
          setopt extendedglob               # Extended globbing
          setopt nocaseglob                 # Case insensitive globbing
          setopt rcexpandparam              # Array expansion with parameters
          setopt nocheckjobs                # Don't warn about running processes when exiting
          setopt numericglobsort            # Sort filenames numerically when it makes sense
          setopt nobeep                     # No beep

          # Completion styling
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
          zstyle ':completion:*' rehash true
          zstyle ':completion:*' accept-exact '*(N)'
          zstyle ':completion:*' use-cache on
          zstyle ':completion:*' cache-path ${config.xdg.cacheHome}/zsh
        '';

        zshConfigEarlyInit = lib.mkOrder 500 ''
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          source $HOME/.p10k.zsh
          if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi 
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
          bindkey '^R' fzf-history-widget          # Ctrl+R for fzf history
        '';

        customFunctions = ''
          # Vault completion
          complete -o nospace -C ${pkgs.vault}/bin/vault vault

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
              os) subdomain="$1"
                cluster_name="openstack"
                workspaces=('infrastructure' 'argocd-infra' 'vault' 'image_upload')
                ;;
              ws) subdomain="$1"
                cluster_name="wavestack"
                workspaces=('infrastructure' 'argocd-infra' 'vault' 'image_upload')
                ;;
              garden) subdomain="cks"
                cluster_name="gardener"
                workspaces=('infrastructure' 'argocd-infra' 'vault' 'image_upload')
                ;;
              *) echo "Usage >> cl os|ws|n100|garden << " && return 1
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
          renovate() {
            ${pkgs.kubectl}/bin/kubectl delete job renovateme -n renovate --context ''${2:-wavestack}
            if [[ $# -eq 0 ]]; then
              ${pkgs.kubectl}/bin/kubectl create job --from cj/renovate -n renovate renovateme --context ''${2:-wavestack}
              ${pkgs.stern}/bin/stern -n renovate --context ''${2:-wavestack} renovateme-
            else
              ${pkgs.kubectl}/bin/kubectl get cj renovate -o yaml -n renovate --context ''${2:-wavestack} |\
                ${pkgs.yq-go}/bin/yq .spec.jobTemplate |\
                ${pkgs.yq-go}/bin/yq ".spec.template.spec.containers[0].env += {\"name\": \"RENOVATE_AUTODISCOVER_FILTER\", \"value\": \"''${1}\"}" |\
                ${pkgs.yq-go}/bin/yq ".spec.template.spec.containers[0].env += {\"name\": \"LOG_LEVEL\", \"value\": \"DEBUG\"}" |\
                ${pkgs.yq-go}/bin/yq '.metadata.name = "renovateme"'|\
                ${pkgs.yq-go}/bin/yq '.kind = "Job"' |\
                ${pkgs.yq-go}/bin/yq '.apiVersion = "batch/v1"' |\
                ${pkgs.kubectl}/bin/kubectl apply -n renovate --context ''${2:-wavestack} -f -
                ${pkgs.stern}/bin/stern -n renovate --context ''${2:-wavestack} renovateme-
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
