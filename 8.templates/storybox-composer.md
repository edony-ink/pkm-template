---
title: <% tp.file.title %>
date: <% tp.file.creation_date("YYYY-MM-DD HH:mm:ss") %>
modify: <% tp.file.last_modified_date("YYYY-MM-DD HH:mm:ss") %>
author: edony.zpc
tags: 002-soft-skills 写作 故事箱
aliases: 
---

# <% tp.file.title %>



<%* 
    let fileName = tp.file.title
    let targetFile = tp.file.find_tfile("1.index/index-life/Storybox.md")
    this.app.vault.append(targetFile, "\n"+"- "+"[["+fileName+"]]")
%>