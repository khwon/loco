# Loco

LOCO bbs system for KAIST

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

```
ruby termapp/run.rb
```

Use admin//a for login


## RuboCop

All available configurations of RuboCop can be found in [default.yml](https://github.com/bbatsov/rubocop/blob/master/config/default.yml).

Run `rubocop` for checking, `rubocop --auto-gen-config` to regenerate `.rubocop_todo.yml`.
