---

title: <% tp.file.title %>
date: <% tp.file.creation_date("YYYY-MM-DD HH:mm:ss") %>
modify: <% tp.file.last_modified_date("YYYY-MM-DD HH:mm:ss") %>
author: edony.zpc
tags: [  ]
aliases: [  ]
featured: false
published: false
excerpt: ""
feature_image: ""

---
%%
subject: #004-topics #blogging
status: 
type: 
excerpt:
%%
# <% tp.file.title %>


## References
1. 

<%* 
    let fileName = tp.file.title;
    let targetFile = tp.file.find_tfile("1.index/topics");
    let content = await this.app.vault.read(targetFile);
    if (content.includes("- " + "[[" + fileName + "]]")) {
        new this.window.Notice("already have linked [[" + fileName + "]] in topics");
    } else {
        let newContent = content.replace(/(## GTD\n)/, "## GTD\n- "+"[["+fileName+"]]\n");
        this.app.vault.modify(targetFile, newContent);
    }
%>