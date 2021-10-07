# AK-Tagger
The architectural knowledge tagger program is a companion to the ArchDetector web application, that provides a more efficient interface for tagging and evaluating the categorization of sources of architectural knowledge.

## Usage
To compile and run this program, you will first need to have a [D compiler](https://dlang.org/download.html) installed on your system. Then, open a terminal in this directory (after cloning this repository), and run `dub build`. This should produce an `ak-tagger` executable, which you can run.

There are several major functionalities of the tagger program:
- Fetching and parsing search results from the ArchDetector.
- Categorizing fetched results with various tags.
- Inspecting categorized results and doing analysis.

## Fetching
To fetch data from ArchDetector for use with this tool, you can use the `fetch` subcommand. This will provide a simple interactive prompt where you can specify the search parameters, perform the search, and save the results.

## Interacting with Data
To view and interact with the data from a particular data set, use the `use <file>` subcommand. This will provide a simple interactive prompt for navigating the data set, viewing individual or sequential data sources, and adding/removing tags from certain sources.

More specifically, the following commands are available from within the `use` interactive interface:

- `tags <thread>` List all tags for the given thread.
- `tag <thread> <tag>` Add a tag to a thread.
- `untag <thread> <tag>` Remove a tag from a thread.
- `export <thread>` Export a thread to a text file for easy viewing.
- `export-untagged` Exports all threads which do not yet have any tags. Useful when you just want to tag lots of things.
- `clean` Removes all exported text files.
- `clean-tagged` Removes all thread text files for threads which have tags. Useful for clearing out exported threads after you've tagged them.
- `save` Saves all changes.
- `exit` Exit the interactive interface, and save all changes.

> Where a `<thread>` argument is required, provide the "search index" of the thread; that is, if the data set contains 5 threads, the first one has a search index of 1, the second has 2, then 3, and so on.

## Inspecting the Data
To gather aggregate information about a categorized data set, use the `inspect <file>` subcommand.
