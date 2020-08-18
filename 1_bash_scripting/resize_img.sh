#!/usr/bin/env bash

############################# Shel Options ###################################
set -o errexit	## stop the script when an error occurs
set -o pipefail	## show proper exit code if program failed in pipeline

## DEBUG
# set -o nounset	## fail if var is used but unset
# set -o xtrace	## prints every expression before executing it
## DEBUG END
############################# Shel Options END ###############################


################################ Variables ###################################
# readonly IMG_EXTENSION='*.jpg *.png *.gif *.bmp'
readonly TMP_DIR="$(mktemp -d)"
declare img_name_patern
declare img_out_path="$(pwd)"
declare new_img_width
################################ Variables END ###############################


################################# Functions ##################################
function _get_ext () {
	echo "${1##*.}"
}

function _get_base_name () {
	echo "${1##*/}"
}

# get file name without extension
function _get_f_name_no_ext () {
	local full_f_name="${1}"
	local base_name="${full_f_name##*/}"
	local f_ext="$(_get_ext "${base_name}")"
	echo "${base_name%.${f_ext}}"
}

function _parse_options () {

	if [[ ${#} -lt 2 ]]; then
		_print_help
		exit 1
	fi

	local gen_img_out_path="0"
	new_img_width="${1}"
	img_name_patern="${2}"
	shift 2

	while [[ ${#} -gt 0 ]]; do
	  case "${1}" in
	    -o|--output)
		  if [[ ${#} -lt 2 ]]; then
		  	_print_help
		  	exit 1
		  fi
	      img_out_path="${2}"
	      shift 2
	    ;;
	    -p|--path)
	      gen_img_out_path="1"
	      shift 1
	    ;;
	    *)
		  echo "Not supported option: ${1}" >&2
	      exit 1
	      ;;
	  esac
	done

	if [[ ${gen_img_out_path} = 1 ]]; then
		mkdir -p "${img_out_path}"
	fi
}

function _print_help () {
	cat << 'END'
  Usage: ./resize_img.sh (new_width:int) (file_name_pattern:str) [options]

  Description:
  	Resize images, that are matched under suplaed pattern, to given width and
  	with saved proportions. Output file name format:
  		"<original-file-name>-<width>-<height>.<ext>"

  Options:
    -o    --output        Path where to store output images
    -p    --path          Create not existing directories in the output path.
END
}

function _is_supported_img () {
	if file "${1}" | grep -qE 'image|bitmap'; then
  		return 0
	fi
	return 1
}

function resize_img () {	
	local width="${1}"
	local image_path="${2}"
	if _is_supported_img "${image_path}"; then
		mogrify -resize "${width}x" "${image_path}"
	else
		return 1
	fi
}
################################# Functions END ##############################


################################### Main #####################################
function _main () {
	_parse_options "${@}"

	local out_file_name
	local tmp_file
	##  		' Image name pattern extends here '
	for file in $(ls ${img_name_patern}); do
		if _is_supported_img "${file}"; then
			tmp_file="${TMP_DIR}/$(_get_base_name "${file}")"
			cp "${file}" "${tmp_file}"
			resize_img "${new_img_width}" "${tmp_file}"

			out_file_name="\
$(_get_f_name_no_ext "${tmp_file}")-\
$(identify -format "%[fx:w]-%[fx:h]" "${tmp_file}").\
$(_get_ext "${tmp_file}")"
			mv "${tmp_file}" "${img_out_path}/${out_file_name}"
		fi
	done
}
################################### Main END #################################


################################### Traps ####################################
function __trap_ctrl_c () {
  echo "** Trapped CTRL-C"
}

function __trap_exit () {
  rm -rf "${TMP_DIR}"
}

trap __trap_ctrl_c INT
trap __trap_exit   EXIT
################################### Traps  END ###############################


# shellcheck "${0}"
_main "${@}"
