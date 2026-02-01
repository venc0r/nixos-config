{ pkgs }:

pkgs.writeShellScriptBin "kube-schema-gen" ''
  port=''${1:-8080}
  OUTPUT_DIR="$HOME/kubernetes_schema"
  mkdir -p "$OUTPUT_DIR"

  GOBIN="$HOME/go/bin"
  KUBESCHEMA="$GOBIN/kubeschema"

  if [[ ! -x "$KUBESCHEMA" ]]; then
    echo "Installing kubeschema..."
    GOBIN="$GOBIN" ${pkgs.go}/bin/go install github.com/imroc/kubeschema@latest
  fi

  myctx=$(${pkgs.kubectl}/bin/kubectl config current-context)
  for ctx in $(${pkgs.kubectl}/bin/kubectl config get-contexts -o name); do
    echo "Checking context: $ctx"
    if ! ${pkgs.kubectl}/bin/kubectl --context="$ctx" --request-timeout=3s cluster-info >/dev/null 2>&1; then
      echo "  skip $ctx (unreachable)"
      continue
    fi
    echo "Generating schema for context: $ctx"
    ${pkgs.kubectl}/bin/kubectl config use-context "$ctx"
    ${pkgs.kubectl}/bin/kubectl proxy --port="$port" &
    PROXY_PID=$!
    sleep 2
    "$KUBESCHEMA" dump --index --out-dir "$OUTPUT_DIR"
    kill $PROXY_PID
  done

  ${pkgs.kubectl}/bin/kubectl config use-context "$myctx" > /dev/null
  echo "Done. Schema index at $OUTPUT_DIR/kubernetes.json"
''
