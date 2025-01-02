---
title: <% tp.file.title %>
description: ""
classes: ""
color: ""
type: ""
date: <% tp.file.creation_date("YYYY-MM-DD HH:mm:ss") %>
modify: <% tp.file.last_modified_date("YYYY-MM-DD HH:mm:ss") %>
era: ""
path: ""
tags:
  - timeline
showOnTimeline: true
cssclass: academia, academia-rounded
---


<%*

let folder = tp.file.folder(relative=true)
let oldFile = folder + "/" + tp.file.title + ".md"
let newFile = "2.fleeting/fleeting-fin/" + tp.file.title + ".md"
await app.vault.adapter.rename(oldFile, newFile)

%>