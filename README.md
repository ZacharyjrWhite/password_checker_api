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

## Caching

The app uses `Rails.cache` for two things:

- **Password strength results** — Key `password_verify/<sha256(password)>`. Cached after each check or generate so repeated requests for the same password reuse the zxcvbn result. TTL: `PASSWORD_TTL` seconds.
- **Pwned API responses** — Key `pwned/<5-char-sha1-prefix>`. The Have I Been Pwned API returns a range of suffixes for a given prefix; that response is cached so multiple passwords sharing the same prefix hit the API once. TTL: `PWNED_TTL` seconds.

Cache store by environment:

- **Development:** `memory_store` (in-process, cleared on restart).
- **Production:** `solid_cache_store` (database-backed via Solid Cache; see `config/cache.yml` and the `cache` DB in `config/database.yml`).

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
