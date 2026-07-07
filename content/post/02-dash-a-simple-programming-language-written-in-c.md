+++
date = "2015-08-12T21:51:26-05:00"
title = "Dash, a simple programming language written in C"
slug = "dash-lang"
aliases = [
  "dash-a-simple-programming-language-written-in-c/",
  "/post/dash-a-simple-programming-language-written-in-c/",
]
description = "In my spare time this summer I set out to write a programming language from scratch. I've always been interested in learning about how programming languages worked, and sometimes the best way to learn something is to get your hands dirty. So after quite a few nights of work, I created Dash, a very simple procedural language, virtual machine, and bytecode. Dash is nothing extraordinary. It won't be the next Python or Javascript. But it was a great learning experience and is pretty cool. I thought it would neat if others could see the end result, so I've hooked up a web server to run the compiler and virtual machine."
draft = false
tags = ["plang", "project"]
disqusid = "1100"
+++

In my spare time this summer I set out to write a programming language from scratch. I've always been interested in learning about how programming languages worked, and sometimes the best way to learn something is to get your hands dirty. So after quite a few nights of work, I created [Dash](https://github.com/eqrion/dash/), a very simple procedural language, virtual machine, and bytecode.

Dash is nothing extraordinary. It won't be the next Python or Javascript. But it was a great learning experience and is pretty cool. I thought it would neat if others could see the end result, so I've hooked up a web server to run the compiler and virtual machine.

<!--more-->

[Update 10/5/2018 - The web server is no longer being maintained, the source snippets are not interactive]

So without further ado, let's write some Dash!

<form>
	<textarea id="input1" style="display:block; width:100%;" rows="19" style="resize:none">
def main : () -> (integer)
{
	print_c(72);
	print_c(101);
	print_c(108);
	print_c(108);
	print_c(111);
	print_c(44);
	print_c(32);
	print_c(87);
	print_c(111);
	print_c(114);
	print_c(108);
	print_c(100);
	print_c(33);
	print_c(10);

	return 0;
}
	</textarea>
    <div class="form-group">
	    <div class="btn-group" role="group">
		    <button type="button" class="btn btn-default" onclick="compile(document.getElementById('input1'), document.getElementById('output1'), document.getElementById('outputFrame1'))">Execute</button>
		    <button type="button" class="btn btn-default" onclick="disassemble(document.getElementById('input1'), document.getElementById('output1'), document.getElementById('outputFrame1'))">Disassemble</button>
	    </div>
    </div>
    <div style="display:none" id="outputFrame1">
	    <label for="output">Output:</label>
	    <div class="well">
	        <p id="output1"></p>
	    </div>
    </div>
</form>

So what're you looking at?

Dash is similar to C, with a few style differences. Here we define a procedure *main* that accepts no variables and outputs an integer. Dash has only two data types it recognizes, signed integers and floating point numbers. There are no arrays, data structures, or even strings. This certainly makes Hello World difficult.

So what in the world is going on here?

Well Dash can't handle strings, but it can handle characters. So we use an external procedure to print each character of "Hello, world". We make do with what we have, right?

Let's take a look at some examples more suited to Dash. Here's a calculation of Pi using a [series](https://en.wikipedia.org/wiki/Leibniz_formula_for_%CF%80):

<form>
    <textarea id="input2" style="display:block; width:100%;" rows="18" style="resize:none">
def pi : (term : integer) -> (real)
{
	let n, sum, is_odd_term = 0, 0., 1;

	while (n <= term)
	{
		if (is_odd_term)
		{
			sum = sum + 1. / (2. * (real)n + 1.);

			is_odd_term = 0;
		}
		else
		{
			sum = sum - 1. / (2. * (real)n + 1.);

			is_odd_term = 1;
		}

		n = n + 1;
	}

	return sum * 4.;
}

def main : () -> (integer)
{
	print_r(pi(100000));

	return 0;
}
	</textarea>
    <div class="form-group">
        <div class="btn-group" role="group">
            <button type="button" class="btn btn-default" onclick="compile(document.getElementById('input2'), document.getElementById('output2'), document.getElementById('outputFrame2'))">Execute</button>
            <button type="button" class="btn btn-default" onclick="disassemble(document.getElementById('input2'), document.getElementById('output2'), document.getElementById('outputFrame2'))">Disassemble</button>
        </div>
    </div>
    <div style="display:none" id="outputFrame2">
        <label for="output">Output:</label>
        <div class="well">
            <p id="output2"></p>
        </div>
    </div>
</form>

As you can see, the first syntax difference from C is in variable declarations. Multiple variables can be defined at a time, and their types are inferred from the right hand side of the declaration. This also means we can't declare a variable without defining it. The only time that we explicitly specify type is in procedure declarations, where type can't be inferred.

Dash also has some standard statements, such as *If*, *While* statements. Some notable exceptions though are *For* loops, and *Break* statements. There's also no implicit casts, not even for constants. The type of a constant is an integer unless there is a decimal part. So you need to add a trailing '.' on integer constants to make them real constants. Otherwise you'll probably get an error about mismatching real and integer in an expression. It's the most common error right now. Dash also supports recursion (which kind of comes with supporting procedure calling and a stack).

Here's two different versions of Fibonnaci:

<form>
    <textarea id="input3" style="display:block; width:100%;" rows="18" style="resize:none">
def fib_lin : (n : integer) -> (integer)
{
	let x = 2;
	let fib_x_minus2, fib_x_minus1 = 1, 1;

	while (x <= n)
	{
		let temp = fib_x_minus1;
		fib_x_minus1 = fib_x_minus1 + fib_x_minus2;
		fib_x_minus2 = temp;

		x = x + 1;
	}

	return fib_x_minus1;
}

def fib_rec : (n : integer) -> (integer)
{
	if (n <= 2)
		return 1;
	else
		return fib_rec(n - 1) + fib_rec(n - 2);
}

def main : () -> (integer)
{
	let i = 1;

	while (i <= 16)
	{
		print_i(fib_lin(i));

		i = i + 1;
	}

	return 0;
}
	</textarea>
    <div class="form-group">
        <div class="btn-group" role="group">
            <button type="button" class="btn btn-default" onclick="compile(document.getElementById('input3'), document.getElementById('output3'), document.getElementById('outputFrame3'))">Execute</button>
            <button type="button" class="btn btn-default" onclick="disassemble(document.getElementById('input3'), document.getElementById('output3'), document.getElementById('outputFrame3'))">Disassemble</button>
        </div>
    </div>
    <div style="display:none" id="outputFrame3">
        <label for="output">Output:</label>
        <div class="well">
            <p id="output3"></p>
        </div>
    </div>
</form>

Mentioned earlier, Dash has a limited library of external procedures written in C. Currently there is just printing procedures, Sin, Cos, Tan, and Pow.

Here's a quick example of using an external procedure: 

<form>
    <textarea id="input4" style="display:block; width:100%;" rows="18" style="resize:none">
def main : () -> (integer)
{
	let tau = 6.283185307179586476925286766559;
	let delta = 0.09817477042468103870195760572748;
	let n = 0.;

	while (n <= tau)
	{
		print_r(sin(n));

		n = n + delta;
	}

	return 0;
}
	</textarea>
    <div class="form-group">
        <div class="btn-group" role="group">
            <button type="button" class="btn btn-default" onclick="compile(document.getElementById('input4'), document.getElementById('output4'), document.getElementById('outputFrame4'))">Execute</button>
            <button type="button" class="btn btn-default" onclick="disassemble(document.getElementById('input4'), document.getElementById('output4'), document.getElementById('outputFrame4'))">Disassemble</button>
        </div>
    </div>
    <div style="display:none" id="outputFrame4">
        <label for="output">Output:</label>
        <div class="well">
            <p id="output4"></p>
        </div>
    </div>
</form>

The feature closest to my heart in Dash is multiple return types. Procedures can return multiple values, and can be used to initialize multiple variables, specify multiple parameters to a procedure, or return multiple values from the current procedure. It's pretty neat!

Here's an example of some of its uses:

<form>
    <textarea id="input5" style="display:block; width:100%;" rows="18" style="resize:none">
    def f : (x : real) -> (real, real)
	return x / 2., x / 2.;

def g : (x : real, y : real) -> (real)
	return x + y;

def main : () -> (integer)
{
	let a, b = f(2.);
	print_r(a);
	print_r(b);

	print_r(g(f(10.)));

	return 0;
}
	</textarea>
    <div class="form-group">
        <div class="btn-group" role="group">
            <button type="button" class="btn btn-default" onclick="compile(document.getElementById('input5'), document.getElementById('output5'), document.getElementById('outputFrame5'))">Execute</button>
            <button type="button" class="btn btn-default" onclick="disassemble(document.getElementById('input5'), document.getElementById('output5'), document.getElementById('outputFrame5'))">Disassemble</button>
        </div>
    </div>
    <div style="display:none" id="outputFrame5">
        <label for="output">Output:</label>
        <div class="well">
            <p id="output5"></p>
        </div>
    </div>
</form>

## Behind the Scenes - The Library
The Dash core library is written in C and is divided into two parts. A VM that executes procedures of bytecode, and a compiler that generates those procedures.

The VM is a register based machine that executes procedures of contiguous bytecode. A register is just a machine word sized slot for any kind of data. A procedure takes in a certain amount of registers as input, uses a certain amount of registers for calculations, then returns a certain sized range of registers as output. Instructions operate on registers using an index encoded in the instruction, and currently only operations on signed integers and floating point numbers are supported. A full list of instructions can be found [here](https://github.com/eqrion/dash/blob/master/dash/src/vm_internal.h).

Some important instructions are listed below:

| opcode | description |
| ------------------| --- |
|dvm_opcode_addf	|	adds two floating point numbers |
|dvm_opcode_jmp_c	|	jmp by an offset if the value in a register is nonzero |
|dvm_opcode_cmpi_e	|	compares two integers for equality and stores the result in a register |
|dvm_opcode_call	|	calls a procedure, specifying an input range, and an output range |
|dvm_opcode_ret		|	finishes the current procedure, and returns a specified register range |
|dvm_opcode_stor	|	stores the machine word after this instruction in a specified register. This is the only double length instruction in the set |

The VM was relatively straightforward to write, and once it was written I could actually hand assemble instructions and write simple procedures like Fibonacci or exponentiation. The compiler on the other hand was not so simple.

The compiler is divided into two parts. The front-end that parses Dash source into an AST, and the back-end that generates bytecode from an AST.

The front-end was mostly written with off the shelf tools. The Dash language was designed to be context-free, so I could use parser generators instead of writing it all by hand. Lexical analysis is done with flex, and parsing is done with yacc. Input comes in as characters and is tokenized by flex into some simple tokens. Yacc then reduces these tokens, and builds an AST. Once the source is accepted and we have an AST, we move to the back-end to generate bytecode.

The back-end was the most difficult part of the project. There is an incredible amount of work you can put into a good code generator. In fact, there's a lot of work needed to just make a passable code generator. Which is where I aimed to hit. The codegen process for Dash is essentially just a big tree traversal. I'm not going into the details today, but if there's interest I'll write a post about it.

The bytecode generated by the back-end is of decent quality. The codegen process is single pass, so there is no dead code elimination or expression simplification. The code you write is very close to the code that will be executed by the VM. Most of the optimization is done around register allocation.

Once the codegen process is completed, the bytecode is loaded into the VM and is available to be executed at any time in the future.

Try and write some expressions and check out the disassembly:

<form>
    <textarea id="input6" style="display:block; width:100%;" rows="19" style="resize:none">
def a : () -> ()
{
	let i = 0;
	while (i < 10)
	{
		i = i + 1;
	}
	return;
}

def b : () -> ()
{
	let true, false = 1, 0;

	if (true and not false)
	{
		return;
	}

	if (false or true)
	{
		return;
	}

	return;
}

def c : () -> ()
{
	let x = 1 + 2 + 3 + 4 + 5 + 6;
	return;
}

def main : () -> (integer)
{
	a();
	b();
	c();
	return 0;
}
	</textarea>
    <div class="form-group">
        <div class="btn-group" role="group">
            <button type="button" class="btn btn-default" onclick="compile(document.getElementById('input6'), document.getElementById('output6'), document.getElementById('outputFrame6'))">Execute</button>
            <button type="button" class="btn btn-default" onclick="disassemble(document.getElementById('input6'), document.getElementById('output6'), document.getElementById('outputFrame6'))">Disassemble</button>
        </div>
    </div>
    <div style="display:none" id="outputFrame6">
        <label for="output">Output:</label>
        <div class="well">
            <p id="output6"></p>
        </div>
    </div>
</form>

## Conclusion

Overall I'm very happy with the project. It's not exactly groundbreaking, but it's just cool to be able to understand the whole process. I don't have any plans to add new features in the immediate future, but that doesn't mean you can't! Feel free to experiment with my code, and create something new.

Questions, comments, found a bug? Leave a comment below!

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
<script  type="text/javascript">
       $(window).load(function () {
       $(document).delegate('.dash-sandbox', 'keydown', function (e) {
            var keyCode = e.keyCode || e.which;

            if (keyCode == 9) {
                e.preventDefault();
                var start = $(this).get(0).selectionStart;
                var end = $(this).get(0).selectionEnd;

                // set textarea value to: text before caret + tab + text after caret
                $(this).val($(this).val().substring(0, start)
                            + "\t"
                            + $(this).val().substring(end));

                // put caret at right position again
                $(this).get(0).selectionStart =
                $(this).get(0).selectionEnd = start + 1;
            }
        });
        });
        
        function compile(input, output, outputFrame) {
            var posting = $.post(
                'http://dashcompiler.azurewebsites.net/api/execute/',
                $(input).val(),
                function (data, textStatus, xhr) {
                    $(output).html(data);
                    $(outputFrame).show();
            }, '');
            posting.fail(function () {
                    $(output).html('Couldn\'t connect to the remote compiler.');
                    $(outputFrame).show();
            });
        }
        function disassemble(input, output, outputFrame) {
            var posting = $.post(
                'http://dashcompiler.azurewebsites.net/api/disassemble/',
                $(input).val(),
                function (data, textStatus, xhr) {
                    $(output).html(data);
                    $(outputFrame).show();
            }, '');
            posting.fail(function () {
                    $(output).html('Couldn\'t connect to the remote compiler.');
                    $(outputFrame).show();
            });
        }
    </script>
