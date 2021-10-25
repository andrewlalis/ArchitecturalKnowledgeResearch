module fetching;

import std.stdio;
import std.conv;
import std.net.curl;
import std.format;
import std.algorithm;
import std.uri;
import std.range;
import std.file;
import std.datetime;
import std.parallelism;
import std.string;

import asdf;

import ak_source_data;

const string BASE_URL = "http://localhost:8080/api/v1";
const string SEARCH_URL = BASE_URL ~ "/email-thread/search?q=%s&mailingListIds=%s&page=%d&size=%d";
const string EMAILS_URL = BASE_URL ~ "/email-thread/%d/email?sort=date";

void fetch() {
	writeln("Enter the Lucene search query to use:");
	auto queryStr = readln();
    writeln("Enter the mailing list ids to use (comma-separted):");
    auto mailingListIdsStr = readln();
    uint[] mailingListIds = mailingListIdsStr.split(",").map!(a => to!uint(strip(a))).array;
    writeln("How many results would you like to fetch?");
    uint size = to!uint(strip(readln()));
    writeln("What page of results would you like (starting from 0)?");
    uint page = to!uint(strip(readln()));
	auto query = MailingListQuery(queryStr, mailingListIds, page, size);
    writefln("Will search using the following query: %s.\n\tExit the program (CTRL+C) to change parameters.", query);
	auto result = searchMailingLists(query);
	writefln("Found %d email threads matching this query.", result.threads.length);
    writeln("Should the results be filtered to remove automated messages?");
    string input = readln.strip.toLower();
    auto shouldFilter = input == "yes" || input == "y";
    if (shouldFilter) {
        result = filterResults(result);
        writefln("After filtering, %d email threads remain.", result.threads.length);
    }
	writeln("Enter the name of the JSON file to save results to.");
	string filename = strip(readln());
	std.file.write(filename, serializeToJsonPretty(result));
}

/** 
 * Searches the ArchDetector mailing lists using the given query data, and
 * returns a sorted list of the top email thread results.
 * Params:
 *   query = The search query information.
 * Returns: A result of searching, containing zero or more email threads.
 */
MailingListDataSet searchMailingLists(MailingListQuery query) {
    auto const url = format(
        SEARCH_URL,
        query.queryString.encode,
        query.mailingListIds.map!(id => to!string(id)).joiner(","),
        query.page,
        query.size
    );
    auto responseJson = parseJson(get(url));
    EmailThread[] threads;
    auto pool = new TaskPool();
    auto app = appender(&threads);
    uint index = 0;
    foreach (threadJson; responseJson["content"].byElement) {
        pool.put(task!parseAndAppendEmailThread(app, threadJson, index++));
    }
    pool.finish(true);
    threads.sort!((a, b) => a.searchIndex < b.searchIndex);
    return MailingListDataSet(query, threads);
}

void parseAndAppendEmailThread(RefAppender!(EmailThread[]) app, Asdf json, int index) {
    app.put(parseThread(json, index));
}

EmailThread parseThread(Asdf threadJson, uint searchIndex) {
    EmailThread thread;
    thread.searchIndex = searchIndex;
    thread.id = to!ulong(threadJson["id"]);
    thread.date = (cast(SysTime) threadJson["date"]).toUnixTime;
    MailingList ml;
    ml.id = to!ulong(threadJson["mailingList"]["id"]);
    ml.name = cast(string) threadJson["mailingList"]["name"];
    ml.url = cast(string) threadJson["mailingList"]["url"];
    thread.mailingList = ml;
    thread.subject = cast(string) threadJson["subject"];
    thread.size = to!uint(threadJson["size"]);
    thread.tags = new string[0];
    thread.emails = [];

    auto app = appender(&thread.emails);
    uint emailIndex = 0;
    auto emailsJson = parseJson(get(format(EMAILS_URL, thread.id)));
    foreach (emailJson; emailsJson.byElement) {
        app.put(parseEmail(emailJson, emailIndex++));
    }
    return thread;
}

Email parseEmail(Asdf emailJson, uint threadIndex) {
    Email email;
    email.threadIndex = threadIndex;
    email.id = to!ulong(emailJson["id"]);
    email.messageId = cast(string) emailJson["messageId"];
    email.date = (cast(SysTime) emailJson["date"]).toUnixTime;
    email.subject = cast(string) emailJson["subject"];
    email.inReplyTo = cast(string) emailJson["inReplyTo"];
    email.sentFrom = cast(string) emailJson["sentFrom"];
    email.body = cast(string) emailJson["body"];
    email.tags = [];
    return email;
}

string toSimpleTimestamp(SysTime time) {
	return format("%d-%d-%d_%02d-%02d-%02d", time.year, time.month, time.day, time.hour, time.minute, time.second);
}

MailingListDataSet filterResults(MailingListDataSet data) {
    EmailThread[] filteredThreads = [];
    uint filteredThreadIndex = 0;
    foreach (thread; data.threads) {
        if (!shouldRemoveThread(thread)) {
            thread.searchIndex = filteredThreadIndex++;
            filteredThreads ~= thread;
        }
    }
    data.threads = filteredThreads;
    return data;
}

bool shouldRemoveThread(EmailThread thread) {
    foreach (email; thread.emails) {
        auto i = email.body.indexOf("builds.apache.org/job");
        if (i != -1) return true;
    }
    return false;
}
