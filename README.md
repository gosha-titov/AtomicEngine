
![AtomicEngine_logo](https://github.com/gosha-titov/AtomicEngine/assets/108375163/b0e28de9-5627-4b42-9d03-51f6b08ae5ee)

# Description

`AtomicEngine` finds typos (missing, wrong, swapped or extra chars) by comparing user text with the accurate one.
It creates math models based on the given texts, applies many complicated algorithms and then makes the math result user-friendly by converting it to text. 

In theory, `AtomicEngine` works for texts of any length, but in practice texts are divided into sentences and sentences into words.
Otherwise, the execution time tends to infinity, since the count of operations inevitably increases.
This approach has only one drawback: if the user put a space in the wrong place or put it accidentally, then there is an inaccuracy of the result.
You can still use direct calculation if you're sure that a word or phrase has a small length: 10-20 chars.
But this approach also has a drawback: it is not possible to understand that the user entered all the words correctly but not in the correct order.
