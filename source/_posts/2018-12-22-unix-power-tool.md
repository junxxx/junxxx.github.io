---
layout: post
title: "Unix power tool"
date: 2018-12-22 
categories: unix
---
### Pattern Matching in case Statements
```
#!/bin/bash
case $1 in
    ?) ;; 
    ?*) ;;
    [yY]|[yY][eE][sS]) ;;
    /*/*[0-9]) ;;
    'What now?') ;;
    "$msgs") ;;
esac
```
list of all signals
```
kill -l 
```
what is trap in linux shell?

### Reading from the Keyboard

```
echo -n "Type the filename:"
read filename
echo -n "Enter first and last name"
read fn ln
#shell have built-in function
value=`line`
```

