#!/bin/bash

readonly tmp=`mktemp`
trap 'rm -f $tmp*' 0

# git diffの結果から.tfファイルが含まれるディレクトリを抽出する
# 例:
# terraform/projct-a/1.tf
# terraform/projct-a/2.tf
# terraform/projct-b/3.tf
# ↓
# terraform/projct-a
# terraform/projct-b

# このプログラム実行時の引数はactions `tj-actions/changed-files` の outputs.all_changed_files が渡される
# ※workflowの以下のセクションの部分
# ```
#       - name: organize and convert diff list to json
#         id: targets
#         run: |
#           bash ./bin/get_tf_targets.sh ${{ steps.changed-files.outputs.all_changed_files }}
# ```
# git diffの差分ファイルパスが空白区切りの1行テキストで渡される
#```
#例:
#.github/workflows/_mock_terraform_plan.yaml bin/get_tf_targets.sh dummy/terraform/project-a/a-1.tf dummy/terraform/project-a/a-2.tf dummy/terraform/project-a/a-3.tf dummy/terraform/project-b/b-1.tf dummy/terraform/project-b/b-2.tf dummy/terraform/project-b/b-3.tf README.md
#```

function __organizing_targets() {
  local diff_files=$@

  # targetsは以下のようなyaml配列形式になるように整形される(重複あり)
  #```
  #- terraform/projct-a
  #- terraform/projct-b
  #- terraform/projct-a
  #```
  for target in $diff_files; do
    #単純な.tfファイルの検出ならこっち
    #if [[ $target =~ ^.*\.tf$ ]]; then
    #  targets+=($target)
    #fi

    #あとから分類しやすいようにcase文で実装
    case $target in
      *.tf)
        target=$(dirname $target)
        echo "- $target" >> $tmp.diff_dirs
        ;;
      *)
        ;;
    esac
  done
}

function __convert_to_json() {
  cat $tmp.diff_dirs | sort | uniq | yq -o json | jq -c .
}

# main

# こういうファイルが作成される
#| + cat /tmp/tmp.y47BIQZ7fI.diff_dirs
#| - dummy/terraform/project-a
#| - dummy/terraform/project-b
#| - dummy/terraform/project-a
__organizing_targets $@

# 上記ファイル内のyaml配列をjsonに変換する。併せて重複を排除。以下のようなJSON文字列に変換される
# これを$GITHUB_OUTPUT変数に出力する（target_dirsという名前の::set-output::に反映される）
# ["dummy/terraform/project-a","dummy/terraform/project-b"]
target_dirs=$(__convert_to_json)
echo $target_dirs
echo "target_dirs=$target_dirs" >> $GITHUB_OUTPUT
