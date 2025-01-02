<%*
	let nowDate = new Date();
	let year = nowDate.getFullYear();
	let startDate = new Date(year,0,1);
	let days = (nowDate.getTime()-startDate.getTime())/(1000*60*60*24)
	let percent = 100*days/365
	let dayPercent = percent >= 100?percent.toFixed(0):percent.toPrecision(2)
	let content = "Year Progress:<div class='meter-snippet'><span style='width:" + dayPercent + "%'>" + dayPercent + "%</span></div>"
	let contentStyle = "Year Progress:<div class='progress-bar-grid-snippet'><div class='meter-snippet'><span style='width:" + dayPercent + "%'></span></div><div class='progress-bar-number-snippet'>" + dayPercent + "%</div></div>";
	if (tp.file.content.includes("Year Progress:<div class='meter-snippet'><span style='width:")) {
		new Notice("updating year progress bar!");
		let newContent = tp.file.content.replace(/(Year Progress:)([\s,\d, %,<,>,.]+)(.*)/, content);
		let file = this.app.workspace.activeLeaf.view.file;
		this.app.vault.modify(file, newContent);
	} else if (tp.file.content.includes("Year Progress:<div class='progress-bar-grid-snippet'><div class='meter-snippet'><span style='width:")) {
		new Notice("updating styled year progress bar!");
		let newContent = tp.file.content.replace(/(Year Progress:)([\s,\d, %,<,>,.]+)(.*)/, contentStyle);
		let file = this.app.workspace.activeLeaf.view.file;
		this.app.vault.modify(file, newContent);
	} else {
		new Notice("the file has no year progress bar, insert new one!");
		let newContent = tp.file.content + content;
		let file = this.app.workspace.activeLeaf.view.file;
		this.app.vault.modify(file, newContent);
	}
%>