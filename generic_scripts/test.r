FOO <- function(x,y) {
 x + y 
}

attr(FOO, "comment") <- "FOO performs simple addition"

#This can be arbitrary. "comment" is special. see ?comment for details.
attr(FOO, "help") <- "FOO expects two numbers, and it will add them together"

attributes(FOO)