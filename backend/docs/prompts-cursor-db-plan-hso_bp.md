# Prompts para Cursor con Roles/Expertise (versión HSO + Buenas Prácticas de Bases de Datos)

Este archivo incluye **todos los prompts**, **roles recomendados**, y ahora **las buenas prácticas de bases de datos** que deben aplicarse durante todo el proceso:  
- Normalización (1FN, 2FN, 3FN, BCNF cuando aplique)  
- Índices obligatorios (FKs, campos de búsqueda, UNIQUE)  
- Tipos de datos adecuados  
- Integridad referencial (ACID)  
- Diseño escalable y mantenible  
- Validación en PGAdmin  
- Análisis de rendimiento básico  

---

## 1. Analizar schema.prisma actual  
**Role/Expertise:** *Experto en Prisma y arquitectura de BD + normalización*  

```
Analiza el archivo backend/prisma/schema.prisma de este proyecto.
Quiero saber:
- modelos existentes,
- relaciones,
- claves primarias,
- claves foráneas,
- índices,
- si cumple normalización mínima (1FN, 2FN, 3FN),
- riesgos de duplicación o dependencias incorrectas.
- y qué consideraciones debo tener en cuenta para expandir la base de datos con nuevos modelos sin romper lo existente. 

NO modifiques nada todavía.

MODELO EPR actual

erDiagram
     COMPANY {
         int id PK
         string name
     }
     EMPLOYEE {
         int id PK
         int company_id FK
         string name
         string email
         string role
         boolean is_active
     }
     POSITION {
         int id PK
         int company_id FK
         int interview_flow_id FK
         string title
         text description
         string status
         boolean is_visible
         string location
         text job_description
         text requirements
         text responsibilities
         numeric salary_min
         numeric salary_max
         string employment_type
         text benefits
         text company_description
         date application_deadline
         string contact_info
     }
     INTERVIEW_FLOW {
         int id PK
         string description
     }
     INTERVIEW_STEP {
         int id PK
         int interview_flow_id FK
         int interview_type_id FK
         string name
         int order_index
     }
     INTERVIEW_TYPE {
         int id PK
         string name
         text description
     }
     CANDIDATE {
         int id PK
         string firstName
         string lastName
         string email
         string phone
         string address
     }
     APPLICATION {
         int id PK
         int position_id FK
         int candidate_id FK
         date application_date
         string status
         text notes
     }
     INTERVIEW {
         int id PK
         int application_id FK
         int interview_step_id FK
         int employee_id FK
         date interview_date
         string result
         int score
         text notes
     }

     COMPANY ||--o{ EMPLOYEE : employs
     COMPANY ||--o{ POSITION : offers
     POSITION ||--|| INTERVIEW_FLOW : assigns
     INTERVIEW_FLOW ||--o{ INTERVIEW_STEP : contains
     INTERVIEW_STEP ||--|| INTERVIEW_TYPE : uses
     POSITION ||--o{ APPLICATION : receives
     CANDIDATE ||--o{ APPLICATION : submits
     APPLICATION ||--o{ INTERVIEW : has
     INTERVIEW ||--|| INTERVIEW_STEP : consists_of
     EMPLOYEE ||--o{ INTERVIEW : conducts
```

---

## 2. Convertir ERD a SQL  
**Role/Expertise:** *DBA experto en PostgreSQL y diseño relacional*  

**Buenas prácticas que deben aplicarse en SQL:**  
- Todas las tablas normalizadas a 3FN  
- PK y FK explícitas  
- `ON DELETE RESTRICT` o `CASCADE` según corresponda  
- Índices obligatorios en todas las FKs  
- Índices en campos de búsqueda (`email`, `status`, `location`, etc.)  
- Tipos adecuados (`numeric`, `text`, `date`, `boolean`)  

```
Convierte este ERD a SQL PostgreSQL aplicando buenas prácticas:
- Normalización (1FN–3FN)
- Claves primarias y foráneas correctas
- Índices en FKs
- Índices en campos muy consultados
- Tipos adecuados
- Nada de redundancia de datos

Aquí está el ERD:


```

---

## 3. Convertir ERD a modelos Prisma  
**Role/Expertise:** *Experto en Prisma ORM y estructuras normalizadas*  

**Buenas prácticas a aplicar:**  
- camelCase  
- Relaciones claras con `@relation`  
- Índices:  
  - `@@index([fk])`  
  - `@@unique([email])`  
- Uso de ENUM cuando el campo tiene opciones fijas  
- Diseños sin duplicación (normalización)  

```
Convierte el siguiente ERD a modelos Prisma aplicando buenas prácticas:
- Normalización
- Relaciones claras
- Índices recomendados
- UNIQUE donde aplique
- Tipos adecuados
- Sin romper modelos existentes

Aquí va el ERD:
[PEGA AQUÍ EL ERD COMPLETO]
```

---

## 4. Integrar modelos nuevos sin romper el esquema actual  
**Role/Expertise:** *Arquitecto de software + experto en BD relacionales*  

**Buenas prácticas a validar:**  
- Eliminar redundancias  
- Revisar dependencias funcionales  
- Verificar que los nuevos modelos NO dupliquen información  
- Validar que todas las relaciones están correctamente justificadas  

```
Aquí está mi schema.prisma actual.
Necesito que:
- Integres los modelos nuevos,
- Mantengas normalización 3FN,
- Añadas índices en FKs y campos de búsqueda,
- Evites duplicación de datos,
- Señales conflictos de diseño,
- Sigas naming conventions del repo.

NO generes migraciones todavía.
Este es mi schema.prisma:
[PEGA AQUÍ TU schema.prisma]
```

---

## 5. Validación de calidad antes de migrar  
**Role/Expertise:** *Especialista en calidad de bases de datos + modelado*  

Checklist obligatorio:  
- Normalización cumplida  
- Índices aplicados  
- FK correctas  
- Constraints adecuados  
- Performance predecible  
- Campos atómicos (1FN)  

```
Valida el schema.prisma con las siguientes reglas:
- Normalización completa (1FN, 2FN, 3FN)
- Índices en todas las FKs
- UNIQUE y ENUM donde corresponda
- Consistencia entre modelo y ERD
- Ausencia de redundancia

Señala errores antes de migrar.
```

---

## 6. Ejecutar migración  
**Role/Expertise:** *Ingeniero backend con foco en estabilidad de BD*  

```
npx prisma migrate dev --name db_hso
```

---

## 7. Validación del SQL generado  
**Role/Expertise:** *DBA PostgreSQL/optimizer*  

**Revisar:**  
- Índices creados  
- Constraints correctas  
- Tipos correctos  
- Coherencia con el ERD  
- Ausencia de redundancia  
- Normalización respetada  

```
Revisa migration.sql y dime:
- Si las tablas están correctas
- Si FKs están bien definidas
- Si se crearon índices suficientes
- Si hay algún problema de rendimiento potencial
- Si está alineado al ERD
```

---

## 8. Generación de datos de prueba  
**Role/Expertise:** *Analista SQL + calidad de datos*  

**Buenas prácticas:**  
- Datos consistentes  
- Claves correctas  
- Evitar violar constraints  

```
Genera inserts SQL para pruebas mínimas:
- 1 Company
- 2 Employees
- 1 Position
- 1 Candidate
- 1 Application
- 1 InterviewFlow
- 2 InterviewStep
- 1 Interview
```

---

## 9. Queries de validación  
**Role/Expertise:** *Analista SQL de rendimiento*  

**Objetivo:** validar integridad, índices y joins.  

```
Genera 5 queries SQL para validar:
- Búsquedas usando índices
- Joins correctos
- Relación Candidate–Application–Position
- Relación Interview–InterviewStep–Employee
- Conteos agregados
```

---

## 10. prompts-hso.md  
**Role/Expertise:** *Documentador técnico + experto en flujos IA*  

Debe incluir:  
- Prompts usados  
- Buenas prácticas aplicadas  
- Resumen del flujo  

```
Genera el archivo prompts-hso.md con:
- Todos los prompts utilizados
- Cómo usé la IA
- Qué buenas prácticas se aplicaron
- Flujo del ejercicio
```

---

## 11. Validación del PR  
**Role/Expertise:** *Ingeniero de release*  

Checklist estricto:  
- `schema.prisma` actualizado  
- Carpeta `migrations/db_hso`  
- Archivo `prompts-hso.md`  
- Nada más cambiado  

```
Revisa que mi PR incluya solo:
- schema.prisma
- carpeta backend/prisma/migrations/<timestamp>_db_hso
- prompts/prompts-hso.md

Indica si algo sobra o falta.
```

---

✔ Archivo totalmente actualizado  
✔ Incluye todas las buenas prácticas del módulo  
✔ Uso listo para Cursor y entregables HSO  

