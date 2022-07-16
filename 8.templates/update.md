<%* 
    let updateData = tp.file.last_modified_date("YYYY-MM-DD HH:mm:ss")
    let newContent= tp.file.content.replace(/(modify:)([\s,\d,-,:]+)(.*)/, "modify: "+updateData)
    let file = this.app.workspace.activeLeaf.view.file
    this.app.vault.modify(file, newContent) 
%>