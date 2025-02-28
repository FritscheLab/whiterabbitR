#!/usr/bin/env Rscript
# runWhiteRabbit.R
#
# This script builds a scanconfig.ini file for WhiteRabbitR based on provided options,
# runs the WhiteRabbit binary (or whiteRabbit.bat on Windows) with that INI file,
# and then produces output.
# The output can be either individual TSV files (default) or a renamed XLSX report,
# depending on the --output_format option.
#
# Required packages: optparse, data.table, openxlsx

suppressPackageStartupMessages({
  library(optparse)
  library(data.table)
  library(openxlsx)
})

# Set default WhiteRabbit binary based on OS
default_whiterabbit <- if (.Platform$OS.type == "windows") {
  "WhiteRabbit_v1.0.0/bin/whiteRabbit.bat"
} else {
  "WhiteRabbit_v1.0.0/bin/whiteRabbit"
}

# Define command-line options
option_list <- list(
  make_option(c("-w", "--working_folder"),
    type = "character", default = NULL,
    help = "Working folder (required) where the input files are located", metavar = "WORKDIR"
  ),
  make_option(c("-l", "--whiterabbit"),
    type = "character", default = default_whiterabbit,
    help = sprintf("Path to the WhiteRabbit binary [%s]", default_whiterabbit), metavar = "WHITERABBIT"
  ),
  make_option(c("-d", "--delimiter"),
    type = "character", default = "tab",
    help = "Delimiter to use: 'tab' (for tab-delimited files) or any other value (for CSV files, will use comma) [default: %default]", metavar = "DELIM"
  ),
  make_option(c("-s", "--scan_field_values"),
    type = "character", default = "yes",
    help = "Whether to scan field values ('yes' or 'no') [default: %default]", metavar = "SCAN_VALUES"
  ),
  make_option(c("-m", "--min_cell_count"),
    type = "integer", default = 20,
    help = "Minimum cell count [default: %default]", metavar = "MINCELL"
  ),
  make_option(c("-M", "--max_distinct_values"),
    type = "integer", default = 1000,
    help = "Maximum distinct values [default: %default]", metavar = "MAXDIST"
  ),
  make_option(c("-r", "--rows_per_table"),
    type = "integer", default = -1,
    help = "Rows per table (-1 for all) [default: %default]", metavar = "ROWSPERTABLE"
  ),
  make_option(c("-c", "--calculate_numeric_stats"),
    type = "character", default = "yes",
    help = "Calculate numeric statistics ('yes' or 'no') [default: %default]", metavar = "CALC_NUM"
  ),
  make_option(c("-n", "--numeric_stats_sampler_size"),
    type = "integer", default = 500,
    help = "Numeric stats sampler size [default: %default]", metavar = "NUM_SAMPLER"
  ),
  make_option(c("-R", "--reportName"),
    type = "character", default = "Report",
    help = "Base name for output report files [default: %default]", metavar = "REPORTNAME"
  ),
  make_option(c("-o", "--output_dir"),
    type = "character", default = ".",
    help = "Output directory [default: current directory]", metavar = "OUTPUTDIR"
  ),
  make_option(c("-f", "--output_format"),
    type = "character", default = "tsv",
    help = "Output format: 'tsv' for individual TSV files (default) or 'xlsx' for a renamed XLSX file", metavar = "OUTPUT_FORMAT"
  )
)

parser <- OptionParser(option_list = option_list)
opts <- parse_args(parser)

if (is.null(opts$working_folder)) {
  print_help(parser)
  stop("Error: --working_folder must be specified.", call. = FALSE)
}

# Normalize working and output directories
workdir <- normalizePath(opts$working_folder, mustWork = TRUE)
output_dir <- normalizePath(opts$output_dir, mustWork = FALSE)
message("Working folder: ", workdir)

# Determine file extension and delimiter based on the provided delimiter option
if (tolower(opts$delimiter) == "tab") {
  file_pattern <- "\\.tsv$"
  delimiter_value <- "tab"
} else {
  file_pattern <- "\\.csv$"
  delimiter_value <- ","
}

# List files matching the expected extension in the working folder
files <- list.files(path = workdir, pattern = file_pattern, full.names = FALSE)
if (length(files) == 0) {
  stop("No files matching the expected extension found in the working folder.", call. = FALSE)
}
tables_to_scan <- paste(files, collapse = ",")

# Build scanconfig.ini content
ini_lines <- c(
  sprintf("WORKING_FOLDER = %s/", workdir),
  "DATA_TYPE = Delimited text files",
  sprintf("DELIMITER = %s", delimiter_value),
  sprintf("TABLES_TO_SCAN = %s", tables_to_scan),
  sprintf("SCAN_FIELD_VALUES = %s", opts$scan_field_values),
  sprintf("MIN_CELL_COUNT = %d", opts$min_cell_count),
  sprintf("MAX_DISTINCT_VALUES = %d", opts$max_distinct_values),
  sprintf("ROWS_PER_TABLE = %d", opts$rows_per_table),
  sprintf("CALCULATE_NUMERIC_STATS = %s", opts$calculate_numeric_stats),
  sprintf("NUMERIC_STATS_SAMPLER_SIZE = %d", opts$numeric_stats_sampler_size)
)
ini_content <- paste(ini_lines, collapse = "\n")

# Write the INI file to a temporary directory
ini_file_path <- file.path(tempdir(), "scanconfig.ini")
message("Writing configuration to ", ini_file_path)
writeLines(ini_content, con = ini_file_path)

# Build and run the WhiteRabbit command using the binary (or .bat for Windows)
command <- sprintf("%s -ini %s", opts$whiterabbit, ini_file_path)
message("Running command: ", command)
ret <- system(command)
if (ret != 0) {
  stop("WhiteRabbit command failed.", call. = FALSE)
}

# Check for the generated ScanReport.xlsx in the working folder
scan_report_path <- file.path(workdir, "ScanReport.xlsx")
if (!file.exists(scan_report_path)) {
  stop("ScanReport.xlsx was not generated in the working folder.", call. = FALSE)
}
message("Found ScanReport.xlsx. Processing report...")

# Process the report based on the chosen output format
if (tolower(opts$output_format) == "tsv") {
  wb <- loadWorkbook(scan_report_path)
  sheet_names <- getSheetNames(scan_report_path)

  for (sheet in sheet_names) {
    message("Processing sheet: ", sheet)
    data <- read.xlsx(wb, sheet = sheet)

    if (sheet == "_" || sheet == "") {
      output_filename <- paste0(opts$reportName, "_ScanConfigurations.ini")
    } else {
      sheet_clean <- sub("\\.tsv$", "", sheet)
      output_filename <- paste0(opts$reportName, "_", sheet_clean, ".tsv")
    }

    output_path <- file.path(output_dir, output_filename)
    fwrite(data, file = output_path, sep = "\t")
    message("Written file: ", output_path)
  }
} else if (tolower(opts$output_format) == "xlsx") {
  new_scan_report_name <- paste0(opts$reportName, "_ScanReport.xlsx")
  new_scan_report_path <- file.path(output_dir, new_scan_report_name)
  if (file.rename(scan_report_path, new_scan_report_path)) {
    message("Renamed ScanReport.xlsx to ", new_scan_report_path)
  } else {
    warning("Failed to rename ScanReport.xlsx.")
  }
} else {
  stop("Invalid output format specified. Use 'tsv' or 'xlsx'.", call. = FALSE)
}
