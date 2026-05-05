# FileController

> **Package:** `com.project.radix.Controller.FileController`
> **Rutas:** `/api/upload`, `/api/files`
> **Endpoints:** 2

---

## Descripción general

Gestiona la subida y descarga de archivos (imágenes, PDFs) en el sistema. Los archivos se almacenan en el sistema de archivos del servidor con nombres UUID y se sirven con detección automática de Content-Type.

**Configuración:**
| Propiedad | Valor |
|-----------|-------|
| Límite de tamaño | 50 MB |
| Directorio de almacenamiento | `/home/ubuntu/radix-uploads/` |
| Variable de configuración | `radix.uploads.path` (default: `/tmp/radix-uploads`) |
| Persistencia | Volumen Docker montado en el host |

---

## Endpoints

### `POST /api/upload`

Sube un archivo al servidor. Acepta `multipart/form-data` con un campo `file`.

**Request:** `multipart/form-data`
```
Content-Disposition: form-data; name="file"; filename="radiografia.jpg"
Content-Type: image/jpeg

<datos binarios>
```

**Respuesta `201`:**
```json
{
  "url": "/api/files/fba4bbfc-5af6-4163-a5e2-4f6fc4afa396",
  "filename": "fba4bbfc-5af6-4163-a5e2-4f6fc4afa396",
  "originalName": "radiografia.jpg",
  "size": 245760
}
```

**Errores:**
| Código | Mensaje |
|--------|---------|
| 400 | `File is empty` |
| 500 | `Failed to store file: <mensaje del sistema>` |

---

### `GET /api/files/{filename}`

Sirve un archivo previamente subido. El Content-Type se detecta automáticamente mediante `Files.probeContentType()` de Java NIO.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `filename` | String | Nombre del archivo (UUID + extensión) |

**Respuesta `200`:** Archivo binario con headers:
```
Content-Type: image/jpeg
Content-Disposition: inline; filename="fba4bbfc-5af6-4163-a5e2-4f6fc4afa396"
```

**Respuesta `404`:** Si el archivo no existe o no se puede leer.

---

## Componente frontend

El componente `FileUpload.tsx` proporciona una interfaz de arrastrar y soltar para subir archivos:

```tsx
<FileUpload onUpload={(url) => console.log('Archivo subido a:', url)} />
```

**Características del componente:**
- Drag & drop + click para seleccionar archivo
- Vista previa de imágenes
- Barra de progreso durante la subida
- Límite configurable (default: 10 MB)
- Formatos aceptados: imágenes y PDF

---

## Notas de implementación

- Los archivos se renombran con UUID para evitar colisiones y problemas de seguridad.
- La extensión original se conserva para la detección de Content-Type.
- El directorio de uploads se monta como volumen Docker (`-v /home/ubuntu/radix-uploads:/home/ubuntu/radix-uploads`) para persistencia entre reinicios del contenedor.
- La variable de entorno `UPLOADS_PATH` se inyecta en el despliegue (`-e UPLOADS_PATH=/home/ubuntu/radix-uploads`).
- En desarrollo local, los archivos se guardan en `/tmp/radix-uploads`.
- Sin autenticación requerida para la subida (se recomienda añadir en producción).
