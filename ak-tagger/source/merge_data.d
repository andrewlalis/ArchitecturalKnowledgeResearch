module merge_data;

import std.stdio;
import std.algorithm;
import std.file;
import std.conv;
import std.array;
import asdf;
import collections.sortedlist;

import ak_source_data;

void mergeMailingListDataSets(string[] inputFiles, string outputFile) {
    writefln("Merging data sets from %s into %s...", inputFiles, outputFile);
    auto allMailingListIds = SortedList!(uint, "a > b", false)([]);
    
    uint conflictCount = 0;
    EmailThread[] allEmails = [];
    auto threadAppender = appender(&allEmails);
    alias threadCmp = (t1, t2) => t1.searchIndex < t2.searchIndex;
    foreach (filename; inputFiles) {
        string content = std.file.readText(filename);
        auto dataSet = deserialize!MailingListDataSet(content);
        allMailingListIds = allMailingListIds ~ dataSet.query.mailingListIds;
        
        foreach (emailThread; dataSet.threads) {
            bool isNew = true;
            foreach (ref existingThread; allEmails) {
                if (existingThread.id == emailThread.id) {
                    isNew = false;
                    if (existingThread.tags != emailThread.tags) {
                        mergeConflictingThreads(existingThread, emailThread);
                        conflictCount++;
                    }
                    break;
                }
            }
            if (isNew) {
                threadAppender ~= emailThread;
            }
        }
    }
    allEmails.sort!(threadCmp, SwapStrategy.stable);

    writefln("Read %d unique email threads.", allEmails.length);
    if (conflictCount > 0) {
        writefln("Found %d conflicts. Look for threads tagged \"CONFLICT\".", conflictCount);
    }
    auto combinedQuery = MailingListQuery("", allMailingListIds.arrayOf, 0, to!uint(allEmails.length));
    MailingListDataSet result = MailingListDataSet(combinedQuery, allEmails);
    std.file.write(outputFile, serializeToJsonPretty(result));
}

private void mergeConflictingThreads(ref EmailThread existing, ref EmailThread other) {
    if (existing.tags != other.tags) {
        foreach (tag; other.tags) {
            if (!existing.tags.canFind(tag)) {
                existing.tags ~= tag;
            }
        }
        existing.tags ~= "CONFLICT";
        existing.tags.sort();
    }
}