#!/bin/sh

export DOCUMENT_ROOT_DIRECTORY=${DOCUMENT_ROOT_DIRECTORY:-"$(pwd)"}
export DOCUMENT_SRC_DIRECTORY=${DOCUMENT_SRC_DIRECTORY:-"${DOCUMENT_ROOT_DIRECTORY}/src/doc"}
export DOCUMENT_THEME_DIRECTORY=${DOCUMENT_THEME_DIRECTORY:-"${DOCUMENT_ROOT_DIRECTORY}/theme"}

export OUTPUT_DIRECTORY=${OUTPUT_DIRECTORY:-"${DOCUMENT_ROOT_DIRECTORY}/docs"}

export HTML_STYLESHEET=${HTML_STYLESHEET:-$(find "${DOCUMENT_THEME_DIRECTORY}" -type f -iname "*.css" -and -not -iname "asciidoctor.css" | head -n 1)}
export HTML_STYLESDIR=${DOCUMENT_THEME_DIRECTORY}

export PDF_THEME=${PDF_THEME:-$(find "${DOCUMENT_THEME_DIRECTORY}" -type f -iname "*-theme.yml" | head -n 1)}

export PROJECT_VERSION=${PROJECT_VERSION:-"LATEST"}
export REVISION_DATE=${REVISION_DATE:-$(date +"%d. %B %Y")}

# Print Asciidoctor verbose output on stdout
for i in $(find /usr/bin -type f -executable -name asciidoctor* -print0 | cut -d- -f1-2 | sort -u )
do
  # @see: https://stackoverflow.com/a/18558871/4956096
  echo -n "${i}: "
  if case ${i} in *-confluence) true;; *) false;; esac
  then
    touch /tmp/temp.adoc
    ${i}  --host 127.0.0.1 -spaceKey TMP --title TEMP --version /tmp/temp.adoc 1> /dev/null
  else
    ${i} --version
  fi
  echo ""
done

[ ! -d "${DOCUMENT_SRC_DIRECTORY}" ] && echo "ERROR: Document source directory required!" && exit 1;

echo "Using document theme directory: ${DOCUMENT_THEME_DIRECTORY}"
echo "Using HTML stylesheet: ${HTML_STYLESHEET}"
echo "Using PDF theme: ${PDF_THEME}"

# Delete output directory
rm -rf "${OUTPUT_DIRECTORY}"

export TOPLEVEL_ADOC_FILES=$(find "${DOCUMENT_SRC_DIRECTORY}" -maxdepth 1 -type f -iname "*.adoc" -and -not -iname "_*.adoc" -and -not -iname "index.adoc")

exec "$@"
