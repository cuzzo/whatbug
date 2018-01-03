# WhatBug

Find out which specific line of code introduced a bug -- fast and accurately.

WhatBug pulls a stacktrace from Rollbar, AirBrake, or Sentry. It gets all the lines of code in the relevant functions in the stack trace. Then, it finds out which of those lines has changed within a timeframe.

## Usage

```bash
whatbug <error_id> <cutoff_time>
```

`cutoff_time` specifies the time at which a line should be marked as changed.

For example, if a line was changed at `2017-12-27` and the `cutoff_time` is `2018-01-02`, that line will not be marked as changed. If the `cutoff_time` is `2017-12-26` the line will be marked as changed.

The `error_id` comes from the URL in your error tracking service.

### Rollbar
For Rollbar, error URLs look like: `https://rollbar.com/cuzzo/whatbug/items/42/`.
`42` is the `error_id`.

WhatBug needs a read only access key to hit the Rollbar API to retreive a stacktrace. You can either set that value in a .env file:

```
ROLLBAR_API_KEY=<my_rollbar_api_key>
```

Or you can preface the command with it:

```
ROLLBAR_API_KEY=<my_rollbar_api_key> whatbug 42 2018-01-02
```

### AirBrake
For AirBrake, error URLs look like: `https://airbrake.io/projects/<project_id>/groups/42`
`42` is the `error_id`.

WhatBug needs a read only access key to hit the Rollbar API to retreive a stacktrace. It also needs to know the project ID. You can either set these value in a .env file:

```
AIRBRAKE_API_KEY=<my_airbrake_api_key>
AIRBRAKE_PROJECT_ID=<my_airbrake_project_id>
```

Or you can preface the command with them:

```
AIRBRAKE_API_KEY=<my_airbrake_api_key> AIRBRAKE_PROJECT_ID=<my_airbrake_project_id> whatbug 42 2018-01-02
```

## Installation

`gem install whatbug`

## Output

The standard binary outputs text to STDOUT. The formatting is such that if you redirect it to a `.diff` file, editors will nicely color code it for you.

```
whatbug 41 2018-01-02 > bug.diff
```

The output can easily be modified to show -- for example -- the last author to touch each line, the time at which it was modified, or the commit it was modified at.

`render` in `bin/whatbug` turns the functions into an array of strings. It iterates over each function in the trace. Then it iterates over each line in the functions.

The functions are hashes with these keys:
* `name` - The name of the function
* `start` - The line at which the funcion starts
* `end` - The line at which the function ends

The individual lines of code are also hashes -- with these keys:
* `text` - The actual line of code
* `line_num` - The line number
* `changed` - Boolean -> Whether or not the line has changed since the cutoff
* `in_trace` - Boolean -> Whether or not the line is in the stack trace
* `blame` - Hash with keys for the `commit`, `author`, and `date`.

If you'd like a full function context, knowning the entire revision history of each line, which lines of code in the trace have occurred in other stack traces, which lines are historically buggy in JIRA or other issue trackers, and also knowing which lines are authored by statisically error-prone developers -- [GigaDiff](https://gigadiff.com/) can tell you that.

Requests for any GigaDiff features will be taken into consideration.

Pull requests are welcome [=

## License

WhatBug is free--as in BSD. Hack your heart out, hackers.
