#!/bin/bash

# Copyright (c) King Mampreh OJSC. All rights reserved.
# Licensed under the MIT License.

if [[ `uname -s` != "Darwin" && `uname -s` != "Linux" ]]; then
  CURRENT_DIR=$(pwd -W)
else
  CURRENT_DIR=$(pwd)
fi

if [[ `uname -s` = "Darwin" ]]; then
  SED="sed -i ''"
else
  SED="sed -i"
fi

EASY_DOX_PATH=`dirname $0`
EASY_DOX_PATH="$CURRENT_DIR/$EASY_DOX_PATH"

PLANTUML_STYLE=$1
if [ -z "$PLANTUML_STYLE" ]; then
  PLANTUML_STYLE=classic
fi

EASY_DOX_CONFIGS_DIR="$EASY_DOX_PATH/Configs"

LATEX_FOOTER_PATH="$EASY_DOX_PATH/footer.tex"

LATEX_EXTRA_STYLESHEET_PATH="$EASY_DOX_PATH/doxygen.sty"

PLANTUML_JAR_PATH="$EASY_DOX_PATH/Tools/plantuml.jar"

PLANTUML_CFG_FILE_PATH="$EASY_DOX_CONFIGS_DIR/plantuml_${PLANTUML_STYLE}.cfg"

DOXYFILE_TMP="$CURRENT_DIR/.Doxyfile.tmp"

DOX_DIR="$CURRENT_DIR/Dox"
if [ ! -d $DOX_DIR ]; then
  DOX_DIR="$CURRENT_DIR/dox"
fi

OUTPUT_DIR="$DOX_DIR/dist"

# Remove Doxyfile.tmp just in case
rm -f $DOXYFILE_TMP

# Create output directory
if [ ! -d $OUTPUT_DIR ]; then
  mkdir $OUTPUT_DIR
fi

# Create Doxyfile.tmp
echo @INCLUDE               = ./Doxyfile                   >> $DOXYFILE_TMP
echo LATEX_FOOTER           = $LATEX_FOOTER_PATH           >> $DOXYFILE_TMP
echo LATEX_EXTRA_STYLESHEET = $LATEX_EXTRA_STYLESHEET_PATH >> $DOXYFILE_TMP
echo PLANTUML_JAR_PATH      = $PLANTUML_JAR_PATH           >> $DOXYFILE_TMP
echo PLANTUML_CFG_FILE      = $PLANTUML_CFG_FILE_PATH      >> $DOXYFILE_TMP

find $DOX_DIR -type f -name 'Doxyfile' -print0 |  while IFS= read -r -d $'\0' DOXYFILE; do

  SPEC_DIR="${DOXYFILE%/*}"
  SPEC_NAME="${SPEC_DIR##*/}"

  REVISION_HISTORY=RevisionHistory
  REVISION_HISTORY_TEMP=RevisionHistoryTemp
  REVISION_HISTORY_MD="$REVISION_HISTORY.md"
  REVISION_HISTORY_TEMP_MD="$REVISION_HISTORY_TEMP.md"
  REVISION_HISTORY_TEMP_MD_PATH="$SPEC_DIR/$REVISION_HISTORY_TEMP_MD"
  REVISION_HISTORY_TEX="latex/$REVISION_HISTORY.tex"
  
  # Generate latex for Revision History
  cd "$SPEC_DIR"

  if [ ! -d latex ]; then
    mkdir latex
  fi

  cp $REVISION_HISTORY_MD $REVISION_HISTORY_TEMP_MD

  $SED "s/&/\\\&/g" $REVISION_HISTORY_TEMP_MD # Replace `&` to `\&` in RevisionHistory.md
  $SED "s/#/\\\#/g" $REVISION_HISTORY_TEMP_MD # Replace `#` to `\#` in RevisionHistory.md
  sed '1!d' $REVISION_HISTORY_TEMP_MD | sed -E 's/^ *\| */\\textbf{/g' | sed -E 's/\| *$/} \\\\ \\hline/g' | sed -E 's/ *\| */}\&\\textbf{/g' | sed 's/_/\\_/g' > $REVISION_HISTORY_TEX
  sed '1,2d' $REVISION_HISTORY_TEMP_MD | sed -E 's/^ *\| *//g' | sed -E 's/\| *$/ \\\\ \\hline/g' | sed -E 's/\|/\&/g' | sed 's/_/\\_/g' >> $REVISION_HISTORY_TEX

  cd -

  # Remove old eps and pdf files before generating documentation
  cd "$SPEC_DIR/latex"
  rm -f *.eps , *.pdf
  cd -

  # Generate latex files
  cd "$SPEC_DIR"
  doxygen "$DOXYFILE_TMP"
  cd -

  # Generate PDF
  cd "$SPEC_DIR/latex"

  find . -type f -name '*.tex' -print0 |  while IFS= read -r -d $'\0' TEXFILE; do

    # Find graphics in tex file
    sed -n -E "s/  \\\mbox\\{\\\includegraphics\\[width=\\\textwidth,height=\\\textheight\\/2,keepaspectratio=true]\\{([^{}]*)\\}}/\1/p" $TEXFILE | while IFS= read -r FIGURE; do

      FROM="\\\\mbox\\{\\\\includegraphics\\[width=\\\\textwidth,height=\\\\textheight\\/2,keepaspectratio=true]\\{$FIGURE\\}\\}"
      PREFIX=""
      TO=""

      # Single eps file. Ex. inline_umlgraph_1.eps
      EPSFILE=$FIGURE.eps
      if [ -e "${EPSFILE}" ]; then
        TO="$TO\\\\mbox\\{\\\\includegraphics\\[scale=0.5]{$EPSFILE}}"
        PREFIX="\\\\end{DoxyImageNoCaption}\\\\begin{DoxyImageNoCaption}"
        if [ -e "${FIGURE}_001.eps" ]; then
          # Find all parts of figure. Ex. inline_umlgraph_1_001.eps inline_umlgraph_1_002.eps
          while IFS=' ' read -r EPSFILE; do
              TO="$TO$PREFIX\\\\includegraphics\\[scale=0.5]{$EPSFILE}"
          done <<< "$(ls ${FIGURE}_*.eps)"
        fi

        # Fix issue with diagram scaling
        $SED -E "s/$FROM/$TO/g" $TEXFILE
      fi

    done

    # Remove @code ... @endcode formatting
    $SED -E '/\\begin\{DoxyCode\}/,/\\end\{DoxyCode\}/s/\\textcolor\{[^{}]*\}\{([^{}]*)\}/\1/g' $TEXFILE # Remove \textcolor{}{}
    $SED -E '/\\begin\{DoxyCode\}/,/\\end\{DoxyCode\}/s/\\hyperlink\{[^{}]*\}\{([^{}]*)\}/\1/g' $TEXFILE # Remove \hyperlink{}{}
    $SED '/\\begin{DoxyCode}/,/\\end{DoxyCode}/s/\\{/{/g' $TEXFILE # Replace `\{`` to `{``
    $SED '/\\begin{DoxyCode}/,/\\end{DoxyCode}/s/\\}/}/g' $TEXFILE # Replace `\}` to `}`
    $SED '/\\begin{DoxyCode}/,/\\end{DoxyCode}/s/\\_/_/g' $TEXFILE # Replace `\_` to `_`
    $SED '/\\begin{DoxyCode}/,/\\end{DoxyCode}/s/\\#/#/g' $TEXFILE # Replace `\#` to `#`
    $SED '/\\begin{DoxyCode}/,/\\end{DoxyCode}/s/\\\$/\$/g' $TEXFILE # Replace `\$` to `$`
    $SED '/\\begin{DoxyCode}/,/\\end{DoxyCode}/s/\\%/%/g' $TEXFILE # Replace `\%` to `%`
    $SED '/\\begin{DoxyCode}/,/\\end{DoxyCode}/s/\\\&/\&/g' $TEXFILE # Replace `\&` to `&`
    $SED '/\\begin{DoxyCode}/,/\\end{DoxyCode}/s/-\\\//-/g' $TEXFILE # Replace `-\/` to `-`
    $SED '/\\begin{DoxyCode}/,/\\end{DoxyCode}/s/\\(\\backslash\\)/\\/g' $TEXFILE # Replace `\(\backslash\)` to `\`
    $SED '/\\begin{DoxyCode}/,/\\end{DoxyCode}/s/^\\DoxyCodeLine{\(.*\)}/\1/g' $TEXFILE # Remove \DoxyCodeLine{}


  done
  make
  cd -

  if [ -f "$REVISION_HISTORY_TEMP_MD_PATH" ]; then
    rm -rf "$REVISION_HISTORY_TEMP_MD_PATH"
    rm -rf "$REVISION_HISTORY_TEMP_MD_PATH''"
  fi

  cp "$SPEC_DIR/latex/refman.pdf" "$OUTPUT_DIR/$SPEC_NAME.pdf"

done

# Remove Doxyfile.tmp
rm -f $DOXYFILE_TMP
