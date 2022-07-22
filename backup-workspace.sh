#!/usr/bin/bash

# Incremental backup of /home/<user>/workspace

set -o errexit
set -o nounset
set -o pipefail

readonly source_dir="/home/<user>/workspace"
readonly backup_dir="/mnt/<user>-backups/workspace"
readonly log_dir="/mnt/<user>-backups/workspace/logs"
readonly datetime="$(date '+%Y-%m-%d_%H')"
readonly backup_path="${backup_dir}/${datetime}"
readonly latest_link="${backup_dir}/latest"
readonly exclude_file="/etc/<user>-backups/backup-workspace-exclude.txt"

readonly server_backup_dir="/mnt/<user>-share/backups/workspace"
readonly server_backup_path="${server_backup_dir}/${datetime}"
readonly server_latest_link="${server_backup_dir}/latest"

mkdir -p "${log_dir}"

# Backup to local disk
rsync -av --delete \
  "${source_dir}/" \
  --link-dest "${latest_link}" \
  --exclude-from="${exclude_file}" \
  "${backup_path}" >> $log_dir/${datetime}-workspace-backup-log

rm -rf "${latest_link}" >> $log_dir/${datetime}-workspace-backup-log
ln -s "${backup_path}" "${latest_link}" >> $log_dir/${datetime}-workspace-backup-log

# Backup to server, if dir is available
if [[ -d "$SERVER_backup_dir" ]]; then
  rsync -av --delete \
    "${source_dir}/" \
    --link-dest "${server_latest_link}" \
    --exclude-from="${exclude_file}" \
    "${server_backup_path}" >> $log_dir/${datetime}-workspace-backup-log

  rm -rf "${server_latest_link}" >> $log_dir/${datetime}-workspace-backup-log
  ln -s "${server_backup_path}" "${server_latest_link}" >> $log_dir/${datetime}-workspace-backup-log
fi
