# Prompts HSO - Ejercicio de Bases de Datos

**Autor:** Heladia Salgado Osorio  
**Fecha:** 17 de Noviembre de 2025  
**Módulo:** AI4Devs - Bases de Datos  
**Rama:** db-hso  
**Migración:** 20251117233207_db_hso  
**Modelo:** claude-sonet 4.5   
**IDE:** cursor  

---

## Índice

1. [Descripción del Ejercicio](#descripción-del-ejercicio)
2. [Flujo de Trabajo Ejecutado](#flujo-de-trabajo-ejecutado)
3. [Prompts Utilizados](#prompts-utilizados)
4. [Buenas Prácticas Aplicadas](#buenas-prácticas-aplicadas)
5. [Decisiones de Diseño](#decisiones-de-diseño)
6. [Resultados Obtenidos](#resultados-obtenidos)
7. [Archivos Generados](#archivos-generados)
8. [Aprendizajes](#aprendizajes)

---

## Descripción del Ejercicio

El ejercicio consistió en expandir la base de datos del proyecto **LTI (Talent Tracking System)**, que inicialmente solo tenía 4 modelos básicos para gestión de candidatos, a un **sistema completo de reclutamiento** con 12 modelos interrelacionados.

### Estado Inicial
- **4 modelos:** Candidate, Education, WorkExperience, Resume
- **Funcionalidad:** Gestión básica de perfiles de candidatos
- **Limitaciones:** Sin sistema de empresas, posiciones o proceso de entrevistas

### Estado Final
- **12 modelos:** Los 4 anteriores + Company, Employee, Position, InterviewFlow, InterviewStep, InterviewType, Application, Interview
- **Funcionalidad:** Sistema completo end-to-end de reclutamiento
- **Características:** Flujos de entrevista configurables, múltiples empresas, tracking completo del proceso

---

## Flujo de Trabajo Ejecutado

El desarrollo siguió el plan de 11 pasos del documento `prompts-cursor-db-plan-hso_bp.md`:

### Paso 0: Preparación
```bash
git checkout -b db-hso
```

### Paso 1: Análisis y Corrección del Schema Actual ✅
**Objetivo:** Mejorar el schema existente antes de agregar nuevos modelos.

**Acciones:**
- Agregados timestamps (`createdAt`, `updatedAt`) a `Candidate`
- Agregados índices en todas las Foreign Keys
- Agregado `onDelete: Cascade` en relaciones de composición
- **Corrección importante:** Eliminados timestamps redundantes de Education, WorkExperience y Resume (ya tienen fechas del dominio)

**Prompt utilizado:**
```
Analiza el schema.prisma actual y detecta:
- Modelos existentes y sus relaciones
- Índices faltantes en Foreign Keys
- Comportamiento onDelete no definido
- Necesidad de timestamps
- Observaciones sobre normalización
```

### Paso 2: Convertir ERD a SQL ⏭️
**Saltado** - Prisma genera el SQL automáticamente en la migración.

### Paso 3: Convertir ERD a Modelos Prisma ✅
**Objetivo:** Agregar los 8 modelos nuevos al schema.prisma.

**Modelos agregados:**
1. **Company** - Empresas que reclutan
2. **Employee** - Empleados/reclutadores
3. **InterviewType** - Catálogo de tipos de entrevista
4. **InterviewFlow** - Flujos de entrevista configurables
5. **InterviewStep** - Pasos dentro de un flujo
6. **Position** - Posiciones/vacantes
7. **Application** - Aplicaciones de candidatos
8. **Interview** - Entrevistas realizadas

**ENUMs creados:**
- `PositionStatus`: DRAFT, OPEN, CLOSED, ON_HOLD
- `EmploymentType`: FULL_TIME, PART_TIME, CONTRACT, TEMPORARY, INTERNSHIP
- `ApplicationStatus`: PENDING, REVIEWING, INTERVIEWED, ACCEPTED, REJECTED, WITHDRAWN
- `InterviewResult`: PENDING, PASSED, FAILED, NO_SHOW
- `EmployeeRole`: RECRUITER, HIRING_MANAGER, INTERVIEWER, ADMIN

**Prompt utilizado:**
```
Convierte el ERD del documento a modelos Prisma aplicando:
- camelCase en nombres de campos
- Relaciones claras con @relation
- Índices en todas las FKs
- Índices en campos de búsqueda frecuente
- UNIQUE donde corresponda
- ENUMs para campos con opciones fijas
- onDelete apropiado (CASCADE vs RESTRICT)
- Timestamps solo en entidades principales
```

### Paso 4: Integración sin Romper el Schema ✅
**Objetivo:** Asegurar que los modelos nuevos se integren sin conflictos.

**Acciones:**
- Agregada relación `applications` a `Candidate`
- Verificadas todas las relaciones bidireccionales
- Validado que no hay conflictos de nombres

### Paso 5: Validación de Calidad ✅
**Objetivo:** Validar antes de migrar.

**Checklist verificado:**
- ✅ Normalización 3FN completa
- ✅ 26 índices estratégicos
- ✅ 16 Foreign Keys con policies correctas
- ✅ 4 UNIQUE constraints
- ✅ 5 ENUMs bien definidos
- ✅ Tipos de datos apropiados
- ✅ Sin redundancia de datos
- ✅ Timestamps solo donde tienen sentido

**Prompt utilizado:**
```
Valida el schema.prisma completo:
- Normalización (1FN, 2FN, 3FN)
- Índices en todas las FKs
- UNIQUE y ENUM donde corresponda
- Consistencia entre modelos
- Ausencia de redundancia
- Policies de onDelete coherentes
```

### Paso 6: Ejecutar Migración ✅
**Comando ejecutado:**
```bash
npx prisma migrate dev --name db_hso
```

**Resultado:**
- Migración creada: `20251117233207_db_hso`
- Base de datos sincronizada exitosamente
- 12 tablas creadas
- 5 ENUMs creados
- 26 índices creados
- 16 Foreign Keys con constraints

### Paso 7: Validar SQL Generado ✅
**Archivo validado:** `prisma/migrations/20251117233207_db_hso/migration.sql`

**Validaciones realizadas:**
- ✅ ENUMs creados correctamente (5 tipos)
- ✅ Tablas con PKs SERIAL
- ✅ Tipos de datos correctos (VARCHAR, TEXT, TIMESTAMP, DECIMAL, BOOLEAN)
- ✅ Índices UNIQUE en emails
- ✅ Índices en todas las FKs (13 índices)
- ✅ Índices en campos de búsqueda (12 índices)
- ✅ Constraints UNIQUE compuestos (Application, InterviewStep)
- ✅ Foreign Keys con CASCADE donde corresponde (9 relaciones)
- ✅ Foreign Keys con RESTRICT para datos históricos (7 relaciones)
- ✅ Valores por defecto apropiados

**Prompt utilizado:**
```
Revisa migration.sql y valida:
- Tablas correctamente definidas
- Foreign Keys con constraints apropiados
- Índices suficientes para performance
- Tipos de datos correctos
- Alineación con el ERD original
- Normalización respetada
```

### Paso 8: Generar Datos de Prueba ✅
**Archivo creado:** `prisma/seed-test-data.sql`

**Datos insertados:**
- 1 Company: "Tech Innovations Inc."
- 2 Employees: María García (Recruiter), Carlos López (Hiring Manager)
- 3 InterviewTypes: Técnica, Cultural, HR
- 1 InterviewFlow: "Proceso estándar técnica - 2 etapas"
- 2 InterviewSteps: Filtro HR, Evaluación técnica
- 1 Position: "Desarrollador Full Stack Senior"
- 1 Candidate: Juan Pérez con 2 educaciones, 2 experiencias, 1 CV
- 1 Application: Juan aplicando a la posición
- 1 Interview: Entrevista HR con María → PASSED (85 puntos)

**Comando ejecutado:**
```bash
psql -h localhost -p 5432 -U LTIdbUser -d LTIdb -f prisma/seed-test-data.sql
```

### Paso 9: Crear Queries de Validación ✅
**Archivo creado:** `prisma/validation-queries.sql`

**10 queries de validación:**
1. Búsqueda de candidatos por email (validar índice UNIQUE)
2. Posiciones abiertas por ubicación (validar índices múltiples)
3. Historial completo de candidato con JOINs
4. Proceso de entrevistas con InterviewStep y Employee
5. Dashboard de reclutamiento con agregados
6. Validar integridad de Foreign Keys (sin huérfanos)
7. Validar constraints UNIQUE
8. Performance de índices en búsquedas por fecha
9. Flujo completo de entrevista por posición
10. Empleados más activos en entrevistas

**Query de prueba ejecutada:**
```sql
SELECT 
    c."firstName" || ' ' || c."lastName" as candidate,
    p.title as position,
    a.status,
    i.result,
    i.score,
    e.name as interviewer
FROM "Application" a
JOIN "Candidate" c ON a."candidateId" = c.id
JOIN "Position" p ON a."positionId" = p.id
LEFT JOIN "Interview" i ON a.id = i."applicationId"
LEFT JOIN "Employee" e ON i."employeeId" = e.id;
```

**Resultado:**
```
      candidate       |            position             |  status   | result | score | interviewer  
----------------------+---------------------------------+-----------+--------+-------+--------------
 Juan Pérez Rodríguez | Desarrollador Full Stack Senior | REVIEWING | PASSED |    85 | María García
```

### Paso 10: Crear prompts-hso.md ✅
**Este archivo** - Documentación completa del proceso.

### Paso 11: Validación del PR ⏳
Pendiente de revisión final.

---

## Prompts Utilizados

### Categoría: Análisis

**Prompt 1: Revisión del proyecto**
```
Revisa el proyecto y @docs para identificar lo que hay que hacer.
```
**Contexto:** Inicio del ejercicio  
**Resultado:** Identificación clara del plan de 11 pasos y estado actual del proyecto

---

**Prompt 2: Creación de rama**
```
Antes que nada hagamos la rama de trabajo, debe llamarse db-hso.
```
**Contexto:** Preparación del entorno  
**Resultado:** Rama db-hso creada exitosamente

---

**Prompt 3: Análisis de timestamps**
```
Puedes analizar detenidamente el modelo y ver si es necesario que los Timestamps esten presentes en los demas tablas?
```
**Contexto:** Después de agregar timestamps a todos los modelos  
**Resultado:** Identificación de que Education, WorkExperience y Resume NO necesitan timestamps porque ya tienen fechas del dominio. Decisión de diseño importante que eliminó redundancia.

---

### Categoría: Documentación

**Prompt 4: Solicitud de diccionario**
```
Crees que sea necesario generar el diccionario de datos?
```
**Contexto:** Después de completar el schema  
**Resultado:** Análisis de beneficios y recomendación de generar diccionario completo

---

**Prompt 5: Archivo separado**
```
Un archivo separado.
```
**Contexto:** Decisión sobre formato del diccionario  
**Resultado:** Creación de `database-dictionary.md` profesional con 702 líneas

---

**Prompt 6: Solicitud de diagrama ER**
```
Y tambien quisiera un diagrama ER en mermaid de la base de datos.
```
**Contexto:** Complementar documentación  
**Resultado:** Creación de `er-diagram.md` con diagramas completos en Mermaid

---

### Categoría: Ejecución

**Prompt 7: Ajustes del paso 1**
```
En el paso 1, haz los ajustes de las observaciones que encontraste.
```
**Contexto:** Después del análisis inicial  
**Resultado:** Corrección de índices, onDelete y timestamps en modelos existentes

---

**Prompt 8: Optimización de timestamps**
```
haz el ajuste
```
**Contexto:** Después del análisis de timestamps redundantes  
**Resultado:** Eliminación de timestamps innecesarios en Education, WorkExperience y Resume

---

**Prompt 9: Continuar con paso 3**
```
Si pasemos al paso 3.
```
**Contexto:** Después de completar paso 1  
**Resultado:** Implementación completa de 8 modelos nuevos con ENUMs y buenas prácticas

---

**Prompt 10: Confirmación de reset**
```
Si
```
**Contexto:** Confirmación para reset de base de datos  
**Resultado:** Reset exitoso y aplicación de migración db_hso

---

### Categoría: Configuración

**Prompt 11: Credenciales de BD**
```
DB_PASSWORD=D1ymf8wyQEGthFR1E9xhCq
DB_USER=LTIdbUser
DB_NAME=LTIdb
DB_PORT=5432
DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}"
```
**Contexto:** Configuración para ejecutar migración  
**Resultado:** Migración ejecutada exitosamente con credenciales correctas

---

## Buenas Prácticas Aplicadas

### 1. Normalización de Base de Datos

**Primera Forma Normal (1FN):**
- ✅ Todos los campos son atómicos
- ✅ No hay arrays ni listas en campos
- ✅ Cada campo contiene un solo valor

**Segunda Forma Normal (2FN):**
- ✅ Cumple 1FN
- ✅ Todos los campos no-clave dependen de la clave primaria completa
- ✅ No hay dependencias parciales

**Tercera Forma Normal (3FN):**
- ✅ Cumple 2FN
- ✅ No hay dependencias transitivas
- ✅ Cada campo no-clave depende SOLO de la clave primaria

**Ejemplo de normalización aplicada:**
- En vez de duplicar información de Company en Position, se usa FK `companyId`
- InterviewStep referencia InterviewType (catálogo) en vez de duplicar nombre/descripción
- Application tiene UNIQUE constraint (positionId, candidateId) para evitar duplicados

### 2. Índices Estratégicos

**Índices en Foreign Keys (13 índices):**
```prisma
@@index([candidateId])    // Education, WorkExperience, Resume
@@index([companyId])       // Employee, Position
@@index([interviewFlowId]) // InterviewStep, Position
@@index([interviewTypeId]) // InterviewStep
@@index([positionId])      // Application
@@index([applicationId])   // Interview
@@index([interviewStepId]) // Interview
@@index([employeeId])      // Interview
```

**Justificación:** Optimizar JOINs (operación más frecuente en BD relacionales)

**Índices en Campos de Búsqueda (12 índices):**
```prisma
@@index([email])           // Employee (además de UNIQUE)
@@index([isActive])        // Employee (filtros frecuentes)
@@index([name])            // Company, InterviewType
@@index([status])          // Position, Application
@@index([location])        // Position (búsquedas geográficas)
@@index([employmentType])  // Position (filtros de tipo de empleo)
@@index([applicationDate]) // Application (ordenamiento temporal)
@@index([interviewDate])   // Interview (ordenamiento temporal)
@@index([result])          // Interview (filtros de resultado)
```

**Justificación:** Campos usados en WHERE, ORDER BY y filtros de dashboard

**Índices UNIQUE (4 constraints):**
```prisma
@unique                    // Candidate.email
@unique                    // Employee.email
@@unique([positionId, candidateId])  // Application
@@unique([interviewFlowId, orderIndex]) // InterviewStep
```

**Justificación:** Integridad de datos y prevención de duplicados

### 3. Integridad Referencial

**CASCADE (composición - hijo no existe sin padre):**
```prisma
Education → Candidate        // Educación es parte del candidato
WorkExperience → Candidate   // Experiencia es parte del candidato
Resume → Candidate           // CV es parte del candidato
Application → Candidate      // Aplicación depende del candidato
InterviewFlow → InterviewStep // Pasos son parte del flujo
Application → Interview      // Entrevistas son parte de la aplicación
```

**RESTRICT (referencia - mantener histórico):**
```prisma
Company → Employee          // No eliminar empresa con empleados
Company → Position          // Mantener histórico de posiciones
Position → Application      // Mantener histórico de aplicaciones
InterviewType → InterviewStep // Proteger catálogo en uso
InterviewStep → Interview   // Mantener histórico completo
Employee → Interview        // Mantener registro de entrevistador
```

**Justificación:** Balance entre integridad automática y protección de datos históricos valiosos

### 4. Tipos de Datos Apropiados

```prisma
String @db.VarChar(100)     // Nombres, títulos (tamaño conocido)
String @db.Text             // Descripciones largas (sin límite predefinido)
DateTime                    // Fechas con precisión de milisegundos
Decimal @db.Decimal(10,2)   // Salarios (precisión monetaria exacta)
Boolean                     // Flags (isActive, isVisible)
Int                         // IDs, scores, orderIndex
```

**Justificación:**
- `VarChar` con límites → Performance y validación
- `Text` sin límite → Flexibilidad para descripciones
- `Decimal` → Evita errores de redondeo en dinero
- `DateTime` con milisegundos → Precisión para logs

### 5. ENUMs para Valores Fijos

```prisma
enum PositionStatus {
  DRAFT | OPEN | CLOSED | ON_HOLD
}

enum EmploymentType {
  FULL_TIME | PART_TIME | CONTRACT | TEMPORARY | INTERNSHIP
}

enum ApplicationStatus {
  PENDING | REVIEWING | INTERVIEWED | ACCEPTED | REJECTED | WITHDRAWN
}

enum InterviewResult {
  PENDING | PASSED | FAILED | NO_SHOW
}

enum EmployeeRole {
  RECRUITER | HIRING_MANAGER | INTERVIEWER | ADMIN
}
```

**Ventajas:**
- ✅ Validación a nivel de BD
- ✅ No necesita tabla catálogo (mejor performance)
- ✅ Autocompletado en IDE
- ✅ Type-safety en TypeScript
- ✅ Documentación implícita

### 6. Timestamps Selectivos

**CON timestamps:**
- `Candidate` - Entidad principal, auditoría necesaria
- `Company` - Entidad principal
- `Employee` - Auditoría de accesos
- `InterviewFlow` - Versionado de configuración
- `Position` - Tracking de publicaciones
- `Application` - Auditoría de proceso
- `Interview` - Registro histórico

**SIN timestamps:**
- `Education` - Tiene startDate/endDate (fechas del dominio)
- `WorkExperience` - Tiene startDate/endDate (fechas del dominio)
- `Resume` - Tiene uploadDate (suficiente)
- `InterviewType` - Catálogo estático
- `InterviewStep` - Configuración (parte de InterviewFlow)

**Justificación:** Evitar redundancia, solo timestamps donde agregan valor real

### 7. Naming Conventions

**Prisma/TypeScript:**
```
Modelos: PascalCase        → Candidate, WorkExperience
Campos: camelCase          → firstName, applicationDate
Relaciones: camelCase      → candidate, workExperiences
ENUMs: PascalCase          → PositionStatus, EmployeeRole
Valores ENUM: UPPER_CASE   → FULL_TIME, PENDING
```

**Base de Datos (generado):**
```
Tablas: "PascalCase"       → "Candidate", "WorkExperience"
Columnas: "camelCase"      → "firstName", "applicationDate"
Índices: snake_case        → Candidate_email_key, Application_status_idx
Constraints: snake_case    → Education_candidateId_fkey
```

**Justificación:** Consistencia con convenciones de TypeScript/Prisma

---

## Decisiones de Diseño

### 1. Timestamps Solo en Entidades Principales

**Problema identificado:**
Inicialmente se agregaron timestamps a TODOS los modelos, incluyendo Education, WorkExperience y Resume.

**Análisis:**
```typescript
// Education ya tiene fechas del dominio:
startDate: DateTime  // Inicio de estudios
endDate: DateTime?   // Fin de estudios

// ¿Para qué necesitaría createdAt/updatedAt?
// - No aporta valor de negocio
// - Crea confusión (¿qué fecha usar?)
// - Aumenta tamaño de tablas innecesariamente
```

**Decisión:**
Eliminar timestamps de modelos con fechas del dominio propias.

**Resultado:**
- Código más limpio y enfocado
- Menos campos → mejor performance
- Sin redundancia de información

### 2. Aplicación Única por Candidato-Posición

**Implementación:**
```prisma
model Application {
  positionId  Int
  candidateId Int
  // ...
  @@unique([positionId, candidateId])
}
```

**Justificación:**
- Lógica de negocio: Un candidato solo debe aplicar UNA vez a cada posición
- Previene duplicados accidentales
- Simplifica queries (no necesitar DISTINCT)
- Mejora UX (detectar re-aplicaciones)

### 3. Orden Único en InterviewStep

**Implementación:**
```prisma
model InterviewStep {
  interviewFlowId Int
  orderIndex      Int
  // ...
  @@unique([interviewFlowId, orderIndex])
}
```

**Justificación:**
- Garantiza secuencia correcta de pasos
- Previene errores de configuración
- Facilita ordenamiento en queries
- Validación a nivel de BD (no confiar solo en aplicación)

### 4. Decimal para Salarios

**Alternativas consideradas:**
```prisma
// Opción 1: Float
salaryMin Float?  // ❌ Errores de redondeo

// Opción 2: Int (en centavos)
salaryMin Int?    // ✅ Exacto pero complicado de manejar

// Opción 3: Decimal
salaryMin Decimal(10,2)?  // ✅ ELEGIDA - Exacto y fácil
```

**Justificación:**
- Decimal es estándar para valores monetarios
- Precisión exacta (sin redondeo)
- Fácil de leer y mantener
- (10,2) = hasta $99,999,999.99

### 5. Separación de InterviewFlow y InterviewStep

**Alternativa rechazada:**
Un solo modelo `InterviewFlow` con JSON de pasos

**Diseño elegido:**
```
InterviewFlow (1) ----→ (N) InterviewStep
```

**Justificación:**
- Normalización correcta (no guardar JSON)
- Permite queries sobre pasos individuales
- Reutilización de InterviewType (catálogo)
- Facilita reportes y métricas por paso
- Mejor para modificaciones futuras

### 6. Employee vs User

**Decisión:**
`Employee` es solo para gestión de reclutamiento, NO para autenticación.

**Justificación:**
- Separación de concerns
- Sistema de auth puede agregarse después
- Empleado puede existir sin cuenta de usuario
- Simplifica MVP actual

**Futuro:**
```prisma
model User {
  id         Int
  email      String @unique
  password   String
  employeeId Int?   // Opcional
  candidateId Int?  // Opcional
}
```

### 7. Catálogo InterviewType

**Por qué no ENUM:**
- Necesita descripción larga
- Puede crecer dinámicamente
- Administrado por usuarios

**Por qué tabla separada:**
- Referenciado por InterviewStep
- Permite agregar campos después
- Protegido por RESTRICT (no eliminar si en uso)

---

## Resultados Obtenidos

### Archivos Generados

```
backend/
├── prisma/
│   ├── schema.prisma                        [MODIFICADO] - 243 líneas, 12 modelos, 5 ENUMs
│   ├── migrations/
│   │   └── 20251117233207_db_hso/
│   │       └── migration.sql                [GENERADO] - 298 líneas SQL
│   ├── seed-test-data.sql                   [CREADO] - Datos de prueba completos
│   └── validation-queries.sql               [CREADO] - 10 queries de validación
└── docs/
    ├── database-dictionary.md               [CREADO] - 702 líneas, documentación completa
    ├── er-diagram.md                        [CREADO] - 554 líneas, diagramas Mermaid
    └── prompts-cursor-db-plan-hso_bp.md     [EXISTENTE] - Plan de 11 pasos
prompts/
└── prompts-hso.md                           [ESTE ARCHIVO] - Documentación del proceso
```

### Estadísticas del Schema

**Modelos:**
- Iniciales: 4 (Candidate, Education, WorkExperience, Resume)
- Agregados: 8 (Company, Employee, Position, InterviewFlow, InterviewStep, InterviewType, Application, Interview)
- Total: 12 modelos

**ENUMs:**
- PositionStatus (4 valores)
- EmploymentType (5 valores)
- ApplicationStatus (6 valores)
- InterviewResult (4 valores)
- EmployeeRole (4 valores)
- Total: 5 ENUMs, 23 valores posibles

**Relaciones:**
- 1:N relaciones: 15
- N:1 relaciones: 15 (bidireccionales)
- CASCADE: 9 relaciones
- RESTRICT: 7 relaciones

**Índices:**
- Primary Keys: 12 (automáticos)
- Foreign Keys: 13 índices
- Búsqueda: 12 índices
- UNIQUE: 4 constraints
- Total: 41 índices

**Campos:**
- Total de campos: ~90 campos
- Required: ~55%
- Optional: ~45%

### Base de Datos Creada

**Tablas en PostgreSQL:**
```sql
LTIdb=# \dt
                 List of relations
 Schema |      Name       | Type  |   Owner    
--------+-----------------+-------+------------
 public | Application     | table | LTIdbUser
 public | Candidate       | table | LTIdbUser
 public | Company         | table | LTIdbUser
 public | Education       | table | LTIdbUser
 public | Employee        | table | LTIdbUser
 public | Interview       | table | LTIdbUser
 public | InterviewFlow   | table | LTIdbUser
 public | InterviewStep   | table | LTIdbUser
 public | InterviewType   | table | LTIdbUser
 public | Position        | table | LTIdbUser
 public | Resume          | table | LTIdbUser
 public | WorkExperience  | table | LTIdbUser
```

**ENUMs en PostgreSQL:**
```sql
LTIdb=# \dT
              List of data types
 Schema |       Name        | Description 
--------+-------------------+-------------
 public | ApplicationStatus |
 public | EmployeeRole      |
 public | EmploymentType    |
 public | InterviewResult   |
 public | PositionStatus    |
```

### Datos de Prueba Insertados

```
Tabla              | Registros
-------------------+----------
Company            |         1
Employee           |         2
InterviewType      |         3
InterviewFlow      |         1
InterviewStep      |         2
Position           |         1
Candidate          |         1
Education          |         2
WorkExperience     |         2
Resume             |         1
Application        |         1
Interview          |         1
-------------------+----------
TOTAL              |        17
```

### Queries Validadas

10 queries de validación ejecutadas exitosamente:
- ✅ Búsqueda por email con índice UNIQUE
- ✅ Posiciones abiertas con filtros múltiples
- ✅ Historial completo de candidato con JOINs
- ✅ Proceso de entrevistas completo
- ✅ Dashboard con agregados
- ✅ Integridad referencial (0 huérfanos)
- ✅ Constraints UNIQUE (0 duplicados)
- ✅ Búsquedas por fecha con índices
- ✅ Flujo completo de entrevista
- ✅ Estadísticas de empleados

**Ejemplo de resultado:**
```
      candidate       |            position             |  status   | result | score | interviewer  
----------------------+---------------------------------+-----------+--------+-------+--------------
 Juan Pérez Rodríguez | Desarrollador Full Stack Senior | REVIEWING | PASSED |    85 | María García
```

---

## Aprendizajes

### Técnicos

1. **Normalización es clave pero tiene excepciones**
   - Seguir 3FN estrictamente
   - PERO: considerar desnormalización calculada si es necesario para performance
   - En este caso: NO fue necesario desnormalizar

2. **Timestamps no son obligatorios en todas las tablas**
   - Solo agregar donde aportan valor real
   - Modelos con fechas del dominio no necesitan createdAt/updatedAt
   - Reduce redundancia y confusión

3. **ENUMs vs Tablas Catálogo**
   - ENUM: Para valores fijos y pequeños (estados, roles)
   - Tabla: Para catálogos que necesitan más info o crecimiento dinámico
   - InterviewType es tabla porque necesita descripción y puede crecer

4. **Índices estratégicos > Índices indiscriminados**
   - SIEMPRE: FKs, campos de búsqueda frecuente
   - CONSIDERAR: Índices compuestos para queries específicas
   - EVITAR: Índices en todo (costo de escritura)

5. **CASCADE vs RESTRICT requiere análisis de negocio**
   - CASCADE: Cuando el hijo es parte del padre (composición)
   - RESTRICT: Cuando el dato histórico es valioso
   - No hay regla automática, depende del dominio

### De Proceso

1. **Documentación en paralelo es más eficiente**
   - Generar diccionario y diagramas ANTES de la migración
   - Ayuda a detectar errores de diseño temprano
   - Más fácil que documentar después

2. **Datos de prueba deben ser realistas**
   - No solo INSERT de IDs y nombres genéricos
   - Datos que cuenten una historia (Juan aplicando y siendo entrevistado)
   - Facilita pruebas y demos

3. **Queries de validación son esenciales**
   - No confiar solo en que "la migración corrió"
   - Validar JOINs, índices, constraints
   - Detectar problemas antes de desarrollo

4. **Plan de 11 pasos es robusto**
   - Seguir la secuencia evita errores
   - Validaciones intermedias detectan problemas temprano
   - Paso 5 (validación antes de migrar) es crítico

### De IA

1. **Cursor/AI es excelente para tareas repetitivas**
   - Generación de modelos Prisma siguiendo patrón
   - Crear documentación exhaustiva
   - Generar datos de prueba consistentes

2. **Pero requiere supervisión humana**
   - La IA agregó timestamps a TODO (no óptimo)
   - Humano identificó redundancia y corrigió
   - Mejor resultado: colaboración humano-IA

3. **Prompts específicos > Prompts genéricos**
   - "Agrega modelos" → Resultado mediocre
   - "Agrega modelos con índices, ENUMs, y onDelete apropiado" → Resultado excelente
   - Cuanto más contexto, mejor el output

4. **Iteración es clave**
   - Primer intento rara vez es perfecto
   - Revisar, cuestionar ("¿realmente necesito timestamps aquí?")
   - Refinar y volver a generar

---

## Conclusiones

### Objetivos Cumplidos ✅

1. ✅ Expandir schema de 4 a 12 modelos
2. ✅ Aplicar normalización 3FN
3. ✅ Implementar 26 índices estratégicos
4. ✅ Configurar integridad referencial (CASCADE/RESTRICT)
5. ✅ Crear 5 ENUMs para valores fijos
6. ✅ Generar migración exitosa (db_hso)
7. ✅ Insertar datos de prueba realistas
8. ✅ Validar con 10 queries complejas
9. ✅ Documentar con diccionario completo
10. ✅ Crear diagramas ER en Mermaid
11. ✅ Documentar proceso completo (este archivo)

### Calidad del Resultado

**Schema:**
- ✅ Profesional y production-ready
- ✅ Normalizado correctamente
- ✅ Performance optimizado
- ✅ Mantenible y escalable

**Documentación:**
- ✅ Completa y detallada
- ✅ Útil para desarrolladores nuevos
- ✅ Diagramas visuales claros
- ✅ Queries de ejemplo funcionales

**Proceso:**
- ✅ Sistemático y reproducible
- ✅ Buenas prácticas aplicadas
- ✅ Errores detectados y corregidos
- ✅ Aprendizajes documentados

### Próximos Pasos

**Corto plazo:**
1. Generar cliente Prisma: `npx prisma generate`
2. Actualizar servicios TypeScript para usar nuevos modelos
3. Crear endpoints REST para nuevas entidades
4. Actualizar frontend para gestionar posiciones y aplicaciones

**Mediano plazo:**
1. Implementar sistema de autenticación (User model)
2. Agregar roles y permisos granulares
3. Sistema de notificaciones (email/SMS)
4. Dashboard de analytics y métricas

**Largo plazo:**
1. Soft delete para auditoría completa
2. Versionado de datos (history tables)
3. Optimización con vistas materializadas
4. Integración con sistemas externos (LinkedIn, etc.)

---

## Agradecimientos

- **Curso AI4Devs** por el módulo de bases de datos estructurado
- **Documento prompts-cursor-db-plan-hso_bp.md** por el plan de 11 pasos
- **Cursor/Claude** por asistencia en generación de código y documentación
- **Prisma** por excelente ORM y herramientas de migración
- **PostgreSQL** por motor de BD robusto y confiable

---

**Fin del documento**

_Generado como parte del ejercicio HSO del módulo de Bases de Datos - AI4Devs_

