# Password Checker API

Rails API for password strength checking (zxcvbn), breach lookup (Have I Been Pwned), and random password generation.

## Requirements

- Ruby 3.x
- Bundler

## Setup

```bash
bundle install
bin/rails db:prepare
```

## Configuration

Optional environment variables (with defaults):

| Variable        | Default | Description                          |
|----------------|---------|--------------------------------------|
| `PASSWORD_TTL` | 3600    | Cache TTL in seconds for check results |
| `PWNED_TTL`    | 3600    | Cache TTL in seconds for Pwned API responses |

Set these in your environment or in `public/.env` for local runs. Do not commit secrets.

## Running

```bash
bin/rails server
```

Health check: `GET /up`

## API

Base URL is where the server is running (e.g. `http://localhost:3000`).

### Check password strength

`POST /password/check`

Body (JSON):

```json
{ "password": "your-password-here" }
```

Response: strength score (0–4), crack time estimates, and zxcvbn feedback (warning, suggestions).

### Check if password appears in breaches

`POST /password/haveibeenpwned`

Body (JSON):

```json
{ "password": "your-password-here" }
```

Uses the [Have I Been Pwned Passwords](https://haveibeenpwned.com/Passwords) API (k-anonymity; only a hash prefix is sent).

Response: `pwned` (boolean) and `count` (number of breaches the password was found in).

### Generate a random password

`GET /password/generate?length=16`

Query: `length` (optional, default 16).

Response: generated password plus the same strength/feedback structure as the check endpoint.

## Rate limiting

The password endpoints are rate limited (e.g. 10 requests per minute). Exceeding the limit returns `429 Too Many Requests`.

## Tests

```bash
bundle exec rails test
```

## License

See repository.
