# AWS EC2 + RDS Deployment

This guide assumes Ubuntu on EC2, Apache/PHP on EC2, and MySQL on Amazon RDS.

## 1. AWS security groups

EC2 inbound:

- TCP 22 from your own public IP only
- TCP 80 from the internet (or temporarily while obtaining HTTPS)
- TCP 443 from the internet

RDS inbound:

- TCP 3306 from the EC2 security group only
- Do not allow `0.0.0.0/0` to RDS 3306

## 2. Install server packages

```bash
sudo apt update
sudo apt install -y apache2 php8.3 php8.3-mysql php8.3-mbstring php8.3-xml php8.3-zip php8.3-gd php8.3-curl php8.3-bcmath unzip git
```

Verify:

```bash
php -v
php -m | grep -E 'PDO|pdo_mysql|mbstring|xml|dom|SimpleXML|zip|gd|curl|openssl|json|session|fileinfo'
```

Install Composer 2 using the official Composer installation procedure, then verify with `composer --version`.

## 3. Clone the repository

```bash
sudo mkdir -p /var/www/personal-finance
sudo chown -R "$USER":"$USER" /var/www/personal-finance
git clone YOUR_GITHUB_REPOSITORY_URL /var/www/personal-finance
cd /var/www/personal-finance
composer install --no-dev --optimize-autoloader
```

Do not commit or copy `config.php` from development.

## 4. Apache

Copy and edit `deploy/apache-vhost.conf.example` into `/etc/apache2/sites-available/personal-finance.conf`.

Then:

```bash
sudo a2enmod rewrite
sudo a2ensite personal-finance.conf
sudo a2dissite 000-default.conf
sudo apache2ctl configtest
sudo systemctl reload apache2
```

Point DNS at the EC2 public address / load balancer before final HTTPS configuration.

## 5. RDS

Create an RDS MySQL database and note:

- endpoint
- port
- database name
- username
- password

Do not expose port 3306 publicly.

## 6. First-time application setup

Open the configured application URL. Because `config.php` is not in Git, the application redirects to `setup.php`.

Enter the RDS connection details and create the Super Admin account.

For Gmail SMTP:

- Host: `smtp.gmail.com`
- Port: `587`
- Encryption: `TLS`
- Username: complete Gmail address
- Password: Google App Password
- From Email: the authenticated Gmail address

The installer creates the schema, roles, categories and first Super Admin, then writes `config.php`.

## 7. Lock down configuration

After setup:

```bash
sudo chmod 640 /var/www/personal-finance/config.php
sudo chown www-data:www-data /var/www/personal-finance/config.php
```

If you deploy future versions by replacing the application tree, preserve the production `config.php` separately and do not put it in Git.

## 8. HTTPS

Use a trusted TLS certificate for the production domain and force HTTP to HTTPS. After HTTPS is enabled, PHP sessions automatically set the Secure cookie flag because the application detects HTTPS.

## 9. Smoke tests

Test:

1. `/`
2. `/login.php`
3. registration
4. login by email
5. login by username
6. add/edit/delete transaction
7. month/year transaction filtering
8. CSV export
9. XLSX export
10. budget
11. goals
12. Super Admin category CRUD
13. forgot password email
14. verification code
15. password reset
16. logout

## 10. Production PHP settings

Ensure PHP production settings have:

```ini
display_errors = Off
log_errors = On
expose_php = Off
```

Keep detailed errors in server logs, not in browser responses.
