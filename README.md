# GenAI generated  code quality compare 

## Purpose: compare quality of  structured, reusable prompts,
 * try code generation for multiple LLMs to understand differences and
   if/where there is a value sweet-spot. 
 * understand reusable common snippets
 *  [View _common_prompt_snippet.txt](prompts/_common_prompt_snippet.txt)
 
 The prompts and generated python files are very simple, open source.
 They are all functional style - simple parts of a data analytics, pandas-based pipeline
 
 
 ##  ./bin/pyquality.sh -  wrapper to run a few python code quality checks. 
	 
	 Metrics: 
	 * lines - total lines including comments (wc)
     * pylint - pylint score 
     * flake 8: 
     * radon_cc: Radon code complexity
     * radon_mi: Radon code maintainability
     * bandit_out: Bandit
     * MyPy: Mypy summary
	 
 ### run
Start from root directory

```bash
~/bin/pyquality.sh  ./generated/copilot/*.py
	 
	 
	 



## Manual Process
1. Manual - I copy each prompt into a LLM chat window and then copy-paste the generated files into a local py file. 
2. See ./prompts/_common_prompt_snippet.txt

## Running

### create and activate venv if needed
1. python3 -m venv .venv
2. source .venv/bin/activate
   or .venv\Scripts\Activate.ps1
3. pip install -r requirements.txt



## Futures - improvements

1. Write script to make sure every prompt has the latest common prompt snippet.
    * Maybe by combining at generation time or by modifying each prompt file (boo) 
2. Generate source files from command line
3. Try harder code. 
4. Consider a few loops - generate code - then ask LLM to evaluate and improve code. 
