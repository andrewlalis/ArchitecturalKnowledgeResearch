import std.stdio;
import std.file;
import std.string;
import std.conv;

import fetching;
import ak_source_data;
import use_data;
import inspect_data;

import asdf;
import commandr;

void main(string[] args) {
	parseArgs(args)
		.on("fetch", (args) => fetch(args))
		.on("use", (args) => use(args))
		.on("inspect", (ProgramArgs args) {
			string filename = to!string(args.arg("file"));
			inspect(filename);
		});
}

void fetch(ProgramArgs args) {
	writeln("Enter the Lucene search query to use:");
	auto queryStr1 = readln();
	auto query = MailingListQuery(queryStr1, [10, 11, 12, 13], 0, 50);
	auto result = searchMailingLists(query);
	writefln("Found %d email threads matching this query.", result.threads.length);
	writeln("Enter the name of the JSON file to save results to.");
	auto filename = strip(readln());
	std.file.write(filename, serializeToJsonPretty(result));
}

void use(ProgramArgs args) {
	auto filename = args.arg("file");
	useData(filename);
}

private ProgramArgs parseArgs(string[] args) {
	auto prog = new Program("ak-tagger")
		.summary("Architectural knowledge categorization program.")
		.add(new Command("help"))
		.add(new Command("fetch"))
		.add(new Command("use")
			.add(new Argument("file", "The file to use.")))
		.add(new Command("inspect")
			.add(new Argument("file", "The file to inspect.")))
		.defaultCommand("help");

	auto pArgs = prog.parse(args);
	pArgs.on("help", (ProgramArgs args) {
		prog.printHelp();
	});
	return pArgs;
}
