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
~/bin/pyquality.sh  "./generated/copilot/*.py"


# Results



## Copilot

| File Name                                        |lines |py lines| Pylint | Flake8   | radon_cc| radon_mi| bandit_out| MyPy  |
|-------------------------------------------------|------|--------|--------|----------|---------|---------|---------|---------|
|./generated/copilot/calc_app_usage_metrics.py    |60    |      35| 6.52   |        4 | 11.0    | A       | 0       | broken  |
|./generated/copilot/calc_usage_metrics.py        |83    |      56| 7.17   |       12 | 6.0     | A       | 0       | broken  |
|./generated/copilot/combine_usage_files.py       |74    |      51| 6.92   |        7 | 12.0    | A       | 0       | broken  |
|./generated/copilot/count_app_users.py           |43    |      29| 6.25   |        4 | 6.0     | A       | 0       | broken  |
|./generated/copilot/csv_str_parse.py             |37    |      24| 9.38   |        1 | 9.0     | A       | 0       | broken  |
|./generated/copilot/gen_readme.py                |55    |      39| 7.14   |        1 | 8.0     | A       | 0       | broken  |
|./generated/copilot/write_period_excel.py        |77    |      58| 6.40   |        5 | 7.0     | A       | 0       | broken  |

## Grok 

| File Name                                        |lines |py lines| Pylint | Flake8   | radon_cc| radon_mi| bandit_out| MyPy  |
|-------------------------------------------------|------|--------|--------|----------|---------|---------|---------|---------|
| ./generated/grok/calc_app_usage_metrics.py       |63    |      39| 4.80   |        7 | 11.0    | A       | 0       | broken  |
| ./generated/grok/calc_usage_metrics.py           |104   |      73| 6.35   |       15 | 8.0     | A       | 0       | broken  |
| ./generated/grok/combine_usage_files.py          |102   |      71| 6.15   |       17 | 13.0    | A       | 0       | broken  |
| ./generated/grok/count_app_users.py              |48    |      31| 3.33   |        4 | 6.0     | A       | 0       | broken  |
| ./generated/grok/csv_str_parse.py                |48    |      29| 10.00  |        1 | 10.0    | A       | 0       | broken  |
| ./generated/grok/gen_readme.py                   |46    |      27| 5.33   |        6 | 9.0     | A       | 0       | broken  |
| ./generated/grok/strip_quotes.py                 |37    |      21| 9.23   |        3 | 6.0     | A       | 0       | broken  |
| ./generated/grok/write_period_excel.py           |67    |      49| 5.19   |        5 | 9.0     | A       | 0       | broken |

notes:  
 * keep any file wildcards in quotes
 *mypy may complain to install stubs =, such as  python3 -m pip install pandas-stub
	 
	 
	 



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

1. Update to generate results in markdown format
2. Write script to make sure every prompt has the latest common prompt snippet.
    * Maybe by combining at generation time or by modifying each prompt file (boo) 
2. Generate source files from command line
3. Try harder code. 
4. Consider a few loops - generate code - then ask LLM to evaluate and improve code. 
