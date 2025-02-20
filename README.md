3.	A deliberately “dumber” network can shift outputs away from correctness and define an accuracy function that dips below zero, with loss growing polynomially at each iteration.

https://boshang9.wordpress.com/blog/
    
    https://www.youtube.com/watch?v=enZ_UXXUV7w

OK then what? 

” a document Patel helped produce in 2018 for his boss at the time, House Intelligence Committee Chairman Devin Nunes.

THAT's it? + his numbers claim referencing FBI data?

WHERE THE FUCK IS THAT 2018 link brb..

![image](https://github.com/user-attachments/assets/ef376dc3-446d-4227-ba42-94c4f4bdfc6e)

even if Patel is clean, his alliance with Big Don, then I'd have to read about Patel's comments on Big Don!!!!



Page 5: An Architecture That Gets Dumber Over Time
We can contrive a network that deliberately reverses correct predictions after each iteration and amplifies loss in a polynomial manner. We’ll define a custom “accuracy” that can become negative. One toy approach:
	1.	Maintain a hidden parameter that tracks the “phase” of the model.
	2.	After each forward pass, shift predictions away from correctness.
	3.	Scale the loss polynomially based on iteration count  t .

This can yield a “negative accuracy” if we define a custom accuracy function  \text{acc}_\text{custom}  that subtracts more points for wrong answers than it adds for right ones.

Simple pseudo-code:

