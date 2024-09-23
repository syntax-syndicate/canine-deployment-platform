TODO:

- Building a cron job scheduler
- Aggregate ENV variables for add on urls

## Requirements

You'll need the following installed to run the template successfully:

- Ruby 3.2+
- Node.js v20+
- PostgreSQL 12+
- Redis - For ActionCable support (and Sidekiq, caching, etc)
- Libvips or Imagemagick - `brew install vips imagemagick`
- [Overmind](https://github.com/DarthSim/overmind) or Foreman - `brew install tmux overmind` or `gem install foreman` - helps run all your processes in development
- [Stripe CLI](https://stripe.com/docs/stripe-cli) for Stripe webhooks in development - `brew install stripe/stripe-cli/stripe`

If you use Homebrew, dependencies are listed in `Brewfile` so you can install them using:

```bash
brew bundle install --no-upgrade
```

Then you can start the database servers:

```bash
brew services start postgresql
brew services start redis
```

## Initial Setup

First, edit `config/database.yml` and change the database credentials for your server.

Run `bin/setup` to install Ruby and JavaScript dependencies and setup your database.

```bash
bin/setup
```

### Setup Github Omniauth for local development

[Create an Omniauth Github app](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/creating-an-oauth-app)

Make sure the authorization callback is with this path: `/users/auth/github/callback`

Fill out your `.env` file

```bash
APP_HOST=canine.example.com
OMNIAUTH_GITHUB_WEBHOOK_SECRET=1234567890
OMNIAUTH_GITHUB_PUBLIC_KEY=1234567890
OMNIAUTH_GITHUB_PRIVATE_KEY=1234567890
```

## Running Jumpstart Pro Rails

To run your application, you'll use the `bin/dev` command:

```bash
bin/dev
```

#### Running on Windows

See the [Installation docs](https://jumpstartrails.com/docs/installation#windows)

#### Running with Docker or Docker Compose

See the [Installation docs](https://jumpstartrails.com/docs/installation#docker)

## Merging Updates

To merge changes from Jumpstart Pro, you will merge from the `jumpstart-pro` remote.

```bash
git fetch jumpstart-pro
git merge jumpstart-pro/main
```
