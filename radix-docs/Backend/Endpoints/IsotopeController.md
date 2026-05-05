# IsotopeController

> **Package:** `com.project.radix.Controller.IsotopeController`
> **Ruta base:** `/api/isotopes`
> **Endpoints:** 2

---

## Descripción general

Catálogo de radioisótopos utilizados en tratamientos de medicina nuclear. Datos de referencia que incluyen nombre, símbolo, tipo de radiación, vida media y unidad de tiempo.

---

## Endpoints

### `GET /api/isotopes`

Lista todos los radioisótopos del catálogo.

**Respuesta `200`:**
```json
[
  {
    "id": 1,
    "name": "Yodo-131",
    "symbol": "I-131",
    "type": "Beta/Gamma",
    "halfLife": 8.02,
    "halfLifeUnit": "días"
  },
  {
    "id": 2,
    "name": "Tecnecio-99m",
    "symbol": "Tc-99m",
    "type": "Gamma",
    "halfLife": 6.01,
    "halfLifeUnit": "horas"
  }
]
```

**Catálogo completo:**
| ID | Nombre | Símbolo | Tipo | Vida media | Unidad |
|----|--------|---------|------|------------|--------|
| 1 | Yodo-131 | I-131 | Beta/Gamma | 8.02 | días |
| 2 | Tecnecio-99m | Tc-99m | Gamma | 6.01 | horas |
| 3 | Radio-223 | Ra-223 | Alfa | 11.4 | días |
| 4 | Lutecio-177 | Lu-177 | Beta/Gamma | 6.65 | días |
| 5 | Itrio-90 | Y-90 | Beta | 2.67 | días |
| 6 | Samario-153 | Sm-153 | Beta/Gamma | 1.95 | días |
| 7 | Holmio-166 | Ho-166 | Beta/Gamma | 1.12 | días |
| 8 | Renio-186 | Re-186 | Beta/Gamma | 3.7 | días |
| 9 | Renio-188 | Re-188 | Beta/Gamma | 0.71 | días |
| 10 | Estroncio-89 | Sr-89 | Beta | 50.5 | días |
| 11 | Fósforo-32 | P-32 | Beta | 14.3 | días |

---

### `GET /api/isotopes/{id}`

Obtiene un isótopo específico por ID.

**Respuesta `200`:** Objeto `Isotope`.

**Respuesta `404`:**
```json
{ "error": "Isotope not found" }
```

---

## Notas de implementación

- Utiliza directamente `IsotopeCatalogRepository`.
- La entidad `IsotopeCatalog` está en la tabla `isotope_catalogs`.
- El repositorio tiene la consulta: `findByName`.
- El catálogo se siembra en `DataLoader.java` con 11 isótopos.
- El frontend (`TreatmentForm.tsx`) usa este catálogo para el selector de isótopos al crear un tratamiento.
- La vida media (`halfLife`) se usa en `ConfinementCalculationService` para calcular `isolationDays = ceil(halfLife * 10)`.
