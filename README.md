# Mutiny [![Build Status](https://travis-ci.org/louismrose/mutiny.png?branch=master)](https://travis-ci.org/louismrose/mutiny) [![Code Climate](https://codeclimate.com/github/louismrose/mutiny.png)](https://codeclimate.com/github/louismrose/mutiny) [![Dependency Status](https://gemnasium.com/louismrose/mutiny.png)](https://gemnasium.com/louismrose/mutiny) [![Coverage Status](https://coveralls.io/repos/louismrose/mutiny/badge.png?branch=master)](https://coveralls.io/r/louismrose/mutiny?branch=master)

A tiny mutation testing framework.

#### Usage
* `git clone` this repo
* `bundle install`
* `./bin/mutiny ./examples/max.rb ./examples/max_tests.rb` Note that we currently assume that tests.rb is a line-separated set of predicates (expressions that evaluate to either true or false).

#### To do list
* Consume a "diff", compute new results for impacted files, and merge into previous round of results

    * Need a way of determining impacted files. The following should be a reasonable starting point:

            g = Git.open(dir)
            head, previous = g.log[0], g.log[1]
            g.diff(head, previous).map(&:path)

    * Need a way of persisting results to disk. Schema:

            Mutants
            id | source_file | line | operator       | operator_state
            00 | lib/calc.rb |      |                |
            01 | lib/calc.rb | 4    | BinaryOperator | >             
            
            Examples
            id | spec_file   | name
            12 | lib/calc.rb | adds
            
            Results
            mutant | example | result
            00     | 12      | passed
            01     | 12      | failed

* Extend framework to explore Program Analyser and more sophisticated Test Case Provider components (see OmniGraffle diagram)
