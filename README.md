sprintly-cli
============

## Prerequisites

Currently you need to have Ruby installed on your system, along with bundler.

## Installation

To install, simply checkout this project in github:

    git clone git://github.com/atharrison/sprintly-cli.git

then call

    bundle install

## Running sprintly-cli

To run, call:

    bundle exec ./sprintly-cli <command>


Available Commands:

    sprintly-cli add_comment     # Add comment to item
    sprintly-cli assign_item     # Assign user to item
    sprintly-cli complete        # Complete a given item
    sprintly-cli config          # Configure sprintly-cli
    sprintly-cli create          # Create an item under the current Product
    sprintly-cli help [COMMAND]  # Describe available commands or one specific command
    sprintly-cli list            # List items
    sprintly-cli list_comments   # List comments for item
    sprintly-cli list_users      # List users
    sprintly-cli products        # List products
    sprintly-cli score           # Score (size) a given item
    sprintly-cli start           # Start a given item
    sprintly-cli tag             # Tag a given item


### Credits

Special consideration should be given to Ian MacLeod, who wrote a Ruby Sprint.ly API, so I didn't have to.

    https://github.com/nevir/sprintly-rb

### Copyright

(c) 2013 Return Path
