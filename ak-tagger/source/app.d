import std.stdio;
import std.file;
import std.string;

import fetching;
import ak_source_data;
import use_data;

import asdf;
import commandr;

void main(string[] args) {
	auto prog = new Program("ak-tagger")
		.summary("Architectural knowledge categorization program.")
		.add(new Command("help"))
		.add(new Command("fetch"))
		.add(new Command("use")
			.add(new Argument("file", "The file to use.")))
		.add(new Command("export")
			.add(new Option("f", "file", "The file to export to.")))
		.add(new Command("import")
			.add(new Option("f", "file", "The file to import from.").acceptsFiles()))
		.defaultCommand("help");

	auto pArgs = prog.parse(args);

	pArgs
		.on("help", (ProgramArgs args) {
			prog.printHelp();
		})
		.on("fetch", (args) => fetch(args))
		.on("use", (args) => use(args));
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
