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
> ==[[<% tp.date.now("YYYY") %>]]==，甲辰年，我在杭州。记录自己的生活，经历自己的生命，观察这个可爱的世界。

## reminder
%%
- **yesterday**：
> [!abstract]-  [[Diary-<% tp.date.yesterday("YYYY-MM-DD") %>]]      ❌  =  **`= length(filter([[Diary-<% tp.date.yesterday("YYYY-MM-DD") %>]].file.tasks, (t) => !t.checked))`**，✅  =  **`= length(filter([[Diary-<% tp.date.yesterday("YYYY-MM-DD") %>]].file.tasks, (t) => t.checked))`**
> 
> ```dataview
> TASK FROM "4.permanent/permanent-diary/permanent-<% tp.date.now("YYYY") %>/Diary-<% tp.date.yesterday("YYYY-MM-DD") %>"
> ```

- **reminder**：记录 daily task，结合 Reminder 插件进行适当提醒
%%
- [ ] 

## memos
%%
memos：一个摘抄和浏览的地方，一些好词、好句、好的思考的聚集地，这里都是别人的东西，作为一个语料库，同时满足自己的收藏癖……
%%
$$\textcolor[RGB]{250,0,0}{------\varkappa------}$$

<%* 
    let fileName = tp.file.title
    let year = tp.date.now("YYYY")
    let targetFile = tp.file.find_tfile("1.index/index-diary/"+year)
    let content = await this.app.vault.read(targetFile)
    if (content.includes("- " + "[[" + fileName + "]]")) {
        new this.window.Notice("already have linked " + fileName + "in " + year)
    } else {
        this.app.vault.append(targetFile, "\n"+"- "+"[["+fileName+"]]")
    }
%>