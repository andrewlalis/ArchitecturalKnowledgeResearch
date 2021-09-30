module use_data;

import std.stdio;
import std.file;
import std.string;
import std.algorithm;
import std.uni;
import std.regex;
import std.range;
import std.conv;
import std.datetime;

import asdf;

import ak_source_data;

void useData(string filename) {
    writefln("Using data from %s", filename);
	string fileContent = std.file.readText(filename);
	auto data = deserialize!MailingListDataSet(fileContent);
	writefln("Read data and found %d threads.", data.threads.length);
    navigateThreads(data);
}

void navigateThreads(MailingListDataSet data) {
    uint page = 0;
    uint size = 5;
    bool shouldExit = false;
    while (!shouldExit) {
        auto lowerBound = page * size;
        auto upperBound = min(data.threads.length, (page * size + size));
        auto threadsToDisplay = data.threads[lowerBound .. upperBound];
        writefln(
            "Displaying page %d of %d pages of email threads.\n-----",
            page + 1,
            (data.threads.length / size) + 1
        );
        foreach (thread; threadsToDisplay) {
            writefln(
                "Thread %d of %d: %d emails\n\tSubject: %s\n\tTags: %s",
                thread.searchIndex + 1,
                data.threads.length,
                thread.emails.length,
                thread.subject,
                thread.tags
            );
        }
        writeln("Enter \"n\" for next page, \"p\" for previous page, \"e\" to exit, or the number of a thread to view it.");
        string cmd = toLower(strip(readln()));
        if (cmd == "n" && (page * size + size) < data.threads.length) {
            page++;
        } else if (cmd == "p" && (page > 0)) {
            page--;
        } else if (startsWith(cmd, "export")) {
            auto captures = matchFirst(cmd, "\\d+");
            if (!captures.empty) {
                uint index = to!uint(captures.front);
                if (index >= 0 && index < data.threads.length) {
                    exportThread(data.threads[index]);
                }
            }
        } else if (cmd == "e" || cmd == "exit" || cmd == "quit") {
            shouldExit = true;
        } else {
            auto captures = matchFirst(cmd, "(?:tag) \\d+ \\w+");
            // TODO: Implement adding and removing tags from threads.
            if (!captures.empty) {
                string[] words = captures.front.split;
                writeln(words);
            }
        }
    }
}

void navigateThread(EmailThread thread) {
    uint currentEmailIndex = 0;
    bool shouldExit = false;
    while (!shouldExit) {
        writefln(
            "Viewing email %d of %d in thread %d.\n\tThread tags:%s\n-----",
            currentEmailIndex + 1,
            thread.emails.length,
            thread.searchIndex,
            thread.tags
        );
        auto email = thread.emails[currentEmailIndex];
        writefln(
            "MessageId: %s\nDate: %s\nIn Reply To: %s\nSent From: %s\nSubject: %s",
            email.messageId,
            SysTime.fromUnixTime(email.date).toISOExtString,
            email.inReplyTo,
            email.sentFrom,
            email.subject
        );
        writefln("\n%s\n", email.body);
        string cmd = toLower(strip(readln()));
        if (cmd == "n" && currentEmailIndex + 1 < thread.emails.length) {
            currentEmailIndex++;
        } else if (cmd == "p" && currentEmailIndex > 0) {
            currentEmailIndex--;
        } else if (cmd == "export") {

        } else if (cmd == "e" || cmd == "exit" || cmd == "quit") {
            shouldExit = true;
        }
    }
}

void exportThread(EmailThread thread) {
    auto file = File(format("thread-%d.txt", thread.searchIndex), "w");
    file.writefln(
        "Thread %d\nId: %d\nDate: %s\nSubject: %s\n\nTags: %s\n\n\n",
        thread.searchIndex,
        thread.id,
        SysTime.fromUnixTime(thread.date).toISOExtString,
        thread.subject,
        thread.tags
    );
    for (int i = 0; i < thread.emails.length; i++) {
        auto email = thread.emails[i];
        file.writefln(
            "Email %d of %d\n\tMessage Id: %s\n\tDate: %s\n\tFrom: %s\n\tIn Reply To: %s\n\tSubject: %s\n\tTags: %s",
            email.threadIndex + 1,
            thread.emails.length,
            email.messageId,
            SysTime.fromUnixTime(email.date).toISOExtString,
            email.sentFrom,
            email.inReplyTo,
            email.subject,
            email.tags
        );
        file.writefln("\n%s\n", email.body);
    }
    file.close();
}
