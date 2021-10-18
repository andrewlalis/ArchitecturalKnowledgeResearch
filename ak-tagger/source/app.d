import std.stdio;
import std.file;
import std.string;
import std.conv;

import fetching;
import ak_source_data;
import use_data;
import inspect_data;
import merge_data;

import asdf;
import commandr;

void main(string[] args) {
	parseArgs(args)
		.on("fetch", (args) => fetch())
		.on("use", (args) => useData(args.arg("file")))
		.on("inspect", (ProgramArgs args) {
			string filename = to!string(args.arg("file"));
			inspect(filename);
		})
		.on("merge", (args) => mergeMailingListDataSets(args.args("files"), args.arg("out")));
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
		.add(new Command("merge")
			.add(new Argument("out"))
			.add(new Argument("files").repeating.acceptsFiles))
		.defaultCommand("help");

	auto pArgs = prog.parse(args);
	pArgs.on("help", (ProgramArgs args) {
		prog.printHelp();
	});
	return pArgs;
}
