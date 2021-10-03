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
import std.array;

import asdf;
import commandr;

import ak_source_data;

void useData(string filename) {
    writefln("Using data from %s", filename);
	string fileContent = std.file.readText(filename);
	auto data = deserialize!MailingListDataSet(fileContent);
	writefln("Read data and found %d threads.", data.threads.length);
    
    auto prog = new Program("use")
		.add(new Command("help"))
        .add(new Command("exit"))
        .add(new Command("tags")
            .add(new Argument("thread", "The thread to get the tags for.")))
		.add(new Command("tag")
            .add(new Argument("thread", "The thread number to tag."))
            .add(new Argument("value", "The tag to add to the thread.")))
        .add(new Command("untag")
            .add(new Argument("thread", "The thread number to tag."))
            .add(new Argument("value", "The tag to remove from the thread.")))
        .add(new Command("export")
            .add(new Argument("thread", "The thread number to export.")))
        .add(new Command("clean"))
		.defaultCommand("help");

    bool shouldExit = false;

    while (!shouldExit) {
        string[] args = ["use"] ~ (readln().strip.split!isWhite).array;
        auto pArgs = prog.parse(args);
        pArgs
            .on("help", (ProgramArgs args) {
                prog.printHelp();
            })
            .on("tags", (args) => listTags(args, data))
            .on("tag", (args) => tag(args, data))
            .on("untag", (args) => untag(args, data))
            .on("export", (args) => exportThread(args, data))
            .on("clean", (args) => cleanExports())
            .on("exit", (ProgramArgs args) {
                shouldExit = true;
            });
    }

    std.file.write(filename, serializeToJsonPretty(data));
    writefln("Saved data to %s.", filename);
}

// Lists all tags for a given thread.
void listTags(ProgramArgs args, MailingListDataSet data) {
    uint threadIndex = to!uint(args.arg("thread"));
    if (threadIndex < 1 || threadIndex > data.threads.length) {
        writeln("Invalid thread.");
    } else {
        auto tags = data.threads[threadIndex - 1].tags;
        tags.sort();
        writefln("Thread %d is tagged with: %s", threadIndex, tags);
    }
}

// Adds a tag to a thread.
void tag(ProgramArgs args, ref MailingListDataSet data) {
    uint threadIndex = to!uint(args.arg("thread"));
    string tag = args.arg("value");
    if (threadIndex < 1 || threadIndex > data.threads.length) {
        writeln("Invalid thread.");
    } else {
        auto tags = data.threads[threadIndex - 1].tags;
        if (!tags.canFind(tag)) {
            tags ~= tag;
            data.threads[threadIndex - 1].tags = tags;
            writefln("Tagged thread %d with %s.", threadIndex, tag);
        } else {
            writefln("Thread %d already has the tag %s.", threadIndex, tag);
        }
    }
}

// Removes a tag from a thread.
void untag(ProgramArgs args, ref MailingListDataSet data) {
    uint threadIndex = to!uint(args.arg("thread"));
    string tag = args.arg("value");
    if (threadIndex < 1 || threadIndex > data.threads.length) {
        writeln("Invalid thread.");
    } else {
        auto tags = data.threads[threadIndex - 1].tags;
        if (tags.canFind(tag)) {
            tags = tags.remove!(a => a == tag);
            data.threads[threadIndex - 1].tags = tags;
            writefln("Removed tag %s from thread %d.", tag, threadIndex);
        } else {
            writefln("Thread %d isn't tagged with %s.", threadIndex, tag);
        }
    }
}

// Exports a thread and all its contents to a text file for easy viewing.
void exportThread(ProgramArgs args, MailingListDataSet data) {
    uint threadIndex = to!uint(args.arg("thread"));
    if (threadIndex < 1 || threadIndex > data.threads.length) {
        writeln("Invalid thread.");
        return;
    }
    auto thread = data.threads[threadIndex - 1];
    string filename = format("thread-%d.txt", threadIndex);
    auto file = File(filename, "w");
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
    writefln("Exported thread %d to %s.", threadIndex, filename);
}

// Removes all exported threads.
void cleanExports() {
    auto r = regex("thread-\\d+\\.txt");
    foreach (string filename; dirEntries("", SpanMode.shallow)) {
        if (!matchAll(filename, r).empty) {
            remove(filename);
            writefln("Removed %s", filename);
        }
    }
}
