# Loco

[![Build Status](https://travis-ci.org/khwon/loco.svg?branch=master)](https://travis-ci.org/khwon/loco)
[![Code Climate](https://codeclimate.com/github/khwon/loco.png)](https://codeclimate.com/github/khwon/loco)
[![Inline docs](http://inch-ci.org/github/khwon/loco.png?branch=master)](http://inch-ci.org/github/khwon/loco)
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/khwon/loco?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

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
* PostgreSQL
    * Ubuntu
        ``` sh
        sudo apt-get install libpq-dev
        ```

    * Mac OS X
        ``` sh
        brew install postgresql
        ARCHFLAGS="-arch x86_64" gem install pg # optional
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
./bin/term
```

## Test

Run every tests with `rake`. Also `rake spec` and `rake rubocop` are available, which are same with `rspec`, `rubocop` respectively.

### RuboCop

All available configurations of RuboCop can be found in [default.yml](https://github.com/bbatsov/rubocop/blob/master/config/default.yml).

Run `rubocop` for checking, `rubocop --auto-gen-config` to regenerate `.rubocop_todo.yml`, `rubocop -R/--rails` to run Rails cop.
