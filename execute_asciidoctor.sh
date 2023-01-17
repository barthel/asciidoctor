#!/bin/sh

[ ${#TOPLEVEL_ADOC_FILES[@]} -eq 0 ] && echo "Non empty TOPLEVEL_ADOC_FILES required." && exit 1;

# convert all .adoc files into HTML files
for adoc in ${TOPLEVEL_ADOC_FILES}
do
  echo "Generate HTML for ${adoc}"
  asciidoctor \
    -b html5 \
    -D "${OUTPUT_DIRECTORY}" \
    -r asciidoctor-diagram \
    -a stylesheet="${HTML_STYLESHEET}" \
    -a stylesdir="${HTML_STYLESDIR}" \
    -a projectVersion="${PROJECT_VERSION}" \
    -a revisionDate="${REVISION_DATE}" \
    "${adoc}";

  echo "Generate PDF for ${adoc}"
  asciidoctor-pdf \
    -D "${OUTPUT_DIRECTORY}" \
    -r asciidoctor-diagram \
    -a pdf-theme="${PDF_THEME}" \
    -a projectVersion="${PROJECT_VERSION}" \
    -a revisionDate="${REVISION_DATE}" \
    "${adoc}";
done

find "${DOCUMENT_SRC_DIRECTORY}" -maxdepth 1 -type f -iname "index.adoc" -exec \
  asciidoctor \
    -b html5 \
    -D "${OUTPUT_DIRECTORY}" \
    -r asciidoctor-diagram \
    -a stylesheet="${HTML_STYLESHEET}" \
    -a stylesdir="${HTML_STYLESDIR}" \
    -a projectVersion="${PROJECT_VERSION}" \
    -a revisionDate="${REVISION_DATE}" \
  {} \;

# copies all HTML releated directories from theme/ in output folder
cp -r "${DOCUMENT_THEME_DIRECTORY}/css" "${OUTPUT_DIRECTORY}/"
cp -r "${DOCUMENT_THEME_DIRECTORY}/images" "${OUTPUT_DIRECTORY}/"

exec "$@"
