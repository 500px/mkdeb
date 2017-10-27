#!/bin/bash
set -euo pipefail

# Generic functions
function log () {
  printf "$(date) $*\n"
}

function die () {
  log "ERROR: $*"
  exit 2
}

function usage_and_exit () {
  echo "Usage: mkdeb.sh -c ASSET_DIR"
  exit 2
}

# mkdeb functions
function validate_config () {
  # If there is a smarter way to do this with -u I would sure like to know
  [[ -n ${deb_name:-} ]] || die "Required var deb_name not defined in mkdeb_configure"
  [[ -n ${deb_maintainer:-} ]] || die "Required var deb_maintainer not defined in mkdeb_configure"
  [[ -n ${deb_vendor:-} ]] || die "Required var deb_vendor not defined in mkdeb_configure"
  [[ -n ${deb_license:-} ]] || die "Required var deb_license not defined in mkdeb_configure"
  [[ -n ${deb_url:-} ]] || die "Required var deb_url not defined in mkdeb_configure"
  [[ -n ${deb_desc:-} ]] || die "Required var deb_desc not defined in mkdeb_configure"
  [[ -n ${deb_version:-} ]] || die "Required var deb_version not defined in mkdeb_configure"
  [[ -n ${dep_epoch:-} ]] || die "Required var dep_epoch not defined in mkdeb_configure"
  [[ -n ${deb_file_maps:-} ]] || die "Required var deb_file_maps not defined in mkdeb_configure"
  return
}

function validate_files () {
  local asset_dir=${1}
  local upstart_file=${2}
  local default_file=${3}
  local init_file=${4}
  local expected_files=(
    ${default_file}
    ${upstart_file}
    ${init_file}
    "preinst.sh"
    "prerm.sh"
    "postinst.sh"
    "postrm.sh"
  )

  # if deb_upstart_filepaths is set we want to make sure the filepaths specified are tested
  if [[ -n ${deb_upstart_filepaths} ]]; then
    if [ ${#deb_upstart_filepaths[@]} -gt 0 ]; then
      for file in "${deb_upstart_filepaths[@]}"; do
        expected_files+=(${file})
      done
    fi
  fi

  # check files exist
  for file in "${expected_files[@]}"; do
    # skip check if default or upstart wasn't given
    if [[ ${file} == "_none" ]]; then
      continue
    fi
    # check files exist
    [[ -e ${file} ]] || die "Expected asset file ${asset_dir}/${file} was not found. See README for details about what files mkdeb expects to find."
  done
  return
}

# Defaults
asset_dir=""
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Handle args
while getopts "c:" OPTION
do
  case ${OPTION} in
    c) asset_dir=$OPTARG;;
    *) usage_and_exit;;
  esac
done

if [[ -z ${asset_dir} ]]; then
  usage_and_exit
fi

# Bail if not ubuntu. Skip this check if SKIP_OS_CHECK is not null
if [[ -z ${SKIP_OS_CHECK:-} ]]; then
  [[ $(lsb_release -is) == "Ubuntu" ]] || die "mkdeb is only supported on Ubuntu 12.04 and higher"
fi

# Bail if fpm not found
fpm=$(command -v fpm) || die "Cannot find fpm in path. You can install fpm with \"gem install fpm\". See README for details."

# Validate asset_dir
if [[ ! -d ${asset_dir} ]]; then
  die "Asset directory ${asset_dir} not found. Use an absolute path, or see README for details on how to create this directory."
fi

log "INFO: mkdeb started"

cd ${asset_dir}
if [[ -r mkdeb_configure ]]; then
    log "INFO: validating files in $(pwd)"
    . mkdeb_configure
    validate_config

    # we might get just a default file, or just an upstart file. Set these to _none if not present
    # so we have some way to validate a positional arg
    validate_files ${asset_dir} ${deb_upstart_filepath:-"_none"} ${deb_default_filepath:-"_none"} ${deb_init_filepath:-"_none"}
else
    die "Cannot find mkdeb_configure in asset_dir"
fi

# Create workdir, src dir, log dir
# Set PX_MKDEB_WORKDIR to override working directory location
cd ${cwd}

if [[ -z ${PX_MKDEB_WORKDIR:-} ]]; then
  work_dir="tmp/mkdeb_work_dir_$(date +'%Y%m%d%H%M%S')"
else
  work_dir=${PX_MKDEB_WORKDIR}
fi

fpm_src_dir="${work_dir}/fpm_src"
log_dir="${work_dir}/logs"

log "INFO: using work dir ${work_dir}"
mkdir -p ${fpm_src_dir}
mkdir -p ${log_dir}

# Copy files to work dir
cd ${fpm_src_dir}
copy_to_work_dir
cd ${cwd}

# Construct fpm arg string
fpm_args=(-s dir)
fpm_args+=(-t deb)
fpm_args+=(-n ${deb_name})
fpm_args+=(-v ${deb_version})
fpm_args+=(-p ${deb_name}_${deb_version}.deb)
fpm_args+=(--epoch ${dep_epoch})
fpm_args+=(--vendor ${deb_vendor})
fpm_args+=(--license ${deb_license})
fpm_args+=(--maintainer ${deb_maintainer})
fpm_args+=(--url "${deb_url}")
fpm_args+=(--description "${deb_desc}")
fpm_args+=(--after-install=${asset_dir}/postinst.sh)
fpm_args+=(--before-install=${asset_dir}/preinst.sh)
fpm_args+=(--after-remove=${asset_dir}/postrm.sh)
fpm_args+=(--before-remove=${asset_dir}/prerm.sh)
fpm_args+=(--no-deb-use-file-permissions)
fpm_args+=(-C ${fpm_src_dir})

# conditional fpm args
if [[ -n ${deb_upstart_filepath:-} ]]; then
  fpm_args+=(--deb-upstart=${asset_dir}/${deb_upstart_filepath})
fi

if [[ -n ${deb_upstart_filepaths:-} ]]; then
  for filepath in "${deb_upstart_filepaths[@]}"; do
    fpm_args+=(--deb-upstart=${asset_dir}/${filepath})
  done
fi

if [[ -n ${deb_default_filepath:-} ]]; then
  fpm_args+=(--deb-default=${asset_dir}/${deb_default_filepath})
fi

if [[ -n ${deb_init_filepath:-} ]]; then
  fpm_args+=(--deb-init=${asset_dir}/${deb_init_filepath})
fi

if [[ -n ${deb_deps:-} ]]; then
  for dep in "${deb_deps[@]}"; do
    fpm_args+=(-d "${dep}")
  done
fi

# file maps
for map in "${deb_file_maps[@]}"; do
  fpm_args+=("${map}")
done

log "INFO: running fpm"
${fpm} "${fpm_args[@]}" 2>&1 | tee -a ${log_dir}/fpm.log

log "INFO: cleaning up working directory ${work_dir}"
rm -r ${work_dir}

log "INFO: mkdeb finished"
