# Django Sales API

REST API construida con Django + Django REST Framework + PostgreSQL.  
Gestiona **Categorías**, **Productos**, **Clientes** y **Ventas**.

---

## Stack

- Python 3.12
- Django 6.0.4
- Django REST Framework 3.17.1
- PostgreSQL 17
- Docker + Docker Compose
- djangorestframework-simplejwt 5.5.1

---

## Estructura del proyecto

```
sales/
├── apps/
│   ├── product/         → Categorías y Productos
│   ├── client/          → Clientes
│   └── sale/            → Ventas y Detalles
├── config/
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── requirements.txt
└── pyproject.toml
```

---

## Requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

---

## Iniciar el proyecto

### 1. Construir y levantar

```bash
docker-compose up --build
```

En segundo plano:

```bash
docker-compose up --build -d
```

> El `entrypoint.sh` espera automáticamente a que PostgreSQL esté listo antes de arrancar Django.

API disponible en: `http://localhost:8000`  
Panel admin: `http://localhost:8000/admin/`

---

### 2. Aplicar migraciones

```bash
docker exec -it django_sales_app python manage.py makemigrations
docker exec -it django_sales_app python manage.py migrate
```

---

### 3. Crear superusuario

```bash
docker exec -it django_sales_app python manage.py createsuperuser
```

---

### 4. Detener el proyecto

```bash
docker-compose down
```

---

## Seguridad — Toggle JWT

La API puede correr **con o sin autenticación JWT** mediante una variable de entorno en `docker-compose.yml`, sin necesidad de cambiar código ni ramas.

### Sin seguridad (pruebas)

```yaml
- USE_JWT=false
```

Todos los endpoints son públicos. No se requiere token.

### Con seguridad (producción)

```yaml
- USE_JWT=true
```

Todos los endpoints requieren el header:

```
Authorization: Bearer <access_token>
```

### Obtener token

```
POST /auth/token/
```

```json
{
  "username": "admin",
  "password": "tu_password"
}
```

Response:

```json
{
  "access": "eyJ...",
  "refresh": "eyJ..."
}
```

### Renovar token

```
POST /auth/token/refresh/
```

```json
{
  "refresh": "eyJ..."
}
```

Response:

```json
{
  "access": "eyJ..."
}
```

> Los endpoints `/auth/token/` y `/auth/token/refresh/` están siempre disponibles independientemente del valor de `USE_JWT`.

---

## Endpoints

### Auth

| Método | URL                    | Acción                        |
|--------|------------------------|-------------------------------|
| POST   | `/auth/token/`         | Login → obtener access+refresh|
| POST   | `/auth/token/refresh/` | Renovar access token          |

### Categorías

| Método | URL                          | Acción                    |
|--------|------------------------------|---------------------------|
| GET    | `/product/categories/`       | Listar categorías         |
| POST   | `/product/categories/`       | Crear categoría           |
| GET    | `/product/categories/{id}/`  | Obtener categoría         |
| PUT    | `/product/categories/{id}/`  | Reemplazar categoría      |
| PATCH  | `/product/categories/{id}/`  | Actualizar parcialmente   |
| DELETE | `/product/categories/{id}/`  | Eliminar categoría        |

### Productos

| Método | URL                         | Acción                    |
|--------|-----------------------------|---------------------------|
| GET    | `/product/products/`        | Listar productos          |
| POST   | `/product/products/`        | Crear producto            |
| GET    | `/product/products/{id}/`   | Obtener producto          |
| PUT    | `/product/products/{id}/`   | Reemplazar producto       |
| PATCH  | `/product/products/{id}/`   | Actualizar parcialmente   |
| DELETE | `/product/products/{id}/`   | Eliminar producto         |

### Clientes

| Método | URL                         | Acción                    |
|--------|-----------------------------|---------------------------|
| GET    | `/client/clients/`          | Listar clientes           |
| POST   | `/client/clients/`          | Crear cliente             |
| GET    | `/client/clients/{id}/`     | Obtener cliente           |
| PUT    | `/client/clients/{id}/`     | Reemplazar cliente        |
| PATCH  | `/client/clients/{id}/`     | Actualizar parcialmente   |
| DELETE | `/client/clients/{id}/`     | Eliminar cliente          |

### Ventas

| Método | URL                      | Acción                         |
|--------|--------------------------|--------------------------------|
| GET    | `/sale/sales/`           | Listar ventas                  |
| POST   | `/sale/sales/`           | Crear venta con detalles       |
| GET    | `/sale/sales/{id}/`      | Obtener venta                  |

> Las ventas no se editan ni eliminan — solo `create`, `list` y `retrieve`.

---

## Documentación de la API

---

### Category

#### Campos

| Campo         | Tipo    | Requerido | Notas               |
|---------------|---------|-----------|---------------------|
| `id`          | integer | auto      | Clave primaria      |
| `name`        | string  | ✅        | Único, max 50 chars |
| `description` | string  | ✅        |                     |

#### POST `/product/categories/`

Request:
```json
{
  "name": "Electrónica",
  "description": "Dispositivos y accesorios electrónicos"
}
```

Response `201`:
```json
{
  "id": 1,
  "name": "Electrónica",
  "description": "Dispositivos y accesorios electrónicos"
}
```

#### GET `/product/categories/`

```json
[
  {
    "id": 1,
    "name": "Electrónica",
    "description": "Dispositivos y accesorios electrónicos"
  }
]
```

---

### Product

#### Campos

| Campo         | Tipo    | Requerido | Notas                        |
|---------------|---------|-----------|------------------------------|
| `id`          | integer | auto      | Clave primaria               |
| `category`    | integer | ✅        | FK a Category                |
| `name`        | string  | ✅        | Único, max 50 chars          |
| `price`       | decimal | ✅        | Max 10 dígitos, 2 decimales  |
| `description` | string  | ✅        |                              |

> **Comportamiento del serializer:**  
> - `POST`, `PUT`, `PATCH` → `category` se envía como **entero** (ID)  
> - `GET` → `category` se devuelve como **objeto anidado**

#### POST `/product/products/`

Request:
```json
{
  "category": 1,
  "name": "Auriculares Bluetooth",
  "price": "49.99",
  "description": "Auriculares inalámbricos con cancelación de ruido"
}
```

Response `201`:
```json
{
  "id": 1,
  "category": 1,
  "name": "Auriculares Bluetooth",
  "price": "49.99",
  "description": "Auriculares inalámbricos con cancelación de ruido"
}
```

#### GET `/product/products/`

```json
[
  {
    "id": 1,
    "category": {
      "id": 1,
      "name": "Electrónica",
      "description": "Dispositivos y accesorios electrónicos"
    },
    "name": "Auriculares Bluetooth",
    "price": "49.99",
    "description": "Auriculares inalámbricos con cancelación de ruido"
  }
]
```

---

### Client

#### Campos

| Campo             | Tipo    | Requerido | Notas               |
|-------------------|---------|-----------|---------------------|
| `id`              | integer | auto      | Clave primaria      |
| `name`            | string  | ✅        | Max 100 chars       |
| `document_number` | string  | ✅        | Único, max 20 chars |

#### POST `/client/clients/`

Request:
```json
{
  "name": "Juan Pérez",
  "document_number": "12345678"
}
```

Response `201`:
```json
{
  "id": 1,
  "name": "Juan Pérez",
  "document_number": "12345678"
}
```

#### GET `/client/clients/`

```json
[
  {
    "id": 1,
    "name": "Juan Pérez",
    "document_number": "12345678"
  }
]
```

---

### Sale

#### Campos — Sale

| Campo       | Tipo     | Requerido | Notas                                    |
|-------------|----------|-----------|------------------------------------------|
| `id`        | integer  | auto      | Número de comprobante                    |
| `client`    | integer  | ✅        | FK a Client                              |
| `created_at`| datetime | auto      | Fecha y hora de creación                 |
| `subtotal`  | decimal  | calculado | Suma de subtotales de todos los detalles |
| `igv`       | decimal  | calculado | subtotal × 18%                           |
| `total`     | decimal  | calculado | subtotal + igv                           |

#### Campos — SaleDetail

| Campo      | Tipo    | Requerido | Notas                                        |
|------------|---------|-----------|----------------------------------------------|
| `id`       | integer | auto      | Clave primaria                               |
| `sale`     | integer | auto      | FK a Sale                                    |
| `product`  | integer | ✅        | FK a Product                                 |
| `quantity` | integer | ✅        | Mínimo 1                                     |
| `price`    | decimal | calculado | Copiado del producto al momento de la venta  |
| `subtotal` | decimal | calculado | price × quantity                             |

> **Comportamiento del serializer:**  
> - `POST` → `client` es un **entero**, cada detalle solo lleva `product` (ID) y `quantity`. El backend resuelve precios, subtotales, IGV y total.  
> - `GET` → `client` y `product` se devuelven como **objetos anidados** completos.

#### POST `/sale/sales/`

Request:
```json
{
  "client": 1,
  "details": [
    {
      "product": 1,
      "quantity": 2
    },
    {
      "product": 2,
      "quantity": 1
    }
  ]
}
```

Response `201`:
```json
{
  "id": 1,
  "client": {
    "id": 1,
    "name": "Juan Pérez",
    "document_number": "12345678"
  },
  "created_at": "2026-05-02T14:30:00Z",
  "subtotal": "149.97",
  "igv": "26.99",
  "total": "176.96",
  "details": [
    {
      "id": 1,
      "product": {
        "id": 1,
        "category": {
          "id": 1,
          "name": "Electrónica",
          "description": "Dispositivos y accesorios electrónicos"
        },
        "name": "Auriculares Bluetooth",
        "price": "49.99",
        "description": "Auriculares inalámbricos con cancelación de ruido"
      },
      "quantity": 2,
      "price": "49.99",
      "subtotal": "99.98"
    },
    {
      "id": 2,
      "product": {
        "id": 2,
        "category": {
          "id": 1,
          "name": "Electrónica",
          "description": "Dispositivos y accesorios electrónicos"
        },
        "name": "Cable USB-C",
        "price": "49.99",
        "description": "Cable de carga rápida"
      },
      "quantity": 1,
      "price": "49.99",
      "subtotal": "49.99"
    }
  ]
}
```

#### GET `/sale/sales/`

Misma estructura que el response del POST, dentro de un array `[]`.

---

## Errores comunes

#### Campo requerido faltante
```json
{
  "name": ["This field is required."]
}
```

#### FK inválida
```json
{
  "client": ["Invalid pk \"99\" - object does not exist."]
}
```

#### Nombre duplicado
```json
{
  "name": ["product with this name already exists."]
}
```

#### Venta sin detalles
```json
{
  "details": ["La venta debe tener al menos un detalle."]
}
```

#### Sin token (cuando USE_JWT=true)
```json
{
  "detail": "Authentication credentials were not provided."
}
```

#### Token inválido o expirado (cuando USE_JWT=true)
```json
{
  "detail": "Given token not valid for any token type",
  "code": "token_not_valid"
}
```