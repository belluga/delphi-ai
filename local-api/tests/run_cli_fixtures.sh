#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
module_root=$(cd -- "$script_dir/.." && pwd -P)
launcher=$module_root/run
uid=$(id -u)
gid=$(id -g)
scratch=$(mktemp -d /tmp/delphi-local-api-fixtures.XXXXXX)
workspace="$scratch/workspace, with \"quotes\" and spaces"
csv_mount_field() {
	field=$1=$2
	value=$(printf '%s' "$field" | sed 's/"/""/g')
	printf '"%s"' "$value"
}
workspace_source_field=$(csv_mount_field source "$workspace")
mkdir -p "$workspace"
cleanup() {
	if [[ ${DELPHI_LOCAL_API_KEEP_FIXTURE:-0} != 1 ]]; then
		rm -rf -- "$scratch"
	fi
}
trap cleanup EXIT HUP INT TERM

docker run --rm --network bridge --mount "type=bind,$workspace_source_field,target=/fixture" golang:1.23-alpine sh -c '
set -eu
apk add --no-cache git >/dev/null
for project in project-one project-two; do
  foundation="/fixture/$project/foundation"
  mkdir -p "$foundation/policies" "$foundation/modules" "$foundation/todos/active"
  printf "# Mandate\n" > "$foundation/project_mandate.md"
  printf "# Entities\n" > "$foundation/domain_entities.md"
  printf "# Constitution\n" > "$foundation/project_constitution.md"
  printf "# Roadmap\n" > "$foundation/system_roadmap.md"
  printf "# Landing\n" > "$foundation/project_landing.md"
  printf "# Policy\n" > "$foundation/policies/policy.md"
  printf "# Module\n" > "$foundation/modules/module.md"
  printf "# TODO\n" > "$foundation/todos/active/todo.md"
done
for source in project-one project-two company-one company-two default-one; do
  root="/fixture/$source/foundation"
  mkdir -p "$root/design/system"
  owner_level=project
  owner_id=$source
  if [ "$source" = company-one ] || [ "$source" = company-two ]; then owner_level=company; owner_id=$source; fi
  if [ "$source" = default-one ]; then owner_level=default; owner_id=default-one; fi
  printf "{\"schema_version\":\"1\",\"id\":\"system-%s\",\"name\":\"%s System\",\"owner\":{\"level\":\"%s\",\"id\":\"%s\"},\"tokens\":[{\"id\":\"primary\",\"type\":\"color\",\"value\":\"#112233\"}],\"components\":[],\"assets\":[],\"contrast_pairs\":[]}\n" "$owner_id" "$owner_id" "$owner_level" "$owner_id" > "$root/design/system/design-system.json"
done
mkdir -p /fixture/project-one/foundation/prototypes/demo
printf "{\"schema_version\":\"1\",\"project_id\":\"project-one\",\"prototypes\":[{\"id\":\"demo-one\",\"name\":\"Demo\",\"description\":null,\"root\":\"prototypes/demo\"}]}\n" > /fixture/project-one/foundation/prototypes/catalog.json
printf "{\"schema_version\":\"1\",\"id\":\"demo-one\",\"entry_point\":\"index.html\",\"screens\":[{\"id\":\"home\",\"name\":\"Home\",\"path\":\"index.html\",\"scope\":null}],\"sources\":[\"index.html\"],\"assets\":[],\"links\":[],\"related\":[],\"design_system_ref\":null}\n" > /fixture/project-one/foundation/prototypes/demo/prototype.json
printf "<main>Demo</main>\n" > /fixture/project-one/foundation/prototypes/demo/index.html
chown -R "$1:$2" /fixture
' fixture "$uid" "$gid"

docker run --rm --network bridge --mount "type=bind,$workspace_source_field,target=/fixture" golang:1.23-alpine sh -c '
set -eu
apk add --no-cache git su-exec >/dev/null
for project in project-one project-two company-one company-two default-one; do
  root="/fixture/$project/foundation"
  su-exec "$1:$2" git -C "$root" init -q
  su-exec "$1:$2" git -C "$root" config user.email fixture@example.invalid
  su-exec "$1:$2" git -C "$root" config user.name "Local API Fixture"
  su-exec "$1:$2" git -C "$root" add --all
  su-exec "$1:$2" git -C "$root" commit -qm "initial $project"
done
' fixture "$uid" "$gid"

project_revision=$(docker run --rm --network bridge --mount "type=bind,$workspace_source_field,target=/fixture,readonly" golang:1.23-alpine sh -c 'apk add --no-cache git su-exec >/dev/null; su-exec "$1:$2" git -C /fixture/project-one/foundation rev-parse HEAD' fixture "$uid" "$gid")
project_two_revision=$(docker run --rm --network bridge --mount "type=bind,$workspace_source_field,target=/fixture,readonly" golang:1.23-alpine sh -c 'apk add --no-cache git su-exec >/dev/null; su-exec "$1:$2" git -C /fixture/project-two/foundation rev-parse HEAD' fixture "$uid" "$gid")
company_revision=$(docker run --rm --network bridge --mount "type=bind,$workspace_source_field,target=/fixture,readonly" golang:1.23-alpine sh -c 'apk add --no-cache git su-exec >/dev/null; su-exec "$1:$2" git -C /fixture/company-one/foundation rev-parse HEAD' fixture "$uid" "$gid")
company_two_revision=$(docker run --rm --network bridge --mount "type=bind,$workspace_source_field,target=/fixture,readonly" golang:1.23-alpine sh -c 'apk add --no-cache git su-exec >/dev/null; su-exec "$1:$2" git -C /fixture/company-two/foundation rev-parse HEAD' fixture "$uid" "$gid")
default_revision=$(docker run --rm --network bridge --mount "type=bind,$workspace_source_field,target=/fixture,readonly" golang:1.23-alpine sh -c 'apk add --no-cache git su-exec >/dev/null; su-exec "$1:$2" git -C /fixture/default-one/foundation rev-parse HEAD' fixture "$uid" "$gid")
mkdir -p "$workspace/project-one/local-api"
jq -n --arg project_sha "$project_revision" --arg company_sha "$company_revision" --arg default_sha "$default_revision" '{schema_version:"1",project_id:"project-one",company_id:"company-one",sources:{project:{repository_id:"project-one",checkout_root:"project-one/foundation",revision:$project_sha,definition_path:"design/system/design-system.json"},company:{repository_id:"company-one",checkout_root:"company-one/foundation",revision:$company_sha,definition_path:"design/system/design-system.json"},default:{repository_id:"default-one",checkout_root:"default-one/foundation",revision:$default_sha,definition_path:"design/system/design-system.json"}}}' > "$workspace/project-one/local-api/all-sources.json"
mkdir -p "$workspace/project-two/local-api"
jq -n --arg project_sha "$project_two_revision" --arg company_sha "$company_two_revision" '{schema_version:"1",project_id:"project-two",company_id:"company-two",sources:{project:{repository_id:"project-two",checkout_root:"project-two/foundation",revision:$project_sha,definition_path:"design/system/design-system.json"},company:{repository_id:"company-two",checkout_root:"company-two/foundation",revision:$company_sha,definition_path:"design/system/design-system.json"},default:null}}' > "$workspace/project-two/local-api/sources.json"
jq -n --arg company_sha "$company_revision" --arg default_sha "$default_revision" '{schema_version:"1",project_id:"project-one",company_id:"company-one",sources:{project:null,company:{repository_id:"company-one",checkout_root:"company-one/foundation",revision:$company_sha,definition_path:"design/system/design-system.json"},default:{repository_id:"default-one",checkout_root:"default-one/foundation",revision:$default_sha,definition_path:"design/system/design-system.json"}}}' > "$workspace/project-one/local-api/company-sources.json"
jq -n --arg default_sha "$default_revision" '{schema_version:"1",project_id:"project-one",company_id:"company-one",sources:{project:null,company:null,default:{repository_id:"default-one",checkout_root:"default-one/foundation",revision:$default_sha,definition_path:"design/system/design-system.json"}}}' > "$workspace/project-one/local-api/default-source.json"
jq -n --arg project_sha "$project_revision" --arg company_sha "$company_revision" --arg default_sha "$default_revision" '{schema_version:"1",project_id:"project-one",company_id:"company-one",sources:{project:{repository_id:"project-one",checkout_root:"missing-project/foundation",revision:$project_sha,definition_path:"design/system/design-system.json"},company:{repository_id:"company-one",checkout_root:"company-one/foundation",revision:$company_sha,definition_path:"design/system/design-system.json"},default:{repository_id:"default-one",checkout_root:"default-one/foundation",revision:$default_sha,definition_path:"design/system/design-system.json"}}}' > "$workspace/project-one/local-api/broken-project.json"

cd /tmp
base=(--workspace-root "$workspace" --project-root project-one --foundation-root project-one/foundation --project-id project-one)
artifact_context=(--workspace-root "$workspace" --project-root project-one --foundation-root project-one/foundation --project-id project-one --company-id company-one)
tree_digest() {
	(
		cd "$workspace"
        find project-one/foundation project-two/foundation company-one/foundation company-two/foundation default-one/foundation -type f ! -path '*/.git/*' ! -name knowledge_review.manifest.json -print0 | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum | cut -d' ' -f1
	)
}
map_digest() {
	find "$workspace/project-one/local-api" "$workspace/project-two/local-api" -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum | cut -d' ' -f1
}
before=$(tree_digest)
maps_before=$(map_digest)
marker="$workspace/project-one/foundation/knowledge_review.manifest.json"
test ! -e "$marker"
git_status_before=$(docker run --rm --network bridge --mount "type=bind,$workspace_source_field,target=/fixture,readonly" golang:1.23-alpine sh -c 'apk add --no-cache git su-exec >/dev/null; su-exec "$1:$2" git -C /fixture/project-one/foundation status --porcelain -z | sha256sum | cut -d" " -f1' fixture "$uid" "$gid")
git_heads_before=$(docker run --rm --network bridge --mount "type=bind,$workspace_source_field,target=/fixture,readonly" golang:1.23-alpine sh -c 'apk add --no-cache git su-exec >/dev/null; for repo in project-one project-two company-one company-two default-one; do printf "%s " "$repo"; su-exec "$1:$2" git -C "/fixture/$repo/foundation" rev-parse HEAD; su-exec "$1:$2" git -C "/fixture/$repo/foundation" status --porcelain -z | sha256sum | cut -d" " -f1; done' fixture "$uid" "$gid" | sha256sum | cut -d' ' -f1)
status_out="$scratch/status.json"
status_err="$scratch/status.err"
"$launcher" knowledge-status status "${base[@]}" >"$status_out" 2>"$status_err"
test ! -s "$status_err"
jq -e '.project_id == "project-one" and .authority_scope == "local_review_only"' "$status_out" >/dev/null
packet_out="$scratch/packet.json"
packet_err="$scratch/packet.err"
"$launcher" knowledge-status review-packet "${base[@]}" --target landing >"$packet_out" 2>"$packet_err"
test ! -s "$packet_err"
revision=$(jq -r .source_revision "$packet_out")
packet_digest=$(jq -r .packet_digest "$packet_out")
[[ "$revision" =~ ^[0-9a-f]{40}$ || "$revision" =~ ^[0-9a-f]{64}$ ]]
[[ "$packet_digest" =~ ^sha256:[0-9a-f]{64}$ ]]
landing_digest=$packet_digest
landing_revision=$revision
landing_source_digest=$(jq -r .source_digest "$packet_out")
landing_document_digest=$(jq -r .document_digest "$packet_out")
roadmap_packet="$scratch/roadmap-packet.json"
"$launcher" knowledge-status review-packet "${base[@]}" --target roadmap >"$roadmap_packet"
roadmap_revision=$(jq -r .source_revision "$roadmap_packet")
roadmap_digest=$(jq -r .packet_digest "$roadmap_packet")
roadmap_source_digest=$(jq -r .source_digest "$roadmap_packet")
roadmap_document_digest=$(jq -r .document_digest "$roadmap_packet")
[[ "$roadmap_revision" == "$landing_revision" ]]
[[ "$roadmap_digest" =~ ^sha256:[0-9a-f]{64}$ ]]

prototype_out="$scratch/prototypes.json"
"$launcher" artifact-status prototypes "${base[@]}" --mode working-tree >"$prototype_out"
jq -e '.project_id == "project-one" and .outcome == "go" and .target == "prototypes" and (.items | length) == 1 and .design_system_validation == "not_evaluated"' "$prototype_out" >/dev/null

for binding in all-sources company-sources default-source; do
	output="$scratch/design-system-$binding.json"
	"$launcher" artifact-status design-system "${artifact_context[@]}" --source-bindings "project-one/local-api/$binding.json" --mode committed --default-owner-id default-one >"$output"
	expected=project
	[[ "$binding" == company-sources ]] && expected=company
	[[ "$binding" == default-source ]] && expected=default
	jq -e --arg expected "$expected" '.outcome == "go" and .design_system_validation == "valid" and .selected_level == $expected and (.items | length) == 1 and .inventory_digest != null' "$output" >/dev/null
done
conditional_default="$scratch/conditional-default.json"
conditional_default_err="$scratch/conditional-default.err"
set +e
"$launcher" artifact-status design-system "${artifact_context[@]}" --source-bindings project-one/local-api/all-sources.json --mode committed >"$conditional_default" 2>"$conditional_default_err"
conditional_default_status=$?
set -e
test "$conditional_default_status" -eq 64
test ! -s "$conditional_default"
test -s "$conditional_default_err"
broken_ds="$scratch/broken-selected.json"
set +e
"$launcher" artifact-status design-system "${artifact_context[@]}" --source-bindings project-one/local-api/broken-project.json --mode committed --default-owner-id default-one >"$broken_ds"
broken_ds_status=$?
set -e
test "$broken_ds_status" -eq 2
jq -e '.outcome == "no_go" and .source == null and (.items | length) == 0 and any(.diagnostics[]; .code == "owner_mismatch")' "$broken_ds" >/dev/null

after=$(tree_digest)
maps_after=$(map_digest)
git_status_after=$(docker run --rm --network bridge --mount "type=bind,$workspace_source_field,target=/fixture,readonly" golang:1.23-alpine sh -c 'apk add --no-cache git su-exec >/dev/null; su-exec "$1:$2" git -C /fixture/project-one/foundation status --porcelain -z | sha256sum | cut -d" " -f1' fixture "$uid" "$gid")
git_heads_after=$(docker run --rm --network bridge --mount "type=bind,$workspace_source_field,target=/fixture,readonly" golang:1.23-alpine sh -c 'apk add --no-cache git su-exec >/dev/null; for repo in project-one project-two company-one company-two default-one; do printf "%s " "$repo"; su-exec "$1:$2" git -C "/fixture/$repo/foundation" rev-parse HEAD; su-exec "$1:$2" git -C "/fixture/$repo/foundation" status --porcelain -z | sha256sum | cut -d" " -f1; done' fixture "$uid" "$gid" | sha256sum | cut -d' ' -f1)
test "$before" = "$after"
test "$maps_before" = "$maps_after"
test "$git_status_before" = "$git_status_after"
test "$git_heads_before" = "$git_heads_after"
test ! -e "$workspace/project-one/local-api/v1"
test ! -e "$workspace/project-two/local-api/v1"
test ! -e "$marker"

second=(--workspace-root "$workspace" --project-root project-two --foundation-root project-two/foundation --project-id project-two)
second_out="$scratch/project-two.json"
"$launcher" knowledge-status status "${second[@]}" >"$second_out"
jq -e '.project_id == "project-two"' "$second_out" >/dev/null
second_ds_out="$scratch/project-two-ds.json"
"$launcher" artifact-status design-system "${second[@]}" --company-id company-two --source-bindings project-two/local-api/sources.json --mode committed >"$second_ds_out"
jq -e '.project_id == "project-two" and .company_id == "company-two" and .selected_level == "project" and .source.repository_id == "project-two"' "$second_ds_out" >/dev/null
second_mismatch="$scratch/project-two-mismatch.json"
set +e
"$launcher" artifact-status design-system "${second[@]}" --company-id company-one --source-bindings project-two/local-api/sources.json --mode committed >"$second_mismatch"
second_mismatch_status=$?
set -e
test "$second_mismatch_status" -eq 2
jq -e '.outcome == "no_go"' "$second_mismatch" >/dev/null

invalid_out="$scratch/invalid.out"
invalid_err="$scratch/invalid.err"
set +e
"$launcher" knowledge-status status --workspace-root "$workspace" --project-root ../escape --foundation-root project-one/foundation --project-id project-one >"$invalid_out" 2>"$invalid_err"
invalid_status=$?
set -e
test "$invalid_status" -eq 64
test ! -s "$invalid_out"
test -s "$invalid_err"

missing_out="$scratch/missing.out"
missing_err="$scratch/missing.err"
set +e
"$launcher" knowledge-status status --workspace-root "$workspace" --project-root project-one --foundation-root absent --project-id project-one >"$missing_out" 2>"$missing_err"
missing_status=$?
set -e
test "$missing_status" -eq 2
test ! -s "$missing_out"
test ! -s "$missing_err"

context_out="$scratch/missing-context.out"
context_err="$scratch/missing-context.err"
set +e
"$launcher" knowledge-status status --workspace-root "$workspace" --project-root project-one --project-id project-one >"$context_out" 2>"$context_err"
context_status=$?
set -e
test "$context_status" -eq 64
test ! -s "$context_out"
test -s "$context_err"

mkdir -p "$workspace/project-one/foundation/nested"
nested_out="$scratch/nested-foundation.out"
nested_err="$scratch/nested-foundation.err"
set +e
"$launcher" knowledge-status status --workspace-root "$workspace" --project-root project-one --foundation-root project-one/foundation/nested --project-id project-one >"$nested_out" 2>"$nested_err"
nested_status=$?
set -e
test "$nested_status" -eq 2
test ! -s "$nested_out"
test ! -s "$nested_err"

write_root_out="$scratch/write-root.out"
write_root_err="$scratch/write-root.err"
set +e
"$launcher" knowledge-status record-review --workspace-root "$workspace" --project-root project-one --foundation-root project-one --project-id project-one --target landing --revision "$landing_revision" --expected-packet-digest "$landing_digest" --reviewed-by fixture --review-reference fixture:unsafe >"$write_root_out" 2>"$write_root_err"
write_root_status=$?
set -e
test "$write_root_status" -eq 2
test ! -s "$write_root_out"
test ! -s "$write_root_err"
test ! -e "$workspace/project-one/knowledge_review.manifest.json"
test ! -e "$marker"

full_err="$scratch/full.err"
set +e
"$launcher" artifact-status prototypes "${base[@]}" --mode working-tree >/dev/full 2>"$full_err"
full_status=$?
set -e
test "$full_status" -eq 70
test -s "$full_err"

declare -A counts=([0]=0 [2]=0 [64]=0 [70]=0)
batch_hashes=()
for batch in 1 2 3; do
  pids=()
  result_dir="$scratch/batch-$batch"
  mkdir -p "$result_dir"
  for worker in $(seq 1 10); do
    target=landing
    [[ $((worker % 2)) -eq 0 ]] && target=roadmap
    target_revision=$landing_revision
    target_digest=$landing_digest
    if [[ "$target" == roadmap ]]; then
      target_revision=$roadmap_revision
      target_digest=$roadmap_digest
    fi
    (
      set +e
      "$launcher" knowledge-status record-review "${base[@]}" --target "$target" --revision "$target_revision" --expected-packet-digest "$target_digest" --reviewed-by "fixture-batch-$batch-worker-$worker" --review-reference "fixture:$batch:$worker" >"$result_dir/$worker.out" 2>"$result_dir/$worker.err"
      result=$?
      printf '%s\n' "$result" >"$result_dir/$worker.status"
      exit "$result"
    ) &
    pids+=("$!")
  done
  for pid in "${pids[@]}"; do
    set +e
    wait "$pid"
    result=$?
    set -e
    counts["$result"]=$((${counts["$result"]} + 1))
    test "$result" -eq 0
  done
  for worker in $(seq 1 10); do
    test ! -s "$result_dir/$worker.out"
    test ! -s "$result_dir/$worker.err"
  done
  jq -e --arg revision "$landing_revision" --arg landing "$landing_digest" --arg landing_source "$landing_source_digest" --arg landing_document "$landing_document_digest" --arg roadmap_revision "$roadmap_revision" --arg roadmap "$roadmap_digest" --arg roadmap_source "$roadmap_source_digest" --arg roadmap_document "$roadmap_document_digest" --arg batch "$batch" '
    .landing.reviewed_revision == $revision and .landing.reviewed_packet_digest == $landing and
    .landing.reviewed_source_digest == $landing_source and .landing.reviewed_document_digest == $landing_document and
    .roadmap.reviewed_revision == $roadmap_revision and .roadmap.reviewed_packet_digest == $roadmap and
    .roadmap.reviewed_source_digest == $roadmap_source and .roadmap.reviewed_document_digest == $roadmap_document and
    (.landing.review_reference | startswith("fixture:" + $batch + ":")) and
    (.roadmap.review_reference | startswith("fixture:" + $batch + ":")) and
    (.landing.reviewed_by == ("fixture-batch-" + $batch + "-worker-" + (.landing.review_reference | split(":")[2]))) and
    (.roadmap.reviewed_by == ("fixture-batch-" + $batch + "-worker-" + (.roadmap.review_reference | split(":")[2]))) and
    ((.landing.review_reference | split(":")[1] | tonumber) == ($batch | tonumber)) and
    ((.roadmap.review_reference | split(":")[1] | tonumber) == ($batch | tonumber)) and
    ((.landing.review_reference | split(":") | length) == 3) and
    ((.roadmap.review_reference | split(":") | length) == 3) and
    ((.landing.review_reference | split(":")[2] | tonumber) >= 1 and (.landing.review_reference | split(":")[2] | tonumber) <= 10) and
    ((.roadmap.review_reference | split(":")[2] | tonumber) >= 1 and (.roadmap.review_reference | split(":")[2] | tonumber) <= 10) and
    ((.landing.review_reference | split(":")[2] | tonumber) % 2 == 1) and
    ((.roadmap.review_reference | split(":")[2] | tonumber) % 2 == 0)
  ' "$marker" >/dev/null
  cp "$marker" "$result_dir/marker-final.json"
  batch_hashes+=("$(sha256sum "$marker" | cut -d' ' -f1)")
done
test "$before" = "$(tree_digest)"
test "$maps_before" = "$(map_digest)"
test ! -e "$workspace/project-one/local-api/v1"
test ! -e "$workspace/project-two/local-api/v1"

jq -n \
  --arg invariant_id "DELPHI-LOCAL-01-review-marker-provenance" \
  --arg concurrency_policy "serialize" \
  --arg probe_profile_observed "10overlapsx3" \
  --arg executor_id "${USER:-unknown}:$(id -u)" \
  --arg runtime "Docker golang:1.23-alpine + Git fixture repos" \
  --arg fixture_scope "scratch-only; workspace path contains comma, quotes, and spaces" \
  --arg evidence_path "$scratch/evidence.json" \
  --argjson batch_sizes '[10,10,10]' \
  --argjson success_count "${counts[0]}" \
  --argjson semantic_reject_count "${counts[2]}" \
  --argjson invocation_reject_count "${counts[64]}" \
  --argjson infrastructure_reject_count "${counts[70]}" \
  --argjson marker_hashes "$(printf '%s\n' "${batch_hashes[@]}" | jq -R . | jq -s .)" \
  '{invariant_id:$invariant_id, concurrency_policy:$concurrency_policy, probe_profile_observed:$probe_profile_observed, executor_id:$executor_id, runtime:$runtime, fixture_scope:$fixture_scope, evidence_path:$evidence_path, batch_sizes:$batch_sizes, success_count:$success_count, semantic_reject_count:$semantic_reject_count, invocation_reject_count:$invocation_reject_count, infrastructure_reject_count:$infrastructure_reject_count, marker_hashes:$marker_hashes, both_target_provenance_verified:true, exact_full_revision:true, no_real_repository_writes:true}' | tee "$scratch/evidence.json"
