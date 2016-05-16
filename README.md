# Seeker

The Seeker gem provides a standard interface for interacting with job search sites. The
user can instantiate an instance of a job search site and then run a simple search
with a description, location, page number, and number of jobs per page.

The API returns a standard ruby hash that contains the same fields for each job site
and it also handles all of the error conditions. The current supported job sites are

1. Indeed.com
2. CareerBuilder.com

## Installation

You will need to install the gem from the github source code, since it is not
deployed to rubygems.org. To download the latest release you can use one of the 
two options below:

1. Install from the master branch

```ruby
gem 'seeker', git: 'git://github.com/mcdaley/budman', branch: 'master'
```

You can also specify a specific release by adding the version

```ruby
gem 'seeker', '0.0.[1-99]', git: 'git://github.com/mcdaley/budman', branch: 'master'
```

2. Install from a commit reference point. You can determine the latest commit
reference number by running the glog command which is an alias for git log defined 
below:

```ruby
alias glog='git log --pretty=format:"%h - %an, %ar : %s"'
```

To install a specific reference of the gem, use the first column of the output 
from the glog command, which is the github reference. This method is the most
flexible when working with a gem that is changing very frequently. When specifying 
a branch, release number, or tag then bundler will not update the gem until the 
version or the tag has been updated.

```ruby
gem 'seeker',     git: 'git://github.com/mcdaley/budman', ref: 'b12e16f'
```

3. Install from a tag, which is not specified here - look at bundler documentation

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install seeker

## Usage

1. Get list of supported job search sites (Not Implemented)
```ruby
sites = Seeker.sites
```

2. Create instances of job search site
```ruby
indeed = Seeker::Indeed.new
```

3. Run search query for each site
```ruby
response = indeed.search("Description", "Location")
```

4. Get response as a ruby hash 
```ruby
message  = response.message if response.ok?
```

The format of the hash is

message = {
  header: {
    http:           { code:, msg: },
    error:          { code:, msg: },
    total_results:,
    description:,
    location:_
  },
  body: {
    jobs: []
  }
}

The search was successful if the error[:code] = 0 and the http[:code] = 200


## To Do
1. Add PRIVATE respository to github

2. Plug into dogpatch

3. Make gem configurable through railties and some sort of configuration. Need
   to look at the Twilio gem because of the article that discussed using 
   environment variables. I can probably use one of the gems discussed in the
   article.

4. Add logging that can integrate with rails logging

5. Try to get rid of the DB table for managing job search sites

6. Check to see where i normalize the page, offset, and per_page

## Contributing

1. Fork it ( https://github.com/[my-github-username]/seeker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
