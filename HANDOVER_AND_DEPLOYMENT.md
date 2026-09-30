# دليل تسليم ونشر المشروع | Project Handover & Deployment Guide

---

## 1. بيانات مفتاح التوقيع (Android Keystore Signing)

* **مسار المفتاح داخل المشروع:** `android/app/hessa.jks`
* **ملف الخصائص:** `android/key.properties`
* **بيانات الاعتماد (Signing Credentials):**
  * **Key Alias:** `hessa`
  * **Keystore Password:** `Hessa2026!SecureApp#Key`
  * **Key Password:** `Hessa2026!SecureApp#Key`

> **تنبيه:** يجب الاحتفاظ بنسخة احتياطية آمنة من ملف `hessa.jks` وكلمات المرور، حيث إنها ضرورية لتوقيع وتحديث أي إصدار قادم على Google Play.

---

## 2. متطلبات السيرفر (Server Requirements)

* **PHP:** >= 8.2 (مع الإضافات: `BCMath`, `Ctype`, `cURL`, `DOM`, `Fileinfo`, `JSON`, `Mbstring`, `OpenSSL`, `PCRE`, `PDO`, `Tokenizer`, `XML`)
* **قاعدة البيانات:** MySQL >= 8.0 أو MariaDB >= 10.4
* **خادم الويب:** Nginx أو Apache مع تفعيل `mod_rewrite`
* **مدير الحزم:** Composer >= 2.x

---

## 3. خطوات نشر الباك إند (Backend Production Deployment)

1. **رفع ملفات الباك إند إلى السيرفر:**
   ```bash
   cd /path/to/backend
   ```

2. **تثبيت الاعتماديات بدون مكتبات التطوير:**
   ```bash
   composer install --optimize-autoloader --no-dev
   ```

3. **إعداد ملف البيئة للإنتاج:**
   * انسخ ملف `.env.production` إلى `.env`:
     ```bash
     cp .env.production .env
     ```
   * قم بتوليد مفتاح التطبيق:
     ```bash
     php artisan key:generate
     ```
   * عدّل بيانات قاعدة البيانات (`DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`) في ملف `.env`.

4. **تشغيل ترحيل قاعدة البيانات:**
   ```bash
   php artisan migrate --force
   ```

5. **توليد الرابط الرمزي لمجلد التخزين:**
   ```bash
   php artisan storage:link
   ```

6. **توليد الكاش لتسريع الأداء:**
   ```bash
   php artisan config:cache
   Route::cache / php artisan route:cache
   php artisan view:cache
   ```

7. **ضبط تصاريح مجلدات التخزين والكاش:**
   ```bash
   chmod -R 775 storage bootstrap/cache
   chown -R www-data:www-data storage bootstrap/cache
   ```

---

## 4. بيانات الدخول الافتراضية للوحة التحكم (Admin Credentials)

يتم إنشاء حساب المدير الافتراضي تلقائياً عند تشغيل أمر البذور (`php artisan db:seed`):

* **الرابط:** `https://qubahom.com/dashboard` (أو مسار لوحة الإدارة المنشور)
* **البريد الإلكتروني:** `admin@qubah.com`
* **كلمة المرور الافتراضية:** `password`
* **الدور (Role):** `admin`

> **ملاحظة أمنية:** يُنصح بتغيير كلمة المرور فور الدخول إلى لوحة التحكم أو عبر أمر Tinker:
> ```bash
> php artisan tinker --execute="App\Models\User::where('email', 'admin@qubah.com')->update(['password' => bcrypt('YOUR_NEW_PASSWORD')]);"
> ```

---

## 5. ملاحظات الهوية ومعرف التطبيق (App Identity & Package Name)

* **معرف الحزمة (Application ID):** `com.hessa.app`
  * هذا المعرف تم اعتماده عند أول نشر للتطبيق على المتجر، ومن الناحية التقنية لا يتم تغييره في المتجر لضمان وصول التحديثات للمستخدمين الحاليين دون انقطاع.
* **الاسم الظاهر والدومين:**
  * الاسم الظاهر للمستخدمين في المتجر والأجهزة هو "قبة المعرفة / Hessa".
  * الدومين الرسمي للباك إند والـ API هو: `https://qubahom.com`.
