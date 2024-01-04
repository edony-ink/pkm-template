<%*
	let fileToWrite = tp.file.find_tfile(tp.file.path(true));
	let listedFolder = await this.app.vault.adapter.list('2.fleeting/fleeting-thoughts/');
	let contents = "";
	//listedFolder.files.forEach(async (f) => {
	for (const f of listedFolder.files) {
		console.log("filename = ", f);
		let targetFile = tp.file.find_tfile(f);
		let content = await this.app.vault.read(targetFile);
		contents = contents + "\n\n" + content;
	}
	await this.app.vault.modify(fileToWrite, contents);
%>
