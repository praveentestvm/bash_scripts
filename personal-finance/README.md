# Personal Finance Web Application

PHP 8.2/8.3 + Apache + MySQL application for personal income, expense, budget and savings tracking.

## Features

- Email-or-username login and registration
- Password reset with a 6-digit email verification code
- CSRF protection and secure sessions
- Super Admin / Standard User RBAC
- Dynamic income and expense categories
- Transaction CRUD with ownership enforcement
- Month/year filtering and description/category/payment search
- CSV and XLSX exports
- Monthly income, expense and net-balance dashboard
- Expense category chart and top-3 spending categories
- Monthly budget progress
- Savings goal tracking
- Responsive green-themed UI
- First-run installation wizard
- Apache-safe root and subdirectory URL handling

## Requirements

- Apache 2.4+
- PHP 8.2 or 8.3
- MySQL 8.0+ or compatible MySQL/MariaDB
- PHP extensions: `pdo_mysql`, `mbstring`, `xml`, `dom`, `simplexml`, `zip`, `gd`, `curl`, `openssl`, `json`, `session`, `fileinfo`
- Composer 2+

## Local / AWS installation

1. Clone the repository.
2. Run `composer install --no-dev --optimize-autoloader`.
3. Point Apache's `DocumentRoot` at the project directory (recommended), or install it in a subdirectory.
4. Ensure Apache can write `config.php` during the first installation only.
5. Open the application URL. If `config.php` does not exist, the installer opens automatically.
6. Enter the MySQL database and Super Admin details.
7. Configure SMTP with `smtp.gmail.com`, port `587`, TLS and a Google App Password if Gmail is used.
8. The installer creates the database/schema, default roles/categories and the first Super Admin.
9. After installation, make `config.php` read-only if your deployment process permits it.

### Recommended AWS layout

For a straightforward production deployment:

- EC2 Ubuntu
- Apache + PHP 8.3
- RDS MySQL
- HTTPS via a domain and certificate
- Gmail SMTP or another transactional SMTP provider

Do not expose RDS/MySQL port 3306 to the public internet. Allow it only from the EC2 security group.

## Apache root deployment

If Apache uses:

`DocumentRoot /var/www/html/personal-finance`

then the application URL is:

`https://your-domain.example/`

The installer will set `app.base_url` to an empty string.

For a subdirectory deployment such as `/personal-finance`, the installer detects and stores `/personal-finance` as the base URL.

## SMTP

For Gmail:

- Host: `smtp.gmail.com`
- Port: `587`
- Encryption: TLS / STARTTLS
- Username: full Gmail address
- Password: Google App Password

SMTP diagnostics are disabled in the production mailer. Failures are logged server-side and shown to users as a friendly error.

## Security notes

- `config.php` is ignored by Git and blocked by Apache.
- `database/` and `includes/` are blocked from direct web access.
- Never commit SMTP passwords, database passwords or other secrets.
- Use HTTPS in production.
- Keep `vendor/` out of Git and run Composer during deployment.
