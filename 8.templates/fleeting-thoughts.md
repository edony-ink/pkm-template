---
title: <% tp.file.title %>
date: <% tp.file.creation_date("YYYY-MM-DD HH:mm:ss") %>
modify: <% tp.file.last_modified_date("YYYY-MM-DD HH:mm:ss") %>
author: edony.zpc
tags: []
aliases:
  - <% tp.file.creation_date("YYYY-MM-DD") %>
---
%%
subject: #005-diary
status: 
type: 
publish: false
%%
# <% tp.file.title %>



#跟周至的一场超时空对话

<%* 
    let fileName = tp.file.title
    let targetFile = tp.file.find_tfile("1.index/index-life/thoughts")
    let content = await this.app.vault.read(targetFile)
    if (content.includes("- " + "[[" + fileName + "]]")) {
        new this.window.Notice("already have linked " + fileName + "in 1.index/index-life/thoughts")
    } else {
        this.app.vault.append(targetFile, "\n"+"- "+"[["+fileName+"]]")
    }
%>
