# UnitController

> **Package:** `com.project.radix.Controller.UnitController`
> **Ruta base:** `/api/units`
> **Endpoints:** 2

---

## Descripción general

Catálogo de unidades de medida para dosis de radiación y parámetros clínicos. Datos de referencia usados en formularios y cálculos de tratamiento.

---

## Endpoints

### `GET /api/units`

Lista todas las unidades de medida disponibles.

**Respuesta `200`:**
```json
[
  { "id": 1, "name": "Milicurio", "symbol": "mCi" },
  { "id": 2, "name": "Becquerel", "symbol": "Bq" },
  { "id": 3, "name": "Gray", "symbol": "Gy" },
  { "id": 4, "name": "Sievert", "symbol": "Sv" },
  { "id": 5, "name": "Rad", "symbol": "rad" },
  { "id": 6, "name": "Rem", "symbol": "rem" },
  { "id": 7, "name": "Roentgen", "symbol": "R" },
  { "id": 8, "name": "Coulomb/kg", "symbol": "C/kg" }
]
```

---

### `GET /api/units/{id}`

Obtiene una unidad específica por ID.

**Respuesta `200`:** Objeto `Unit` con `id`, `name` y `symbol`.

**Respuesta `404`:**
```json
{ "error": "Unit not found" }
```

---

## Notas de implementación

- Utiliza directamente `UnitRepository` (sin consultas personalizadas, solo `JpaRepository`).
- La entidad `Unit` está en la tabla `units` con campos: `id`, `name` (NOT NULL), `symbol` (NOT NULL).
- Las unidades se siembran en `DataLoader.java` con 8 unidades estándar.
- El campo `fk_unit_id` en la entidad `Treatment` referencia esta tabla, permitiendo especificar la unidad de medida de la dosis.
