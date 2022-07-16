<%*
	let startDate = new Date(2022,0,1)
	let nowDate = new Date()
	let days = (nowDate.getTime()-startDate.getTime())/(1000*60*60*24)
	let percent = 100*days/365
	let dayPercent = percent.toPrecision(3)
	let content = "Year Progress:<div class='meter'><span style='width:" + dayPercent + "%'>" + dayPercent + "%</span></div>"
	let newContent= tp.file.content.replace(/(Year Progress:)([\s,\d, %,<,>,.]+)(.*)/, content)
	let file = this.app.workspace.activeLeaf.view.file
	this.app.vault.modify(file, newContent)
%>