# AK-Tagger
The architectural knowledge tagger program is a companion to the ArchDetector web application, that provides a more efficient interface for tagging and evaluating the categorization of sources of architectural knowledge.

## Usage
There are several major functionalities of the tagger program:
- Fetching and parsing search results from the ArchDetector.
- Categorizing fetched results with various tags.
- Exporting and importing data sets.

## Fetching
To fetch data from ArchDetector for use with this tool, you can use the `fetch` subcommand. This will provide a simple interactive prompt where you can specify the search parameters, perform the search, and save the results.

## Interacting with Data
To view and interact with the data from a particular data set, use the `use <file>` subcommand. This will provide a simple interactive prompt for navigating the data set, viewing individual or sequential data sources, and adding/removing tags from certain sources.

## Exporting and Importing
By default, all data is stored in JSON format, and can be exported or imported by simply copying files.
