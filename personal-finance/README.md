# Personal Finance Web Application

A lightweight personal finance management web application built with **PHP 8.3**, **MySQL 8**, HTML/CSS/JavaScript, and PHPMailer.

The application is designed for a small self-hosted or AWS-hosted environment and provides user authentication, income/expense tracking, budgets, savings goals, category management, reporting, and password recovery by email.

---

## 1. Project Overview

The application provides a central place to manage personal financial records.

### Main capabilities

- User registration and login
- Login using email **or** username
- Secure password hashing
- CSRF protection
- Session-based authentication
- Forgot-password workflow with a 6-digit email verification code
- User profile management
- Role-based access control
- Super Admin category management
- Income and expense transaction management
- Monthly dashboard
- Monthly budget tracking
- Savings goal tracking
- Expense-category charts
- Top spending categories
- Transaction search and filtering
- CSV/XLSX export
- Responsive green-themed UI
- Floating quick-add transaction button
- First-time installation wizard
- Automatic database schema initialization

---

# 2. Technology Stack

| Component | Technology |
|---|---|
| Backend | PHP 8.3+ |
| Web Server | Apache 2.4+ |
| Database | MySQL 8.0+ / compatible MySQL |
| Database API | PDO MySQL |
| Dependency Manager | Composer 2.x |
| Email | PHPMailer 6.x |
| Frontend | HTML5, CSS3, JavaScript |
| Charts | Chart.js |
| Authentication | PHP Sessions + password_hash/password_verify |
| Export | CSV + PhpSpreadsheet/XLSX |
| Recommended OS | Ubuntu 22.04/24.04 LTS |

---

# 3. Server Requirements

## Minimum

- Linux server
- Apache 2.4+
- PHP 8.3+
- MySQL 8.0+
- Composer 2.x
- OpenSSL
- Git
- PHP PDO MySQL extension

## Recommended PHP extensions

Install the following:

```bash
sudo apt update

sudo apt install -y \
    apache2 \
    mysql-client \
    php8.3 \
    php8.3-cli \
    php8.3-common \
    php8.3-mysql \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-curl \
    php8.3-zip \
    php8.3-gd \
    php8.3-intl \
    unzip \
    git \
    curl \
    openssl
```

Check PHP:

```bash
php -v
```

Expected:

```text
PHP 8.3.x
```

Check PDO MySQL:

```bash
php -r 'print_r(PDO::getAvailableDrivers());'
```

You should see:

```text
Array
(
    [0] => mysql
)
```

Check important extensions:

```bash
php -m | grep -Ei 'pdo|mysql|mbstring|xml|curl|zip|gd|openssl'
```

---

# 4. Composer

Composer is required to install PHP dependencies.

Check whether it is already installed:

```bash
composer --version
```

If it is not installed, install Composer using the official Composer installation instructions.

After cloning the project:

```bash
cd /var/www/personal-finance
composer install --no-dev --optimize-autoloader
```

This creates the `vendor/` directory.

**Do not commit `vendor/` to Git.**

---

# 5. Project Structure

```text
personal-finance/
│
├── admin/
│   └── categories.php
│
├── api/
│   └── ...
│
├── assets/
│   ├── css/
│   │   └── app.css
│   └── js/
│       ├── app.js
│       ├── dashboard.js
│       └── transactions.js
│
├── database/
│   └── ...
│
├── deploy/
│   └── apache-vhost.conf
│
├── docs/
│   └── ...
│
├── export/
│   └── ...
│
├── includes/
│   ├── auth.php
│   ├── bootstrap.php
│   ├── csrf.php
│   ├── db.php
│   ├── footer.php
│   ├── functions.php
│   ├── header.php
│   └── mailer.php
│
├── add_transaction.php
├── budget.php
├── dashboard.php
├── delete_transaction.php
├── edit_transaction.php
├── forgot_password.php
├── goals.php
├── index.php
├── login.php
├── logout.php
├── profile.php
├── register.php
├── reset_password.php
├── setup.php
├── setup_db.php
├── verify_code.php
├── view_transactions.php
│
├── composer.json
├── composer.lock
├── default-config.php
├── .env.example
└── .gitignore
```

---

# 6. Clone the Project

Example:

```bash
cd /var/www

git clone YOUR_GITHUB_REPOSITORY_URL personal-finance

cd personal-finance
```

Then install dependencies:

```bash
composer install --no-dev --optimize-autoloader
```

---

# 7. Configuration

The project intentionally does **not** include the production `config.php`.

This is important because `config.php` can contain:

- Database password
- SMTP password/App Password
- Application secrets
- Environment-specific configuration

The first-time setup wizard creates the live configuration.

---

# 8. First-Time Installation

Make sure Apache can write the application configuration during initial installation.

The application checks whether:

```text
config.php
```

exists.

If it does not exist, the application redirects to:

```text
/setup.php
```

The setup wizard asks for:

### Database

```text
DB Host
DB Name
DB User
DB Password
```

### Super Admin

```text
Username
Email
Password
```

### Mail

```text
SMTP Host
SMTP Port
SMTP Username
SMTP Password
Encryption
From Email
From Name
```

The setup process creates:

```text
config.php
```

and initializes the database.

---

# 9. Gmail SMTP Configuration

For Gmail SMTP use:

```text
Host: smtp.gmail.com
Port: 587
Encryption: TLS / STARTTLS
Username: your Gmail address
Password: Google App Password
```

Do **not** use your normal Gmail account password.

Use a Google **App Password** when SMTP authentication requires it.

Example:

```text
SMTP Host: smtp.gmail.com
SMTP Port: 587
SMTP Username: example@gmail.com
SMTP Password: ********
Encryption: tls
```

The password-reset system uses this SMTP configuration to send 6-digit verification codes.

---

# 10. Database

The application uses a relational MySQL database.

Major entities include:

- Users
- Roles
- Categories
- Transactions
- Budgets
- Goals
- Password reset codes

The database uses foreign keys and indexes to maintain relational integrity and improve query performance.

The setup process initializes:

- Database tables
- Foreign keys
- Default roles
- Default categories
- Required indexes

---

# 11. User Roles

## Super Admin

The Super Admin can:

- Access the administration interface
- Add categories
- Edit categories
- Delete categories
- Manage application-level categories

## Standard User

A Standard User can:

- Manage their own transactions
- Manage their own budgets
- Manage their own savings goals
- Edit their profile
- Change their password
- View their own financial information

Users must not be able to access another user's financial records.

---

# 12. Dashboard

The dashboard is designed around the **current calendar month**.

It displays:

### Income

Total income for the selected month.

### Expenses

Total expenses for the selected month.

### Net Balance

```text
Net Balance = Total Income - Total Expense
```

### Expense Chart

Visualizes spending by category.

### Top 3 Spending Categories

Shows the three categories with the highest spending.

### Budget Progress

Displays spending against the monthly budget.

### Savings Goal

Displays progress toward the configured savings target.

---

# 13. Transactions

Transactions support:

```text
Income
Expense
```

Each transaction contains:

- Amount
- Type
- Category
- Payment method
- Description/notes
- Created date

Supported payment methods include:

```text
Cash
Debit Card
Credit Card
```

Users can:

- Add transactions
- View transactions
- Edit transactions
- Delete transactions
- Search transactions
- Filter by category
- Filter by payment method
- Filter by month/year
- Export filtered data

---

# 14. Transaction History

The dashboard defaults to the active calendar month.

The transaction view supports historical month/year filtering.

The application is designed around a rolling three-month transaction view/retention requirement while retaining records in the database so historical records are not accidentally destroyed simply because the dashboard moves to a new month.

**Important:** Database records should not be physically purged as part of normal dashboard/month navigation.

---

# 15. Password Reset

The password-reset workflow is:

```text
Forgot Password
       |
       v
Enter Email
       |
       v
Generate 6-digit code
       |
       v
Store hashed code + expiry
       |
       v
Send code through SMTP
       |
       v
Verify Code
       |
       v
Set New Password
       |
       v
Login
```

Reset codes have:

- Expiration timestamps
- Used status
- Hashed storage
- Attempt protection

The plaintext verification code should never be stored in the database.

---

# 16. Security

The project includes several security controls.

### Passwords

Passwords use PHP's password hashing APIs:

```php
password_hash()
password_verify()
```

### SQL Injection

Database operations use PDO prepared statements.

### CSRF

Forms use CSRF tokens.

### Sessions

Authenticated sessions use PHP session controls with HTTP-only and SameSite cookie settings.

### Authorization

User-owned records are protected using user ownership checks.

### Configuration

Production credentials should never be committed to Git.

### Error Handling

Production environments should not display PHP stack traces to users.

---

# 17. Apache Configuration

For a domain such as:

```text
https://finance.example.com
```

the Apache document root should point to:

```text
/var/www/personal-finance
```

Example:

```apache
<VirtualHost *:80>

    ServerName finance.example.com

    DocumentRoot /var/www/personal-finance

    <Directory /var/www/personal-finance>
        AllowOverride All
        Require all granted
        Options -Indexes
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/personal-finance-error.log
    CustomLog ${APACHE_LOG_DIR}/personal-finance-access.log combined

</VirtualHost>
```

Enable the site:

```bash
sudo a2ensite personal-finance.conf
sudo a2enmod rewrite
sudo systemctl reload apache2
```

---

# 18. HTTPS

For production, HTTPS is strongly recommended.

Typical setup:

```text
Internet
   |
 HTTPS :443
   |
 Apache
   |
 PHP
   |
 MySQL
```

You can use Let's Encrypt/Certbot or an AWS load balancer/reverse proxy depending on your AWS architecture.

Never send passwords or financial information over plain HTTP in production.

---

# 19. Recommended AWS Architecture

For a small personal finance application, a simple architecture is:

```text
                    Internet
                       |
                       v
                 AWS EC2
              Ubuntu Server
                       |
                  Apache 2.4
                       |
                   PHP 8.3
                       |
             Personal Finance App
                       |
                       v
                  AWS RDS
                   MySQL 8
```

SMTP:

```text
Application
     |
     v
smtp.gmail.com:587
     |
     v
Gmail
```

Recommended AWS components:

- EC2 for Apache/PHP
- RDS MySQL for the database
- Route 53 for DNS if using an AWS-managed domain
- HTTPS certificate
- Security Groups
- CloudWatch/log monitoring as needed

---

# 20. AWS Security Group

For a normal public web server:

```text
HTTP   80   Internet
HTTPS  443  Internet
SSH    22   Your IP only
```

Do **not** expose MySQL port `3306` to the public Internet.

For RDS, allow:

```text
EC2 Security Group → RDS port 3306
```

rather than:

```text
0.0.0.0/0 → 3306
```

---

# 21. Production PHP Settings

Recommended production settings:

```ini
display_errors = Off
log_errors = On
expose_php = Off
```

Check the active PHP configuration:

```bash
php --ini
```

Apache PHP configuration may be separate from CLI PHP configuration, so verify both environments when changing PHP settings.

---

# 22. GitHub Rules

Do not commit:

```text
config.php
.env
.env.*
vendor/
```

The repository should contain:

```text
.env.example
```

instead of real secrets.

Never commit:

```text
Gmail App Password
Database Password
AWS Access Key
AWS Secret Key
Production API Keys
```

If a secret is accidentally committed, rotate it immediately even if the repository is private.

---

# 23. Local Development

For local development:

```bash
git clone YOUR_REPOSITORY_URL
cd personal-finance

composer install
```

Configure a local MySQL database and run the application through Apache/PHP.

For the PHP built-in server, note that Apache-specific behavior such as `.htaccess` is not fully reproduced. Apache is therefore preferred for testing the production configuration.

---

# 24. Useful Validation Commands

### PHP syntax

Check one file:

```bash
php -l login.php
```

Check all PHP files:

```bash
find . -name "*.php" -not -path "./vendor/*" -print0 |
while IFS= read -r -d '' file; do
    php -l "$file" || exit 1
done
```

### Composer

```bash
composer validate
composer install --no-dev --optimize-autoloader
```

### PHP extensions

```bash
php -m
```

### Apache configuration

```bash
sudo apache2ctl configtest
```

Expected:

```text
Syntax OK
```

### Apache virtual hosts

```bash
sudo apache2ctl -S
```

---

# 25. Deployment Workflow

Recommended deployment process:

```text
Developer Laptop
      |
      v
Git
      |
      v
GitHub
      |
      v
AWS EC2
      |
      +--> composer install
      |
      +--> Apache
      |
      +--> PHP 8.3
      |
      v
AWS RDS MySQL
```

Basic deployment:

```bash
cd /var/www

git clone YOUR_REPOSITORY_URL personal-finance

cd personal-finance

composer install --no-dev --optimize-autoloader
```

Then configure Apache and open:

```text
https://YOUR-DOMAIN/
```

The first request should redirect to:

```text
/setup.php
```

if `config.php` has not yet been created.

---

# 26. Updating the Application

After a new GitHub release:

```bash
cd /var/www/personal-finance

git pull

composer install --no-dev --optimize-autoloader

sudo systemctl reload apache2
```

Before production updates:

1. Back up the database.
2. Back up configuration.
3. Pull the new code.
4. Run Composer.
5. Check PHP syntax.
6. Check Apache configuration.
7. Test login.
8. Test transaction creation.
9. Test dashboard.
10. Test password reset if mail-related code changed.

---

# 27. Backup Strategy

Because this application contains financial records, backups are important.

Recommended:

```text
Application code
    → GitHub

Database
    → Automated RDS backups

Configuration/secrets
    → Secure secret storage / protected backup

Uploaded files (if added later)
    → Separate backup
```

Never treat GitHub as a database backup.

---

# 28. Troubleshooting

### CSS not loading

Check:

```text
/assets/css/app.css
```

Then:

```bash
curl -I https://YOUR-DOMAIN/assets/css/app.css
```

Expected:

```text
HTTP/1.1 200 OK
```

### Apache error

```bash
sudo tail -100 /var/log/apache2/personal-finance-error.log
```

### PHP error

```bash
sudo tail -100 /var/log/apache2/error.log
```

### Database connection

Verify:

- RDS endpoint
- database name
- username
- password
- security group
- port 3306
- RDS availability

### SMTP

Verify:

```text
smtp.gmail.com
587
STARTTLS
```

and use a Gmail App Password.

---

# 29. Important Production Checklist

Before declaring the application production-ready:

- [ ] HTTPS enabled
- [ ] HTTP redirects to HTTPS
- [ ] Production database credentials configured
- [ ] Gmail App Password configured securely
- [ ] `config.php` excluded from Git
- [ ] `.env` excluded from Git
- [ ] `vendor/` excluded from Git
- [ ] PHP `display_errors=Off`
- [ ] Apache directory listing disabled
- [ ] Database port not publicly exposed
- [ ] RDS backups enabled
- [ ] SSH restricted to administrator IP
- [ ] Super Admin password changed from installation/test credentials
- [ ] Password reset tested
- [ ] Transaction ownership tested
- [ ] Admin RBAC tested
- [ ] CSV export tested
- [ ] XLSX export tested
- [ ] Mobile layout tested
- [ ] Database backup verified

---

# 30. Version

Current application release:

```text
Personal Finance Web Application
Version: 1.2.0
```

The application is intended to be a simple, secure, self-hosted personal finance management system that can run on a conventional PHP/Apache server or an AWS EC2 environment.

---

## License

Add your preferred license here, for example MIT, GPL-3.0, or a private/proprietary license.
