Restaurante App - Documentación Técnica

---

## Requisitos previos

* [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (3.x o superior recomendado)
* Android Studio, VS Code o cualquier IDE compatible con Flutter
* Emulador Android o dispositivo físico
* Cuenta Google configurada para Firebase
* Archivo `google-services.json` (ya incorporadas las claves del profesor pero OJO, SHA-1)

---

## Configuración inicial

1. Descargar este repositorio.
2. Ubica el archivo `google-services.json` dentro de `android/app/`.

3. Instala las dependencias necesarias:

   en la terminal poner: flutter pub get

4. **(Opcional)** Revisa o personaliza el archivo `lib/data/api_service.dart` (Ya que se utilizo el token entregado por el profesor)
---

## Estructura del proyecto

-- `main.dart`: Contiene la lógica principal, vistas, rutas, y toda la experiencia visual y de usuario.
-- `data/api_service.dart`: Encapsula todas las llamadas HTTP a la API de menús y evaluación de platos.
-- `android/`: Archivos nativos y configuración para el despliegue en Android (incluye google-services.json).

---

## Despliegue y ejecución

1. Conecta tu dispositivo Android o inicia un emulador.
2. Desde la raíz del proyecto abrir la terminal cmd, idle, y ejecutar:

   > flutter run

3. La aplicación iniciará mostrando la pantalla de login Google. Tras autenticarte, verás el menú principal del restaurante.

---

## Funcionalidades

-- Autenticación Google/Firebase
-- Visualización de menús
-- Detalle de platos y bebidas
-- Valoración de platos
-- Pop-up moderno
-- Diseño responsivo

---


## Preguntas frecuentes

--¿Puedo desplegar en iOS?**

> No, el proyecto está configurado para Android

--¿Cómo actualizo el menú o la clave del profe?**

> Solo modifica la constante en `api_service.dart` (Static const String TokenProfe) y vuelve a ejecutar la app.
