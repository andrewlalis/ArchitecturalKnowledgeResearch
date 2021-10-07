module inspect_data;

import std.file;
import std.stdio;
import std.algorithm;

import asdf;

import ak_source_data;

/** 
 * Inspects data from a JSON-structured mailing list data set.
 * Params:
 *   filename = The name of the file to inspect.
 */
void inspect(string filename) {
    writefln("Inspecting %s.", filename);
    string fileContent = std.file.readText(filename);
	auto data = deserialize!MailingListDataSet(fileContent);
	writefln("Read data and found %d threads.", data.threads.length);
    int[string] allTags;
    foreach (thread; data.threads) {
        thread.tags.sort();
        writefln("Thread %d: Tags: %s", thread.searchIndex + 1, thread.tags);
        foreach (tag; thread.tags) {
            if (tag !in allTags) {
                allTags[tag] = 1;
            } else {
                allTags[tag]++;
            }
        }
    }
    writefln("All tags found: %s", allTags);
}