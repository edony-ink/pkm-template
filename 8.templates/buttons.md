```button
name Click Me to Init Diary
type line(2) text  
action title: <% tp.file.title %>
replace [2,2]
templater true
remove true
type line(3) text  
action date: <% tp.file.creation_date() %>
replace [3,3]
templater true
remove true
type line(4) text  
action modify: <% tp.file.last_modified_date("YYYY-MM-DD HH:mm:ss") %>
replace [4,4]
templater true
remove true
color bule
```


```button
name Click Me to Update
type line(4) text  
action modify: <% tp.file.last_modified_date("YYYY-MM-DD HH:mm:ss") %>
replace [4,4]
templater true
remove true
color bule
```
