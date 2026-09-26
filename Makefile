.PHONY: help book chapters clean cleanall all
.PHONY: ch1 ch2 ch3 ch4 ch5 ch6 ch7 ch8 ch9 ch10 ch11 ch12 ch13 ch14 ch15 ch16 ch17 ch18 ch19 ch20 ch21

SHELL := /bin/bash
SRCDIR := src
BUILDDIR := build
OUTDIR := output
CHAPTERS_OUTDIR := $(OUTDIR)/chapters

# Compile from BUILDDIR so aux/log/minted/pdf intermediates never land in src/.
# Trailing colon on TEXINPUTS keeps TeX Live's default search path.
BUILD_TEXINPUTS := ../$(SRCDIR):../$(SRCDIR)/packages:
LATEXMK := latexmk -xelatex -cd- -output-directory=. -aux-directory=. -latexoption="-file-line-error -halt-on-error" -shell-escape -silent -interaction=nonstopmode

help:
	@echo "📚 Book Build System"
	@echo ""
	@echo "Targets:"
	@echo "  make book                - Build full book PDF"
	@echo "  make chapters            - Build all chapter PDFs"
	@echo "  make ch[1-21]            - Build a specific chapter (e.g., make ch1)"
	@echo "  make all                 - Build everything"
	@echo "  make clean               - Delete build artifacts"
	@echo "  make cleanall            - Delete all PDFs + artifacts"
	@echo ""

all: book chapters
	@echo "✓ Build complete!"

book: $(OUTDIR)/book.pdf
	@:

chapters: $(CHAPTERS_OUTDIR)/01_Introduction.pdf \
           $(CHAPTERS_OUTDIR)/02_BasicProgramStructure.pdf \
           $(CHAPTERS_OUTDIR)/03_Arithmetic.pdf \
           $(CHAPTERS_OUTDIR)/04_Conditionals.pdf \
           $(CHAPTERS_OUTDIR)/05_Loop.pdf \
           $(CHAPTERS_OUTDIR)/06_Array.pdf \
           $(CHAPTERS_OUTDIR)/07_FloatingPointNumbers.pdf \
           $(CHAPTERS_OUTDIR)/08_Function.pdf \
           $(CHAPTERS_OUTDIR)/09_Pointer.pdf \
           $(CHAPTERS_OUTDIR)/10_Character.pdf \
           $(CHAPTERS_OUTDIR)/11_String.pdf \
           $(CHAPTERS_OUTDIR)/12_BitOperations.pdf \
           $(CHAPTERS_OUTDIR)/13_DeclarationModifiers.pdf \
           $(CHAPTERS_OUTDIR)/14_Structure.pdf \
           $(CHAPTERS_OUTDIR)/15_Recursion.pdf \
           $(CHAPTERS_OUTDIR)/16_FileIO.pdf \
           $(CHAPTERS_OUTDIR)/17_Preprocessing.pdf \
           $(CHAPTERS_OUTDIR)/18_StandardLibrary.pdf \
           $(CHAPTERS_OUTDIR)/19_DataStructure.pdf \
           $(CHAPTERS_OUTDIR)/20_Objects.pdf \
           $(CHAPTERS_OUTDIR)/21_ExtendedTechniques.pdf
	@echo "✓ All chapters compiled to $(CHAPTERS_OUTDIR)/"

# Chapter Shortcuts
ch1: $(CHAPTERS_OUTDIR)/01_Introduction.pdf
ch2: $(CHAPTERS_OUTDIR)/02_BasicProgramStructure.pdf
ch3: $(CHAPTERS_OUTDIR)/03_Arithmetic.pdf
ch4: $(CHAPTERS_OUTDIR)/04_Conditionals.pdf
ch5: $(CHAPTERS_OUTDIR)/05_Loop.pdf
ch6: $(CHAPTERS_OUTDIR)/06_Array.pdf
ch7: $(CHAPTERS_OUTDIR)/07_FloatingPointNumbers.pdf
ch8: $(CHAPTERS_OUTDIR)/08_Function.pdf
ch9: $(CHAPTERS_OUTDIR)/09_Pointer.pdf
ch10: $(CHAPTERS_OUTDIR)/10_Character.pdf
ch11: $(CHAPTERS_OUTDIR)/11_String.pdf
ch12: $(CHAPTERS_OUTDIR)/12_BitOperations.pdf
ch13: $(CHAPTERS_OUTDIR)/13_DeclarationModifiers.pdf
ch14: $(CHAPTERS_OUTDIR)/14_Structure.pdf
ch15: $(CHAPTERS_OUTDIR)/15_Recursion.pdf
ch16: $(CHAPTERS_OUTDIR)/16_FileIO.pdf
ch17: $(CHAPTERS_OUTDIR)/17_Preprocessing.pdf
ch18: $(CHAPTERS_OUTDIR)/18_StandardLibrary.pdf
ch19: $(CHAPTERS_OUTDIR)/19_DataStructure.pdf
ch20: $(CHAPTERS_OUTDIR)/20_Objects.pdf
ch21: $(CHAPTERS_OUTDIR)/21_ExtendedTechniques.pdf

# Full book: copy the driver into BUILDDIR (do not compile ../src/book.tex in
# place — latexmk/xelatex would write aux/log/minted next to the source).
$(OUTDIR)/book.pdf: $(SRCDIR)/book.tex
	@mkdir -p $(BUILDDIR) $(OUTDIR)
	@echo "Building: Full book..."
	@cp $(SRCDIR)/book.tex $(BUILDDIR)/book.tex
	@cd $(BUILDDIR) && TEXINPUTS="$(BUILD_TEXINPUTS)" $(LATEXMK) book.tex > /dev/null 2>&1 || \
		(echo "❌ Build failed. Error snippet from book.log:"; grep -n -A 5 '^!' book.log || tail -20 book.log; exit 1)
	@cp $(BUILDDIR)/book.pdf $(OUTDIR)/book.pdf
	@echo "✓ $(OUTDIR)/book.pdf"

# Build script for chapters
define build_chapter
	@mkdir -p $(BUILDDIR) $(CHAPTERS_OUTDIR)
	@echo "Building chapter: $2..."
	@wrapper="$(BUILDDIR)/chapter-$1.tex" && \
	chap_num=$$(echo "$1" | grep -o '^[0-9]\+') && chap_num=$${chap_num:-1} && \
	sed -e '/\\include{chapters/d' -e '/\\input{chapters/d' -e '/\\end{document}/d' -e '/\\maketitle/d' -e '/\\tableofcontents/d' -e '/\\frontmatter/d' -e '/\\mainmatter/d' $(SRCDIR)/book.tex > "$$wrapper" && \
	echo "\\setcounter{chapter}{$$(( 10#$$chap_num - 1 ))}" >> "$$wrapper" && \
	echo "\\input{../$(SRCDIR)/chapters/$1/chapter}" >> "$$wrapper" && \
	echo "\\end{document}" >> "$$wrapper" && \
	cd $(BUILDDIR) && TEXINPUTS="$(BUILD_TEXINPUTS)" $(LATEXMK) chapter-$1.tex > /dev/null 2>&1 || \
	(echo "❌ Build failed for $2. Error snippet from chapter-$1.log:"; grep -n -A 5 '^!' chapter-$1.log || tail -20 chapter-$1.log; exit 1) && \
	if [ -f "chapter-$1.pdf" ]; then cp chapter-$1.pdf ../$(CHAPTERS_OUTDIR)/$1.pdf; fi
endef

# Individual chapter targets
$(CHAPTERS_OUTDIR)/01_Introduction.pdf:
	$(call build_chapter,01_Introduction,Introduction)
$(CHAPTERS_OUTDIR)/02_BasicProgramStructure.pdf:
	$(call build_chapter,02_BasicProgramStructure,Basic Program Structure)
$(CHAPTERS_OUTDIR)/03_Arithmetic.pdf:
	$(call build_chapter,03_Arithmetic,Arithmetic)
$(CHAPTERS_OUTDIR)/04_Conditionals.pdf:
	$(call build_chapter,04_Conditionals,Conditionals)
$(CHAPTERS_OUTDIR)/05_Loop.pdf:
	$(call build_chapter,05_Loop,Loop)
$(CHAPTERS_OUTDIR)/06_Array.pdf:
	$(call build_chapter,06_Array,Array)
$(CHAPTERS_OUTDIR)/07_FloatingPointNumbers.pdf:
	$(call build_chapter,07_FloatingPointNumbers,Floating Point Numbers)
$(CHAPTERS_OUTDIR)/08_Function.pdf:
	$(call build_chapter,08_Function,Function)
$(CHAPTERS_OUTDIR)/09_Pointer.pdf:
	$(call build_chapter,09_Pointer,Pointer)
$(CHAPTERS_OUTDIR)/10_Character.pdf:
	$(call build_chapter,10_Character,Character)
$(CHAPTERS_OUTDIR)/11_String.pdf:
	$(call build_chapter,11_String,String)
$(CHAPTERS_OUTDIR)/12_BitOperations.pdf:
	$(call build_chapter,12_BitOperations,Bit Operations)
$(CHAPTERS_OUTDIR)/13_DeclarationModifiers.pdf:
	$(call build_chapter,13_DeclarationModifiers,Declaration Modifiers)
$(CHAPTERS_OUTDIR)/14_Structure.pdf:
	$(call build_chapter,14_Structure,Structure)
$(CHAPTERS_OUTDIR)/15_Recursion.pdf:
	$(call build_chapter,15_Recursion,Recursion)
$(CHAPTERS_OUTDIR)/16_FileIO.pdf:
	$(call build_chapter,16_FileIO,File IO)
$(CHAPTERS_OUTDIR)/17_Preprocessing.pdf:
	$(call build_chapter,17_Preprocessing,Preprocessing)
$(CHAPTERS_OUTDIR)/18_StandardLibrary.pdf:
	$(call build_chapter,18_StandardLibrary,Standard Library)
$(CHAPTERS_OUTDIR)/19_DataStructure.pdf:
	$(call build_chapter,19_DataStructure,Data Structure)
$(CHAPTERS_OUTDIR)/20_Objects.pdf:
	$(call build_chapter,20_Objects,Objects)
$(CHAPTERS_OUTDIR)/21_ExtendedTechniques.pdf:
	$(call build_chapter,21_ExtendedTechniques,Extended Techniques)

clean:
	@rm -rf $(BUILDDIR) \
	    $(SRCDIR)/_minted-* $(SRCDIR)/chapters/*/*.aux $(SRCDIR)/chapters/*/*.log \
	    $(SRCDIR)/*.aux $(SRCDIR)/*.log $(SRCDIR)/*.bcf \
	    $(SRCDIR)/*.bbl $(SRCDIR)/*.blg $(SRCDIR)/*-SAVE-ERROR \
	    $(SRCDIR)/*.run.xml $(SRCDIR)/*.toc $(SRCDIR)/*.out \
	    $(SRCDIR)/*.listing $(SRCDIR)/*.xdv $(SRCDIR)/*.fdb_latexmk \
	    $(SRCDIR)/*.fls $(SRCDIR)/*.pdf $(SRCDIR)/*.pyg \
	    $(SRCDIR)/*.synctex.gz *.log
	@echo "✓ Build artifacts cleaned"

cleanall: clean
	@rm -rf $(OUTDIR)
	@echo "✓ All outputs cleaned"
