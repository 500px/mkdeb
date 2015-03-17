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
  [[ -n ${deb_upstart_filepath:-} ]] || die "Required var deb_upstart_filepath not defined in mkdeb_configure"
  [[ -n ${deb_default_filepath:-} ]] || die "Required var deb_default_filepath not defined in mkdeb_configure"
  [[ -n ${deb_file_maps}:- ]] || die "Required var deb_file_maps not defined in mkdeb_configure" 
  return
}

function validate_files () {
  local asset_dir=${1:-}
  local upstart_file=${2:-}
  local default_file=${3:-}

  local expected_files=(
    "preinst.sh"
    "prerm.sh"
    "postinst.sh"
    "postrm.sh"
    "${upstart_file}"
    "${default_file}"
  )

  for file in "${expected_files[@]}"; do
    # check files exist
    [[ -e ${file} ]] || die "Asset file ${asset_dir}/${file} was not found. See README for details about what files mkdeb expects to find."
  done

  return
}

# Defaults
asset_dir=""
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Handle args
while getopts "c:w:" OPTION
do
  case ${OPTION} in
    c) asset_dir=$OPTARG;;
    *) usage_and_exit;;
  esac
done

if [[ -z ${asset_dir} ]]; then
  usage_and_exit
fi

# Bail if not ubuntu, or FPM not installed
[[ $(lsb_release -is) == "Ubuntu" ]] || die "mkdeb is only supported on Ubuntu 12.04 and higher"
fpm=$(command -v fpm) || die "Cannot find fpm in path. You can install fpm with \"gem install fpm\". See README for details."

# Validate asset_dir
if [[ ! -d ${asset_dir} ]]; then
  die "Asset directory ${asset_dir} not found. Use an absolute path, or see README for details on how to create this directory."
fi

cd ${asset_dir}
if [[ -r mkdeb_configure ]]; then
    . mkdeb_configure
    validate_config
    validate_files ${asset_dir} ${deb_upstart_filepath:-} ${deb_default_filepath:-}
else
    die "Cannot find mkdeb_configure in asset_dir"
fi

# Create workdir, src dir, log dir
cd ${cwd}
work_dir="tmp/mkdeb_work_dir_$(date +'%Y%m%d%H%M%S')"
fpm_src_dir="${work_dir}/fpm_src"
log_dir="${work_dir}/logs"

log "Using work dir ${workdir}"
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
fpm_args+=(--deb-upstart=${asset_dir}/${deb_upstart_filepath})
fpm_args+=(--deb-default=${asset_dir}/${deb_default_filepath})
fpm_args+=(--after-install=${asset_dir}/postinst.sh)
fpm_args+=(--before-install=${asset_dir}/preinst.sh)
fpm_args+=(--after-remove=${asset_dir}/postrm.sh)
fpm_args+=(--before-remove=${asset_dir}/prerm.sh)
fpm_args+=(--no-deb-use-file-permissions)
fpm_args+=(-C ${fpm_src_dir})

for dep in "${deb_deps[@]:-}"; do
  fpm_args+=(-d "${dep}")
done

for map in "${deb_file_maps[@]}"; do
  fpm_args+=("${map}")
done

log "Running fpm"
${fpm} "${fpm_args[@]}" 2>&1 | tee -a ${log_dir}/fpm.log

log "Cleaning up working directory ${work_dir}"
rm -r ${work_dir}
