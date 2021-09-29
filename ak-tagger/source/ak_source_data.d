module ak_source_data;

import std.datetime;

struct MailingList {
    ulong id;
    string name;
    string url;
}

struct Email {
    ulong id;
    uint threadIndex;
    string messageId;
    ulong date;
    string inReplyTo;
    string sentFrom;
    string subject;
    string body;
    string[] tags;
}

struct EmailThread {
    ulong id;
    uint searchIndex;
    ulong date;
    MailingList mailingList;
    string subject;
    uint size;
    string[] tags;
    Email[] emails;
}

struct MailingListQuery {
    string queryString;
    uint[] mailingListIds;
    uint page;
    uint size;
}

struct MailingListDataSet {
    MailingListQuery query;
    EmailThread[] threads;
}
