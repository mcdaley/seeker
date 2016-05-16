# Seeker

## Description

The Seeker gem provides a standard interface for interacting with job search sites. The
user can instantiate an instance of a job search site and then run a simple search
with a description, location or the user can run advanced job search and specify radius 
to search, number of days posted, and boolean search logic to use for matching the 
description. The gem currently supports running Dice jobs

## Usage

Create instances of job search site

```ruby
dice = Seeker::Dice.new
```

### Run simple search query for each site
To run a simple search, just call search with a description and location.

```ruby
response = dice.search("Description", "Location")
```

### Run advanced search
To better narrow the job search results run an advanced search, where the
user can specify:

|Parameter    |Description|
|:------------|:----------|
|description  |Job, title, skills, or company|
|boolean_opr  |Match __all__ words, __any__ words, or __exact phrase__ in description|
|location     |City, state, or zip code|
|radius       |Distance from location in miles to include in search results|
|fromage      |Include jobs posted within fromage days|
|job_type     |Select job type (i.e., fulltime, parttime,contract, internship, temporary)

For example, to search for jobs that are within 5 miles of "94105" and posted less than
7 days ago:

```ruby
params    = { description: "JavaScript", location: "94105", radius: "5", fromage: "7"}
response  = dice.advanced_search(params)
```

### Search results
The search and advanced_search methods return a standard response message that contains
the status of the job search and the jobs, if the result was ok. The message is a standard
ruby hash with a header and a body.

The format of the hash is:

```ruby
message = {
  header: {
    http:           { code:, msg: },
    error:          { code:, msg: },
    total_results:,
    description:,
    location:
  },
  body: {
    jobs: []
  }
}
```

The search was successful if the error[:code] = 0 and the http[:code] = 200

### Example
Run a simple search, validate the response, and retrieve the jobs

```ruby
dice      = Seeker::Dice.new
response  = dice.search("JavaScript", "San Francisco, CA")
msg       = response.msg
header    = msg[:header]
jobs      = msg[:body][:jobs]

puts "First job is #{jobs[0][:title]}, at #{jobs[0].company}"
```

## To Do


## Contributing

1. Fork it ( https://github.com/[my-github-username]/seeker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
