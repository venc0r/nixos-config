{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
      version = 4;
      final_space = true;
      console_title_template = "{{ .Folder }}";
      blocks = [
        {
          type = "prompt";
          alignment = "left";
          segments = [
            {
              type = "path";
              style = "plain";
              background = "#282828";
              foreground = "#00AFFF";
              template = " {{ .Path }} ";
              options = { style = "letter"; gitdir_format = "<b>%s</>"; };
            }
            {
              type = "git";
              style = "plain";
              background = "#282828";
              foreground_templates = [
                "{{ if or (.Working.Changed) (.Staging.Changed) }}#FF9248{{ end }}"
                "{{ if and (gt .Ahead 0) (gt .Behind 0) }}#ff4500{{ end }}"
                "{{ if gt .Ahead 0 }}#B388FF{{ end }}"
                "{{ if gt .Behind 0 }}#B388FF{{ end }}"
              ];
              foreground = "#b8bb26";
              template = " <#928374></> {{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }}  {{ .StashCount }}{{ end }} ";
              options = {
                branch_template = "{{ trunc 25 .Branch }}";
                fetch_status = true;
                branch_icon = " ";
                branch_identical_icon = "●";
              };
            }
            {
              type = "go";
              style = "plain";
              background = "#282828";
              foreground = "#8ED1F7";
              template = " <#928374></>  {{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }} ";
              options = { fetch_version = true; };
            }
            {
              type = "python";
              style = "plain";
              background = "#282828";
              foreground = "#FFDE57";
              template = " <#928374></>  {{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }} ";
              options = { display_mode = "files"; fetch_virtual_env = false; };
            }
            {
              type = "aws";
              style = "plain";
              foreground = "#FFA400";
              template = " <#928374></>  {{ .Profile }}{{ if .Region }}@{{ .Region }}{{ end }} ";
              foreground_templates = [
                "{{if contains \"default\" .Profile}}#FFA400{{end}}"
                "{{if contains \"jan\" .Profile}}#f1184c{{end}}"
              ];
              options = { display_default = false; };
            }
            {
              type = "root";
              style = "plain";
              background = "#282828";
              foreground = "#ffff66";
              template = " <#928374></>  ";
            }
            {
              type = "text";
              style = "plain";
              background = "#282828";
              foreground = "#83a598";
              template = "❯ ";
            }
          ];
        }
        {
          type = "rprompt";
          alignment = "right";
          segments = [
            {
              type = "status";
              style = "plain";
              background = "transparent";
              foreground = "#fb4934";
              template = " {{ .String }} <#928374></>";
              options = { always_enabled = false; };
            }
            {
              type = "executiontime";
              style = "plain";
              background = "transparent";
              foreground = "#fabd2f";
              template = " {{ .FormattedMs }} <#928374></>";
              options = { threshold = 500; style = "austin"; };
            }
            {
              type = "kubectl";
              style = "plain";
              background = "transparent";
              foreground = "#83a598";
              template = " {{ .Context }}{{ if .Namespace }}:{{ .Namespace }}{{ end }} <#928374></>";
              options = { display_error = false; parse_kubeconfig = false; };
            }
            {
              type = "terraform";
              style = "plain";
              background = "transparent";
              foreground = "#689d6a";
              template = " {{ .WorkspaceName }} <#928374></>";
            }
            {
              type = "time";
              style = "plain";
              background = "transparent";
              foreground = "#a89984";
              template = " {{ .CurrentDate | date \"15:04:05\" }} ";
            }
          ];
        }
      ];
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      strategy = [ "history" ];
    };
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";
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

    completionInit = ''
      autoload -U compinit
      compinit -C -d ${config.xdg.cacheHome}/zsh/zcompdump
    '';

    localVariables = {
      WORDCHARS = "*?_-~=!#$%^(){}<>";
    };

    shellAliases = {
      zen = if pkgs.stdenv.isDarwin then "open -a 'Zen Browser' --args --ProfileManager" else "zen-beta --ProfileManager";

      ls   = "${pkgs.eza}/bin/eza --icons --group-directories-first";
      ll   = "${pkgs.eza}/bin/eza -lh  --icons --group-directories-first --git";
      la   = "${pkgs.eza}/bin/eza -lAh --icons --group-directories-first --git";
      l    = "${pkgs.eza}/bin/eza -laAh --icons --group-directories-first --git";
      tree = "${pkgs.eza}/bin/eza --tree --icons";

      ".." = "cd ..";

      md  = "mkdir -p";
      cls = "clear";

      h   = "history";
      hs  = "history | grep";

      myip = "curl ifconfig.me";

      cp   = "cp -i";
      mv   = "mv -i";
      df   = "duf";
      free = "free -m";
      vim  = "nvim";
      vi   = "nvim";

      sed   = "${pkgs.gnused}/bin/sed";
      awk   = "${pkgs.gawk}/bin/gawk";
      grep  = "${pkgs.gnugrep}/bin/grep --color=auto";
      fgrep = "${pkgs.gnugrep}/bin/fgrep --color=auto";
      egrep = "${pkgs.gnugrep}/bin/egrep --color=auto";
      find  = "${pkgs.findutils}/bin/find";
      xargs = "${pkgs.findutils}/bin/xargs";
      tar   = "${pkgs.gnutar}/bin/tar";

      gitu = "git add . && git commit && git push";
      ga   = "git add";
      gc   = "git commit";
      gp   = "git push";
      gl   = "git pull";
      gst  = "git status";
      gd   = "git diff";
      gco  = "git checkout";
      gb   = "git branch";
      glog = "git log --oneline --decorate --graph";

      tf = "tofu";

      vpnup   = "nmcli connection up vpn --ask";
      vpndown = "nmcli connection down vpn";

      op = "oc project";
      oc = "kubectl";
      k  = "kubectl";

      pwaz   = "podman run -it -v homevol:/root --rm docker.io/venc0r/pwsh";
      azdopr = "az repos pr create | yq \".repository.webUrl + \\\"/pullrequest/\\\" + .pullRequestId\"";
      jf     = "jfrog";
      aza    = "az account list --query '[].name' -o tsv | fzf | xargs -I {} az account set --subscription \"{}\"";

      nano = "curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash";
    };

    initContent =
      let
        zshOptions = lib.mkBefore ''
          [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

          alias -g ...='../..'
          alias -g ....='../../..'
          alias -g .....='../../../..'

          setopt correct
          setopt extendedglob
          setopt nocaseglob
          setopt rcexpandparam
          setopt nocheckjobs
          setopt numericglobsort
          setopt nobeep

        '';

        keybindings = lib.mkAfter ''
          bindkey '^[[7~' beginning-of-line
          bindkey '^[[H' beginning-of-line
          bindkey '^[[1~' beginning-of-line
          bindkey '^[[8~' end-of-line
          bindkey '^[[F' end-of-line
          bindkey '^[[4~' end-of-line
          bindkey '^[[2~' overwrite-mode
          bindkey '^[[3~' delete-char
          bindkey '^[[C' forward-char
          bindkey '^[[D' backward-char
          bindkey '^[Oc' forward-word
          bindkey '^[Od' backward-word
          bindkey '^[[1;5D' backward-word
          bindkey '^[[1;5C' forward-word
          bindkey '^H' backward-kill-word
          bindkey '^[[Z' undo

          sudo-command-line() {
            [[ -z $BUFFER ]] && zle up-history
            if [[ $BUFFER == sudo\ * ]]; then
              LBUFFER="''${LBUFFER#sudo }"
            else
              LBUFFER="sudo $LBUFFER"
            fi
          }
          zle -N sudo-command-line
          bindkey '\e\e' sudo-command-line


        '';

        customFunctions = ''
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

          wtf() { ${pkgs.curl}/bin/curl https://cheat.sh/$1 }

          if [[ "$OSTYPE" == darwin* ]]; then
            vm-unlock() {
              local vm_name="''${1:-nixos-dev-avf}"
              local vm_id
              vm_id=$(osascript -e "tell application \"UTM\" to get id of virtual machine \"$vm_name\"" 2>/dev/null)
              if [[ -z "$vm_id" ]]; then echo "vm-unlock: VM '$vm_name' not found in UTM" >&2; return 1; fi
              # Already booted? (avahi mDNS answers only once the guest is up.)
              if ping -c1 -W1 -t1 nixos.local >/dev/null 2>&1; then
                echo "vm-unlock: $vm_name already up (nixos.local)"; return 0
              fi
              # Not booted -> sitting at LUKS (or off). The prompt prints once and
              # can't be recaught after the fact, so force a fresh boot and attach
              # the serial reader before it appears.
              if [[ "$(osascript -e "tell application \"UTM\" to get status of virtual machine id \"$vm_id\"")" == "started" ]]; then
                osascript -e "tell application \"UTM\" to stop virtual machine id \"$vm_id\" by force" >/dev/null 2>&1
                while [[ "$(osascript -e "tell application \"UTM\" to get status of virtual machine id \"$vm_id\"")" != "stopped" ]]; do sleep 2; done
              fi
              osascript -e "tell application \"UTM\" to start virtual machine id \"$vm_id\"" >/dev/null
              sleep 4
              local pty
              pty=$(osascript -e "tell application \"UTM\" to get address of first serial port of virtual machine id \"$vm_id\"")
              local log="/tmp/vm-unlock.log"
              pkill -f "cat $pty" 2>/dev/null
              /bin/stty -f "$pty" raw -echo
              : > "$log"
              # Reader stays attached (disowned) for the VM's lifetime: it drains
              # the hvc0 console so the guest never backpressures/stalls.
              ( cat "$pty" > "$log" 2>/dev/null ) &!
              local elapsed=0
              while (( elapsed < 120 )); do
                if ${pkgs.gnugrep}/bin/grep -qai 'enter passphrase' "$log"; then
                  security find-generic-password -w -s nixos-vm-luks | tr -d '\n' > "$pty"
                  printf '\n' > "$pty"
                  echo "vm-unlock: $vm_name unlocked from keychain"
                  return 0
                fi
                sleep 2; (( elapsed += 2 ))
              done
              echo "vm-unlock: no LUKS prompt within 120s" >&2
              return 1
            }
          fi

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

          rtzx() { export RG=$1 }

          rtz() {
            local func=$1
            shift 1
            case "$func" in
              "logs") az containerapp logs show -n $1 -g $RG ''${@:2} ;;
              "exec") az containerapp exec -n $1 -g $RG --command ''${@:2} ;;
              *) az containerapp --help ;;
            esac
          }

          sessions() {
            local days_ago=''${1:-0}
            local target_date=$(${pkgs.coreutils}/bin/date -d "$days_ago days ago" +%Y-%m-%d)
            ${pkgs.findutils}/bin/find ~/.local/share/opencode/storage/session -name "ses_*.json" -type f -exec sh -c 'file_date=$(date -d @$(${pkgs.jq}/bin/jq -r ".time.updated / 1000" "$1") +%Y-%m-%d); if [ "$file_date" = "'"$target_date"'" ]; then ${pkgs.jq}/bin/jq -r "\"[\((.time.updated / 1000) | strftime(\"%H:%M\"))] \(.directory) | \(.title)\"" "$1"; fi' _ {} \; | ${pkgs.coreutils}/bin/sort -rn
          }

          # ============================================================================
          # WORK-SPECIFIC FUNCTIONS (Kubernetes/Tekton/Infrastructure)
          # ============================================================================

          cl() {
            case "$1" in
              n100) subdomain="n100"; cluster_name="n100"; workspaces=('infrastructure' 'argocd-infra' 'vault') ;;
              hcp)  subdomain="hcp";  cluster_name="hcp";  workspaces=('vault') ;;
              *) echo "Usage >> cl n100|hcp << " && return 1 ;;
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
            [[ ''${USER} == "jma" ]] && IaC="''${HOME}/Documents/git/gitea/devops/IaC"

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
            [[ -n "''${popme}" ]] && { popd > /dev/null || cd "''${popme}"; }
          }

          runreno() {
            ${pkgs.kubectl}/bin/kubectl delete job renovateme -n renovate --context ''${2:-hcp-oidc} --ignore-not-found
            if [[ $# -eq 0 ]]; then
              ${pkgs.kubectl}/bin/kubectl create job --from cj/renovate -n renovate renovateme --context ''${2:-hcp-oidc}
              ${pkgs.stern}/bin/stern -n renovate --context ''${2:-hcp-oidc} renovateme-
            else
              ${pkgs.kubectl}/bin/kubectl get cj renovate -o yaml -n renovate --context ''${2:-hcp-oidc} \
                | ${pkgs.yq-go}/bin/yq .spec.jobTemplate \
                | ${pkgs.yq-go}/bin/yq ".spec.template.spec.containers[0].env += {\"name\": \"RENOVATE_AUTODISCOVER_FILTER\", \"value\": \"''${1}\"}" \
                | ${pkgs.yq-go}/bin/yq ".spec.template.spec.containers[0].env += {\"name\": \"LOG_LEVEL\", \"value\": \"DEBUG\"}" \
                | ${pkgs.yq-go}/bin/yq '.metadata.name = "renovateme"' \
                | ${pkgs.yq-go}/bin/yq '.kind = "Job"' \
                | ${pkgs.yq-go}/bin/yq '.apiVersion = "batch/v1"' \
                | ${pkgs.kubectl}/bin/kubectl apply -n renovate --context ''${2:-hcp-oidc} -f -
              ${pkgs.stern}/bin/stern -n renovate --context ''${2:-hcp-oidc} renovateme-
            fi
          }

          unseal() {
            case "$1" in
              n100) local limit="n100";  local workspace_name="n100" ;;
              nsc)  local limit="nsc";   local workspace_name="nsc" ;;
              hcp)  local limit="hcp";   local workspace_name="hcp" ;;
              *) echo "Usage >> unseal nsc|n100|hcp << " && return 1 ;;
            esac
            for r in {0..2}; do
              for i in {0..2}; do
                ${pkgs.kubectl}/bin/kubectl exec openbao-$r --context ''${limit} -n openbao -- bao operator unseal --tls-skip-verify $(${pkgs.rbw}/bin/rbw get openbao-''${limit} --field=key_hex_$i)
              done
              [[ ''${limit} != "hcp" ]] && break
            done
          }

          patch() {
            case "$1" in
              archlinux) local playbook="archlinux-setup.yml"; local limit="archlinux" ;;
              os) local playbook="cluster-setup.yml"; local limit="arch-$1"; local workspace_name="openstack" ;;
              ws) local playbook="cluster-setup.yml"; local limit="arch-$1"; local workspace_name="wavestack" ;;
              *) echo "Usage >> patch os|ws|archlinux << " && return 1 ;;
            esac
            tknPipelineRunAnsible -p ''${playbook} -l ''${limit} -w ''${workspace_name}
          }

          tknPipelineRunPatchday() {
            case "$1" in
              os) local workspace_name="openstack" ;;
              ws) local workspace_name="wavestack" ;;
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
              --namespace tekton-pipelines --showlog
            ${pkgs.coreutils}/bin/rm ''${tmp}
          }

          tknPipelineRunTofu() {
            set -x
            case "$1" in
              os)  local workspace_name="openstack" ;;
              ws)  local workspace_name="wavestack" ;;
              n100) local workspace_name="n100" ;;
              *) echo "no known workspace" && return 1 ;;
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
              --namespace tekton-pipelines --showlog
            ${pkgs.coreutils}/bin/rm ''${tmp}
          }

          tknPipelineRunIaC() {
            case "$1" in
              os) local workspace_name="openstack"; local playbook="cluster-setup.yml" ;;
              ws) local workspace_name="wavestack"; local playbook="cluster-setup.yml" ;;
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
              --param path=terraform --param tf_action=plan \
              --param workspace_name=''${workspace_name} \
              --workspace name=sources,volumeClaimTemplateFile=''${tmp} \
              --workspace name=ssh-directory,secret=git-ssh-credential \
              --workspace name=plans,claimName=tofu \
              --namespace tekton-pipelines --showlog
            ${pkgs.coreutils}/bin/rm ''${tmp}
          }

          tknPipelineRunAnsible() {
            while [ "$#" -gt 0 ]; do
              case "$1" in
                -p) playbook="$2";       shift 2 ;;
                -t) tags="$2";           shift 2 ;;
                -w) workspace_name="$2"; shift 2 ;;
                -l) limit="$2";          shift 2 ;;
                -tf) tf_path="$2";       shift 2 ;;
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
              --namespace tekton-pipelines --showlog
            ${pkgs.coreutils}/bin/rm ''${tmp}
          }
        '';
      in
      lib.mkMerge [
        zshOptions
        keybindings
        customFunctions
      ];
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";

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
