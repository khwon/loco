# Loco

[![Code Climate](https://codeclimate.com/github/khwon/loco.png)](https://codeclimate.com/github/khwon/loco)
[![Inline docs](http://inch-ci.org/github/khwon/loco.png?branch=develop)](http://inch-ci.org/github/khwon/loco)

LOCO BBS system for KAIST

## Requirements

* Ruby >= 2.1.0
* Ncurses
    * Ubuntu
        ``` sh
        sudo apt-get install libncursesw5-dev
        ```

    * Mac OS X

        Install [Homebrew](http://brew.sh/).
        ``` sh
        brew install homebrew/dupes/ncurses
        brew doctor
        brew link --force ncurses
        ```
* For required gems, see [Gemfile](/Gemfile)

## How to run

### Pour sample data

``` sh
rake termapp:generate_data
```
login credentials: a/a for admin, b/b, c/c, d/d for user

### Run

``` sh
ruby termapp/run.rb
```

## RuboCop

All available configurations of RuboCop can be found in [default.yml](https://github.com/bbatsov/rubocop/blob/master/config/default.yml).

Run `rubocop` for checking, `rubocop --auto-gen-config` to regenerate `.rubocop_todo.yml`, `rubocop -R/--rails` to run Rails cop.
