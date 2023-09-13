
![AtomicEngine_logo](https://github.com/gosha-titov/AtomicEngine/assets/108375163/b0e28de9-5627-4b42-9d03-51f6b08ae5ee)

# Description

`TypoHunt` is a library for finding typos (missing, wrong, swapped or extra chars) by comparing the user text with the accurate one specified in advance.
It creates math models based on the given texts, applies many complicated algorithms and then makes the math result user-friendly by converting it back to text. 

This direct approach allows you to find typos of any complexity in the user text, and therefore allows you to draw the necessary conclusions.
But the more complex (longer and more monotonous) the source text and the more mistakes the user makes, the longer the execution time.
For this reason, you can use a bit different approach when texts are divided into sentences and sentences into words.
There is only one drawback: if the user put a space in the wrong place or put it accidentally, then there is an inaccuracy of the result.
