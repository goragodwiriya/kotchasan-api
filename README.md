# Kotchasan API Framework

> API Framework ที่ปลอดภัยและยืดหยุ่น สร้างบน **Kotchasan PHP Framework**  
> รองรับ JWT Authentication, CSRF Protection, Rate Limiting และ OpenAPI Specification

[![PHP](https://img.shields.io/badge/PHP-7.4%2B-blue)](https://php.net)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![OpenAPI](https://img.shields.io/badge/OpenAPI-3.0-orange)](openapi.yaml)

---

## สารบัญ

1. [ภาพรวม](#ภาพรวม)
2. [คุณสมบัติหลัก](#คุณสมบัติหลัก)
3. [ความต้องการของระบบ](#ความต้องการของระบบ)
4. [การติดตั้ง](#การติดตั้ง)
5. [การกำหนดค่า](#การกำหนดค่า)
6. [สถาปัตยกรรม MVC](#สถาปัตยกรรม-mvc)
7. [API Endpoints ทั้งหมด](#api-endpoints-ทั้งหมด)
8. [รูปแบบ Response มาตรฐาน](#รูปแบบ-response-มาตรฐาน)
9. [การยืนยันตัวตน (Authentication)](#การยืนยันตัวตน-authentication)
10. [การทดสอบ API ด้วย curl](#การทดสอบ-api-ด้วย-curl)
11. [สร้าง Module ใหม่](#สร้าง-module-ใหม่)
12. [ความปลอดภัย](#ความปลอดภัย)
13. [การ Deploy บน Production](#การ-deploy-บน-production)
14. [OpenAPI / SDK Generation](#openapi--sdk-generation)
15. [โครงสร้างไฟล์](#โครงสร้างไฟล์)

---

## ภาพรวม

Kotchasan API Framework เป็นการขยาย [Kotchasan PHP Framework](https://www.kotchasan.com/) เพื่อรองรับการพัฒนา **RESTful API** สำหรับ Production โดยมีระบบ routing อัตโนมัติ, authentication ครบวงจร, และ response format มาตรฐาน

```
Base URL: http://your-domain.com/api/{module}/{method}/{action}
```

**ตัวอย่าง:**
```
GET  /api/index/auth/me
POST /api/index/auth/login
GET  /api/index/system/health
```

---

## คุณสมบัติหลัก

| คุณสมบัติ | รายละเอียด |
|---|---|
| 🔐 **JWT Authentication** | Access token + Refresh token rotation พร้อม revoke list |
| 🛡️ **CSRF Protection** | Double submit cookie pattern ป้องกัน CSRF ทุก POST |
| 🚦 **Rate Limiting** | จำกัด request ต่อ IP ต่อนาที กำหนดค่าได้ |
| 🌐 **CORS Management** | Origin allowlist กำหนดผ่าน config |
| 🔒 **IP Allowlist** | จำกัด IP ที่เรียก API ได้ |
| 🗄️ **Multi-Database** | MySQL, PostgreSQL, MSSQL, SQLite |
| 📋 **Standard Response** | JSON Envelope: success, code, message, data, errors, request_id |
| ❤️ **Health Check** | /health, /readiness, /version, /time, /features |
| 📄 **OpenAPI 3.0** | สเปกครบถ้วนใน openapi.yaml |
| 🔔 **Multi-Channel Notify** | Email, Telegram, LINE, SMS |

---

## ความต้องการของระบบ

### ขั้นต่ำ
- **PHP**: 7.4 หรือสูงกว่า (แนะนำ PHP 8.1+)
- **Database**: MySQL 5.7 / MariaDB 10.2 / PostgreSQL 11 / SQLite 3
- **Web Server**: Apache 2.4 / Nginx 1.16
- **Extensions**: `mbstring`, `openssl`, `PDO`, `pdo_mysql`, `curl`, `json`

### แนะนำสำหรับ Production
- PHP 8.1+ พร้อม OPcache
- MySQL 8.0 / MariaDB 10.6
- Redis สำหรับ cache
- SSL Certificate

---

## การติดตั้ง

### 1. Clone โปรเจกต์

```bash
git clone https://github.com/goragodwiriya/kotchasan-api.git
cd kotchasan-api
```

### 2. กำหนด Web Server

**Apache** — สร้าง Virtual Host:
```apache
<VirtualHost *:80>
    ServerName api.your-domain.com
    DocumentRoot /path/to/kotchasan-api
    DirectoryIndex api.php

    <Directory /path/to/kotchasan-api>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

ตรวจสอบว่า `.htaccess` มีอยู่แล้วในโปรเจกต์ (รองรับ URL rewriting)

**Nginx:**
```nginx
server {
    listen 80;
    server_name api.your-domain.com;
    root /path/to/kotchasan-api;
    index api.php;

    location / {
        try_files $uri $uri/ /api.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### 3. สิทธิ์ไฟล์

```bash
# กำหนด permission
chmod -R 755 /path/to/kotchasan-api
chmod -R 777 /path/to/kotchasan-api/datas/cache
```

---

## การกำหนดค่า

### settings/config.php

```php
<?php
return [
    // ─── ข้อมูลระบบ ───────────────────────────────────────
    'version'     => '1.0.0',
    'web_title'   => 'My API',
    'timezone'    => 'Asia/Bangkok',

    // ─── JWT ─────────────────────────────────────────────
    // สร้างด้วย: openssl rand -hex 32
    'jwt_secret'  => 'your-256-bit-hex-secret-here',

    // ─── API Security ────────────────────────────────────
    'api_tokens'  => [
        'internal' => 'token-for-internal-services',
        'external' => 'token-for-external-clients',
    ],
    // IP ที่อนุญาต (ใช้ '0.0.0.0' เพื่อเปิดทุก IP)
    'api_ips'     => ['0.0.0.0'],
    // CORS origins (ใช้ '*' เพื่อเปิดทุก origin)
    'api_cors'    => '*',

    // ─── Feature Flags ───────────────────────────────────
    'user_register'          => 1,  // 1 = เปิดสมัครสมาชิก
    'user_forgot'            => 1,  // 1 = เปิดลืมรหัสผ่าน
    'activate_user'          => 0,  // 1 = ต้องยืนยันอีเมลก่อน login
    'new_members_active'     => 1,  // 1 = active ทันทีหลังสมัคร
    'require_terms_acceptance' => 0,

    // ─── Cache ───────────────────────────────────────────
    'cache_expire' => 5,            // นาที

    // ─── Notifications ───────────────────────────────────
    'telegram_bot_token'    => '',
    'telegram_chat_id'      => '',
];
```

### settings/database.php

```php
<?php
return [
    'default' => [
        'dbdriver'  => 'mysql',         // mysql | pgsql | mssql | sqlite
        'dbhost'    => 'localhost',
        'dbname'    => 'your_database',
        'username'  => 'your_user',
        'password'  => 'your_password',
        'dbcharset' => 'utf8mb4',
        'prefix'    => '',              // prefix ตาราง เช่น 'app_'
    ]
];
```

> **หมายเหตุ:** อย่า commit ไฟล์ `settings/` ลง Git ควรใช้ `.gitignore` หรือ environment variables

---

## สถาปัตยกรรม MVC

### การทำงานของ Request

```
HTTP Request
    │
    ▼
api.php  ─── โหลด Kotchasan Framework
    │
    ▼
Router (Kotchasan\Router)
    │  แปลง URL → module/method/action
    ▼
ApiController (Kotchasan\ApiController)
    │  ตรวจ IP Allowlist
    │  ตรวจ CORS
    │  route ไปยัง Controller
    ▼
{Module}\{Method}\Controller
    │  ตรวจ JWT (ถ้า endpoint ต้องการ)
    │  ตรวจ CSRF (ถ้าเป็น POST)
    │  เรียก Model
    ▼
{Module}\{Method}\Model
    │  Query Builder → Database
    ▼
JSON Response (มาตรฐาน Envelope)
```

### URL Pattern

```
/api/{module}/{method}/{action}
  │       │        │       └── method ใน Controller (default: index)
  │       │        └────────── ชื่อไฟล์ controller (ตรงกับ class ใน namespace)
  │       └─────────────────── ชื่อ module (โฟลเดอร์ใน modules/)
  └─────────────────────────── จุดเข้า API
```

**ตัวอย่างการ map:**

| URL | PHP Class | Method |
|---|---|---|
| `GET /api/index/auth/login` | `Index\Auth\Controller` | `login()` |
| `POST /api/index/auth/register` | `Index\Auth\Controller` | `register()` |
| `GET /api/index/system/health` | `Index\System\Controller` | `health()` |
| `GET /api/myapp/product/list` | `Myapp\Product\Controller` | `list()` |

### โครงสร้าง Module

```
modules/
└── mymodule/
    ├── controllers/
    │   ├── index.php        # namespace Mymodule\Index — default controller
    │   ├── user.php         # namespace Mymodule\User
    │   └── product.php      # namespace Mymodule\Product
    └── models/
        ├── index.php        # namespace Mymodule\Index
        ├── user.php         # namespace Mymodule\User
        └── product.php      # namespace Mymodule\Product
```

---

## API Endpoints ทั้งหมด

### Auth Module (`/api/index/auth/...`)

| Method | Endpoint | หน้าที่ | Auth | CSRF |
|---|---|---|---|---|
| `GET` | `/api/index/auth/csrf-token` | ออก CSRF token | — | — |
| `GET` | `/api/index/auth/settings` | Feature flags (register/forgot/activate) | — | — |
| `GET` | `/api/index/auth/verify` | ตรวจสอบ access token | ✅ | — |
| `GET` | `/api/index/auth/me` | ดึงข้อมูลผู้ใช้ปัจจุบัน | ✅ | — |
| `GET` | `/api/index/auth/activate?id={code}` | ยืนยันบัญชีด้วย activation code | — | — |
| `POST` | `/api/index/auth/login` | เข้าสู่ระบบ | — | ✅ |
| `POST` | `/api/index/auth/logout` | ออกจากระบบ revoke token | — | ✅ |
| `POST` | `/api/index/auth/refresh` | ต่ออายุ token ด้วย refresh token | — | ✅ |
| `POST` | `/api/index/auth/register` | สมัครสมาชิกใหม่ | — | ✅ |
| `POST` | `/api/index/auth/update` | อัปเดตโปรไฟล์ผู้ใช้ | ✅ | ✅ |
| `POST` | `/api/index/auth/forgot` | ขอรีเซ็ตรหัสผ่าน | — | ✅ |
| `POST` | `/api/index/auth/resetpassword` | รีเซ็ตรหัสผ่านด้วย token จากอีเมล | — | ✅ |

### System Module (`/api/index/system/...`)

| Method | Endpoint | หน้าที่ | Response |
|---|---|---|---|
| `GET` | `/api/index/system/health` | Liveness probe | `200` เสมอ |
| `GET` | `/api/index/system/readiness` | Readiness (config/storage/db) | `200` หรือ `503` |
| `GET` | `/api/index/system/version` | เวอร์ชันระบบ | `200` |
| `GET` | `/api/index/system/time` | เวลาเซิร์ฟเวอร์ (Asia/Bangkok) | `200` |
| `GET` | `/api/index/system/features` | Feature flags ทั้งหมด | `200` |

---

## รูปแบบ Response มาตรฐาน

ทุก endpoint คืนค่า JSON Envelope รูปแบบเดียวกัน:

```json
{
  "success": true,
  "code": 200,
  "message": "คำอธิบายผลลัพธ์",
  "data": { ... },
  "errors": null,
  "request_id": "c20e2ed61d9b1abf"
}
```

| Field | Type | รายละเอียด |
|---|---|---|
| `success` | boolean | `true` = สำเร็จ, `false` = ล้มเหลว |
| `code` | int | HTTP status code |
| `message` | string | ข้อความอธิบาย |
| `data` | object\|null | ข้อมูลที่คืนค่า |
| `errors` | object\|string\|null | รายละเอียด error (validation) |
| `request_id` | string | ID สำหรับ tracing ใน logs |

Header ที่ส่งกลับทุกครั้ง: `X-Request-Id`

### HTTP Status Codes

| Code | ความหมาย |
|---|---|
| `200` | สำเร็จ |
| `201` | สร้างข้อมูลสำเร็จ |
| `400` | Bad Request — route หรือ parameter ไม่ถูกต้อง |
| `401` | Unauthorized — ไม่มี token หรือ token หมดอายุ |
| `403` | Forbidden — CSRF token ไม่ถูกต้อง |
| `404` | Not Found — ไม่พบ resource |
| `405` | Method Not Allowed |
| `422` | Unprocessable — Validation error |
| `429` | Too Many Requests — Rate limit exceeded |
| `503` | Service Unavailable — ระบบไม่พร้อม |

---

## การยืนยันตัวตน (Authentication)

### Flow ทั้งหมด

```
1. ขอ CSRF Token  →  GET /auth/csrf-token
2. Login          →  POST /auth/login  (X-CSRF-TOKEN required)
3. เรียก API      →  Authorization: Bearer {access_token}
4. Refresh        →  POST /auth/refresh (เมื่อ access token หมดอายุ)
5. Logout         →  POST /auth/logout
```

### ข้อมูลที่ได้จาก Login

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "token_type": "Bearer",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "name": "ผู้ดูแลระบบ"
  }
}
```

### การส่ง Access Token

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Refresh Token Rotation

- ทุกครั้งที่ใช้ refresh token → ระบบออก token คู่ใหม่
- token เก่าถูก revoke ทันที (เก็บใน `datas/cache/revoked_tokens.json`)
- ป้องกัน token reuse attack

---

## การทดสอบ API ด้วย curl

### ตั้งค่าเริ่มต้น

```bash
# กำหนด Base URL
BASE="http://localhost/kotchasan-api/api"

# ไฟล์เก็บ cookie
COOKIE="/tmp/kotchasan.cookie"
HEADERS="/tmp/kotchasan.headers"
```

---

### 1. ขอ CSRF Token

```bash
curl -s \
  -c $COOKIE \
  -D $HEADERS \
  "$BASE/index/auth/csrf-token"

# อ่าน token จาก response header
TOK=$(grep -i '^X-Csrf-Token:' $HEADERS | awk '{print $2}' | tr -d '\r')
echo "CSRF Token: $TOK"
```

**Response ตัวอย่าง:**
```json
{
  "success": true,
  "code": 200,
  "message": "CSRF token generated",
  "data": { "csrf_token": "abc123..." }
}
```

---

### 2. Login

```bash
curl -s \
  -b $COOKIE -c $COOKIE \
  -H "X-CSRF-TOKEN: $TOK" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"your-password"}' \
  "$BASE/index/auth/login"
```

**Response ตัวอย่าง:**
```json
{
  "success": true,
  "code": 200,
  "message": "Login successful",
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "expires_in": 3600
  }
}
```

```bash
# เก็บ access token
ACCESS_TOKEN="eyJ..."
```

---

### 3. ดึงข้อมูลโปรไฟล์ (ต้องใช้ token)

```bash
curl -s \
  -b $COOKIE \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  "$BASE/index/auth/me"
```

---

### 4. สมัครสมาชิก

```bash
curl -s \
  -b $COOKIE -c $COOKIE \
  -H "X-CSRF-TOKEN: $TOK" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "password": "SecurePass123",
    "email": "user@example.com",
    "name": "ชื่อ นามสกุล"
  }' \
  "$BASE/index/auth/register"
```

---

### 5. Refresh Token

```bash
curl -s \
  -b $COOKIE -c $COOKIE \
  -H "X-CSRF-TOKEN: $TOK" \
  -H "Content-Type: application/json" \
  -d "{\"refresh_token\":\"$REFRESH_TOKEN\"}" \
  "$BASE/index/auth/refresh"
```

---

### 6. ลืมรหัสผ่าน

```bash
curl -s \
  -b $COOKIE -c $COOKIE \
  -H "X-CSRF-TOKEN: $TOK" \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com"}' \
  "$BASE/index/auth/forgot"
```

---

### 7. รีเซ็ตรหัสผ่าน

```bash
curl -s \
  -b $COOKIE -c $COOKIE \
  -H "X-CSRF-TOKEN: $TOK" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "reset-token-from-email",
    "password": "NewPassword123",
    "password_confirm": "NewPassword123"
  }' \
  "$BASE/index/auth/resetpassword"
```

---

### 8. Logout

```bash
curl -s \
  -b $COOKIE -c $COOKIE \
  -H "X-CSRF-TOKEN: $TOK" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -X POST \
  "$BASE/index/auth/logout"
```

---

### 9. Health Check

```bash
# Liveness
curl -s "$BASE/index/system/health"

# Readiness (ตรวจ config/storage/database)
curl -s "$BASE/index/system/readiness"

# เวอร์ชัน
curl -s "$BASE/index/system/version"

# เวลาเซิร์ฟเวอร์
curl -s "$BASE/index/system/time"

# Feature flags
curl -s "$BASE/index/system/features"
```

---

### Script ทดสอบครบวงจร

```bash
#!/bin/bash
# test-api.sh — ทดสอบ login flow ครบวงจร

BASE="http://localhost/kotchasan-api/api"
COOKIE="/tmp/k.cookie"
HEADERS="/tmp/k.headers"

echo "=== 1. ขอ CSRF Token ==="
curl -s -c $COOKIE -D $HEADERS "$BASE/index/auth/csrf-token" | python3 -m json.tool
TOK=$(grep -i '^X-Csrf-Token:' $HEADERS | awk '{print $2}' | tr -d '\r')
echo "Token: $TOK"

echo -e "\n=== 2. Login ==="
RESP=$(curl -s -b $COOKIE -c $COOKIE \
  -H "X-CSRF-TOKEN: $TOK" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' \
  "$BASE/index/auth/login")
echo $RESP | python3 -m json.tool
ACCESS=$(echo $RESP | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['access_token'] if d['success'] else '')" 2>/dev/null)

echo -e "\n=== 3. ดึงโปรไฟล์ ==="
curl -s -b $COOKIE \
  -H "Authorization: Bearer $ACCESS" \
  "$BASE/index/auth/me" | python3 -m json.tool

echo -e "\n=== 4. Health Check ==="
curl -s "$BASE/index/system/health" | python3 -m json.tool
```

---

## สร้าง Module ใหม่

### ขั้นตอนสร้าง Module `product`

```bash
mkdir -p modules/product/controllers
mkdir -p modules/product/models
```

**modules/product/controllers/product.php**

```php
<?php
namespace Product\Product;

use Kotchasan\Http\Request;

/**
 * Product Controller
 * Endpoint: /api/product/product/{action}
 */
class Controller extends \Kotchasan\ApiController
{
    /**
     * GET /api/product/product/index
     * ดึงรายการสินค้าทั้งหมด
     */
    public function index(Request $request): array
    {
        $page    = (int) $request->get('page', 1)->toInt();
        $perPage = (int) $request->get('per_page', 20)->toInt();

        $result = \Product\Product\Model::getAll($page, $perPage);

        return [
            'success' => true,
            'code'    => 200,
            'data'    => $result,
        ];
    }

    /**
     * GET /api/product/product/show?id={id}
     * ดึงข้อมูลสินค้าตาม ID
     */
    public function show(Request $request): array
    {
        $id = (int) $request->get('id', 0)->toInt();

        if ($id === 0) {
            return ['success' => false, 'code' => 400, 'message' => 'ID is required'];
        }

        $item = \Product\Product\Model::get($id);

        if ($item === null) {
            return ['success' => false, 'code' => 404, 'message' => 'Product not found'];
        }

        return ['success' => true, 'code' => 200, 'data' => $item];
    }

    /**
     * POST /api/product/product/create
     * สร้างสินค้าใหม่
     */
    public function create(Request $request): array
    {
        // ตรวจสอบ JWT (ต้อง login ก่อน)
        $user = $this->getAuthUser($request);
        if (!$user) {
            return ['success' => false, 'code' => 401, 'message' => 'Unauthorized'];
        }

        $data = $request->getParsedBody();

        // Validation
        if (empty($data['topic'])) {
            return [
                'success' => false,
                'code'    => 422,
                'errors'  => ['topic' => 'กรุณากรอกชื่อสินค้า'],
            ];
        }

        $id = \Product\Product\Model::create($data);

        return ['success' => true, 'code' => 201, 'data' => ['id' => $id]];
    }
}
```

**modules/product/models/product.php**

```php
<?php
namespace Product\Product;

use Kotchasan\Model;

class Model extends \Kotchasan\Model
{
    /**
     * ดึงรายการสินค้าแบบ pagination
     */
    public static function getAll(int $page = 1, int $perPage = 20): array
    {
        $offset = ($page - 1) * $perPage;

        $db = static::createQuery();

        $total = $db->select('COUNT(*) AS cnt')
            ->from('products')
            ->where('published', 1)
            ->toValue();

        $items = $db->select()
            ->from('products')
            ->where('published', 1)
            ->orderBy('id', 'DESC')
            ->limit($perPage, $offset)
            ->toArray();

        return [
            'items'    => $items,
            'total'    => (int) $total,
            'page'     => $page,
            'per_page' => $perPage,
            'pages'    => (int) ceil($total / $perPage),
        ];
    }

    /**
     * ดึงข้อมูลสินค้าตาม ID
     * @return object|null
     */
    public static function get(int $id)
    {
        return static::createQuery()
            ->select()
            ->from('products')
            ->where('id', $id)
            ->toObject();
    }

    /**
     * สร้างสินค้าใหม่
     */
    public static function create(array $data): int
    {
        return static::createQuery()
            ->insert('products')
            ->set($data)
            ->execute();
    }
}
```

**เรียกใช้งาน:**

```bash
GET  /api/product/product/index          # รายการสินค้า
GET  /api/product/product/show?id=1      # สินค้า ID 1
POST /api/product/product/create         # สร้างใหม่ (ต้อง login)
```

---

## ความปลอดภัย

### 1. JWT Token

```php
// ตั้งค่าใน config.php
'jwt_secret' => 'your-256-bit-secret',  // สร้างด้วย: openssl rand -hex 32

// Access token หมดอายุใน 1 ชั่วโมง (3600 วินาที)
// Refresh token หมดอายุใน 7 วัน (604800 วินาที)
```

### 2. CSRF Protection

```
ทุก POST endpoint ต้องมี:
  Header: X-CSRF-TOKEN: {token}
  Cookie: session cookie จากการ GET /auth/csrf-token

ถ้าไม่มี → HTTP 403 Forbidden
```

### 3. Rate Limiting

```php
// ปรับค่าใน SecurityMiddleware
'maxRequestsPerMinute' => 60,    // ค่าเริ่มต้น
'maxLoginAttempts'     => 5,     // สำหรับ /auth/login
```

### 4. IP Allowlist

```php
// เปิดทุก IP (development)
'api_ips' => ['0.0.0.0'],

// จำกัด IP (production)
'api_ips' => ['203.0.113.1', '198.51.100.0'],
```

### 5. CORS

```php
// เปิดทุก origin (development)
'api_cors' => '*',

// จำกัด origin (production)
'api_cors' => 'https://app.your-domain.com',
```

### OWASP Checklist

- [x] SQL Injection → Prepared Statements ใน Query Builder
- [x] XSS → input filter และ JSON output encoding
- [x] CSRF → Double submit cookie
- [x] Broken Authentication → JWT + rotation + revoke list
- [x] Security Misconfiguration → IP allowlist, CORS
- [x] Sensitive Data → รหัสผ่าน hash ด้วย bcrypt
- [x] Rate Limiting → ป้องกัน brute force

---

## การ Deploy บน Production

### ก่อน Deploy

1. ตั้ง `'debug' => false` ใน config
2. เปลี่ยน `jwt_secret` เป็น random string ใหม่
3. กำหนด `api_ips` เป็น IP จริง (ไม่ใช่ `0.0.0.0`)
4. กำหนด `api_cors` เป็น domain จริง
5. ใช้ HTTPS เท่านั้น
6. ตั้ง permission `datas/cache/` ให้เขียนได้

### Environment Variables (แนะนำ)

สร้าง `settings/config.local.php` และ `.gitignore` ไฟล์นี้:

```php
<?php
// settings/config.local.php — ไม่ commit ลง Git
return [
    'jwt_secret' => getenv('JWT_SECRET'),
    'api_tokens' => [
        'internal' => getenv('API_TOKEN_INTERNAL'),
        'external' => getenv('API_TOKEN_EXTERNAL'),
    ],
];
```

### Docker (ตัวอย่าง)

```dockerfile
FROM php:8.1-apache
RUN docker-php-ext-install pdo_mysql mbstring
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html/datas/
```

```yaml
# docker-compose.yml
services:
  api:
    build: .
    ports: ["80:80"]
    environment:
      JWT_SECRET: "your-production-secret"
    depends_on: [db]
  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: kotchasan_api
      MYSQL_ROOT_PASSWORD: secret
```

---

## OpenAPI / SDK Generation

### สเปกไฟล์

ดูและแก้ไขสเปก: [openapi.yaml](openapi.yaml)

### Generate TypeScript Client

```bash
# ติดตั้ง OpenAPI Generator
npm install -g @openapitools/openapi-generator-cli

# Generate TypeScript SDK
openapi-generator-cli generate \
  -i openapi.yaml \
  -g typescript-fetch \
  -o sdk/typescript \
  --additional-properties=typescriptThreePlus=true
```

### Generate Python Client

```bash
openapi-generator-cli generate \
  -i openapi.yaml \
  -g python \
  -o sdk/python \
  --additional-properties=packageName=kotchasan_api
```

### Swagger UI (local)

```bash
# ดู API docs ผ่าน Swagger UI
docker run -p 8080:8080 \
  -e SWAGGER_JSON=openapi.yaml \
  -v $(pwd)/docs:/ \
  swaggerapi/swagger-ui
# เปิด http://localhost:8080
```

---

## โครงสร้างไฟล์

```
kotchasan-api/
├── api.php                     # จุดเข้าหลัก (entry point)
├── load.php                    # Bootstrap / autoloader
├── index.html                  # Landing page
├── README.md                   # คู่มือนี้
├── openapi.yaml                # OpenAPI 3.0 Specification
│
├── Kotchasan/                  # PHP Framework Core
│   ├── ApiController.php       # Base class สำหรับ API controllers
│   ├── Router.php              # URL routing
│   ├── JwtMiddleware.php       # JWT authentication
│   ├── Validator.php           # Input validation
│   ├── Database.php            # Database abstraction
│   ├── Model.php               # Base Model class
│   ├── QueryBuilder/           # Query Builder (Select/Insert/Update/Delete)
│   ├── Connection/             # Database drivers
│   ├── Http/                   # Request/Response classes
│   ├── Cache/                  # Cache system (File/Memory/Redis)
│   └── Security/               # Security utilities
│
├── Gcms/                       # CMS / Application layer
│   ├── Api.php                 # API base controller
│   └── Config.php              # Application config loader
│
├── modules/                    # Application modules
│   └── index/                  # Module หลัก
│       ├── controllers/
│       │   ├── auth.php        # Authentication endpoints
│       │   ├── index.php       # Default controller
│       │   ├── system.php      # Health/Version endpoints
│       │   └── registrationvalidator.php
│       └── models/
│
├── settings/                   # Configuration files
│   ├── config.php              # Application config
│   └── database.php            # Database config
│
├── datas/                      # Runtime data
│   └── cache/
│       ├── auth_sessions.json  # Active sessions
│       └── revoked_tokens.json # Revoked JWT tokens
│
└── docs/                       # Documentation
    ├── th/                     # เอกสารภาษาไทย
    │   ├── API.md
    │   ├── API_ENDPOINTS.md
    │   ├── mvc-guide.md
    │   ├── deployment-guide.md
    │   └── practical-examples.md
    └── en/                     # English documentation
        ├── API.md
        ├── mvc-guide.md
        └── deployment-guide.md
```

---

## การแก้ไขปัญหาเบื้องต้น

### 403 Forbidden บน POST

```
สาเหตุ: ไม่มี CSRF token หรือ token หมดอายุ
แก้ไข: เรียก GET /auth/csrf-token ใหม่ก่อน POST
```

### 401 Unauthorized

```
สาเหตุ: access token หมดอายุ หรือไม่มี Authorization header
แก้ไข:
  1. ตรวจสอบ Authorization: Bearer {token} header
  2. POST /auth/refresh ด้วย refresh_token
  3. Login ใหม่ถ้า refresh token หมดอายุ
```

### 503 Service Unavailable (readiness)

```
สาเหตุ: ไม่สามารถเชื่อมต่อ database ได้
แก้ไข: ตรวจสอบ settings/database.php และ database server
```

### CORS Error ใน Browser

```
สาเหตุ: origin ไม่อยู่ใน allowlist
แก้ไข: เพิ่ม origin ใน 'api_cors' ใน config.php
       หรือตั้งค่า 'api_cors' => '*' ชั่วคราว
```

---

## การสนับสนุน

- 📚 [เอกสาร](https://docs.kotchasan.com/)
- 📄 [OpenAPI Specification](openapi.yaml)
- 🌐 [Kotchasan Framework](https://www.kotchasan.com/)

---

**Kotchasan API Framework** — สร้างบน [Kotchasan PHP Framework](https://www.kotchasan.com/)  
PHP 7.4+ · MySQL/PostgreSQL/MSSQL/SQLite · MIT License
