# whiterabbitR

**whiterabbitR** is a lightweight R-based wrapper script designed to automate the execution of [WhiteRabbit](https://github.com/OHDSI/WhiteRabbit) for data profiling. By dynamically generating a `scanconfig.ini` file, running the WhiteRabbit binary (or whiteRabbit.bat on Windows) with that INI file, and processing the output, this script streamlines report generation. Though simple, it can be a useful tool to incorporate into your data scanning workflow.

## Overview

This tool simplifies running WhiteRabbit by automating configuration, execution, and post-processing steps. It supports a variety of configuration options and output formats (TSV or a renamed XLSX report), making it flexible for different use cases.

**Important:** This project would not be possible without the hard work and dedication of the White Rabbit developers. Their innovation in building and maintaining WhiteRabbit is the foundation for this wrapper, and we are deeply grateful for their contributions to the open-source community.

## Features

- **Automated Configuration:** Dynamically generates the `scanconfig.ini` file based on user-defined options.
- **Flexible Delimiter Support:** Handles both tab-delimited (TSV) and comma-separated (CSV) input files.
- **Customizable Scan Options:** Configure scanning depth, numeric statistics, minimum cell counts, and more.
- **Output Format Selection:** Produces either individual TSV files or a renamed XLSX report.
- **Cross-Platform Compatibility:** Works on UNIX-based and Windows systems with minimal dependencies.

## Requirements

This script requires the following R packages:
- `optparse`
- `data.table`
- `openxlsx`

Install these packages using:

```r
install.packages(c("optparse", "data.table", "openxlsx"))
```

## Installation

### 1. Clone the Repository

Clone this repository and navigate to the project directory:

```sh
git clone https://github.com/FritscheLab/whiterabbitR.git
cd whiterabbitR
```

### 2. Install WhiteRabbit

**Download and Install WhiteRabbit:**

1. **Download:** Obtain the latest version of WhiteRabbit from the [GitHub Releases page](https://github.com/OHDSI/WhiteRabbit/releases/latest). Download the `WhiteRabbit_vX.X.X.zip` file (where `X.X.X` is the current version).
2. **Unzip:** Extract the contents of the downloaded ZIP file to a location of your choice.
3. **Ensure Access:** Make sure the WhiteRabbit executable is accessible. The default path expected by the R script is:
   - On UNIX-based systems: `WhiteRabbit_v1.0.0/bin/whiteRabbit`
   - On Windows: `WhiteRabbit_v1.0.0/bin/whiteRabbit.bat`

   Adjust the path as needed using the `--whiterabbit` option when running the script.

## Usage

Run the `runWhiteRabbit.R` script with the required parameters:

```sh
Rscript runWhiteRabbit.R --working_folder <WORKDIR> [options]
```

### Required Argument:
- `--working_folder (-w)`: Path to the directory containing input files.

### Optional Arguments:

| Argument                         | Short | Default                                       | Description                                                               |
|----------------------------------|-------|-----------------------------------------------|---------------------------------------------------------------------------|
| `--whiterabbit`                  | `-l`  | `WhiteRabbit_v1.0.0/bin/whiteRabbit` (or `WhiteRabbit_v1.0.0/bin/whiteRabbit.bat` on Windows) | Path to the WhiteRabbit executable                                        |
| `--delimiter`                    | `-d`  | `tab`                                         | File delimiter (`tab` for TSV or any other for CSV with comma)            |
| `--scan_field_values`            | `-s`  | `yes`                                         | Scan field values (`yes` or `no`)                                         |
| `--min_cell_count`               | `-m`  | `20`                                          | Minimum cell count                                                        |
| `--max_distinct_values`          | `-M`  | `1000`                                        | Maximum distinct values                                                   |
| `--rows_per_table`               | `-r`  | `-1`                                          | Rows per table (`-1` for all)                                             |
| `--calculate_numeric_stats`      | `-c`  | `yes`                                         | Calculate numeric statistics (`yes` or `no`)                              |
| `--numeric_stats_sampler_size`   | `-n`  | `500`                                         | Sample size for numeric stats                                             |
| `--reportName`                   | `-R`  | `Report`                                      | Base name for output reports                                              |
| `--output_dir`                   | `-o`  | `.`                                           | Directory for output files                                                |
| `--output_format`                | `-f`  | `tsv`                                         | Output format (`tsv` for individual TSV files, `xlsx` for renamed report)   |

### Example Usage

1. **Run with Default Settings:**

   ```sh
   Rscript runWhiteRabbit.R -w /path/to/data
   ```

2. **Specify CSV Delimiter and Output Format as TSV:**

   ```sh
   Rscript runWhiteRabbit.R -w /path/to/data -d "," -f tsv
   ```

3. **Set Custom WhiteRabbit Executable Path:**

   ```sh
   Rscript runWhiteRabbit.R -w /path/to/data -l /custom/path/whiteRabbit
   ```

## Output

- **TSV Mode:** Processes `ScanReport.xlsx` into individual `.tsv` files.
- **XLSX Mode:** Renames the report based on the `--reportName` parameter.

## Acknowledgements

This project is a modest R-based wrapper intended to simplify the use of WhiteRabbit for data profiling. We wholeheartedly thank the White Rabbit developers for their hard work and innovation. Their dedication to building and maintaining WhiteRabbit makes tools like this possible, and we are grateful for their ongoing contributions to the open-source community.

## Error Handling

- Verifies the existence of input files and directories.
- Displays an error message if the WhiteRabbit execution fails.
- Terminates with an error if `ScanReport.xlsx` is not found after execution.

## License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.
