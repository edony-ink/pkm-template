---
title: <% tp.file.title %>
date: <% tp.file.creation_date("YYYY-MM-DD HH:mm:ss") %>
modify: <% tp.file.last_modified_date("YYYY-MM-DD HH:mm:ss") %>
author: edony.zpc
tags: 003-readings
aliases: 
---

# <% tp.file.title %>


## References
1. 

<%* 
    let fileName = tp.file.title
    let targetFile = tp.file.find_tfile("1.index/index-phrase/2022 phrase.md")
    this.app.vault.append(targetFile, "\n"+"- "+"[["+fileName+"]]")
%>