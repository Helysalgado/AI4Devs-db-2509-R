# Diccionario de Datos - LTI Talent Tracking System

**Versión:** 1.0  
**Fecha:** Noviembre 2025  
**Base de Datos:** PostgreSQL  
**ORM:** Prisma

---

## Índice

1. [Descripción General](#descripción-general)
2. [Convenciones y Estándares](#convenciones-y-estándares)
3. [ENUMs del Sistema](#enums-del-sistema)
4. [Tablas del Sistema](#tablas-del-sistema)
5. [Relaciones entre Tablas](#relaciones-entre-tablas)
6. [Índices y Performance](#índices-y-performance)
7. [Decisiones de Diseño](#decisiones-de-diseño)

---

## Descripción General

El sistema LTI (Talent Tracking System) es una plataforma completa de gestión de reclutamiento que permite a las empresas:

- Gestionar candidatos y sus perfiles profesionales
- Publicar y administrar posiciones vacantes
- Procesar aplicaciones de candidatos
- Configurar flujos de entrevista personalizados
- Realizar seguimiento completo del proceso de selección
- Gestionar equipos de reclutamiento

El sistema está normalizado a **Tercera Forma Normal (3FN)** y sigue las mejores prácticas de diseño de bases de datos relacionales.

---

## Convenciones y Estándares

### Nomenclatura
- **Modelos:** PascalCase (ej: `Candidate`, `WorkExperience`)
- **Campos:** camelCase (ej: `firstName`, `applicationDate`)
- **ENUMs:** PascalCase para el tipo, UPPER_CASE para valores
- **Relaciones:** Nombres descriptivos en plural cuando es 1:N

### Claves
- **Primary Keys:** Campo `id` autoincremental en todas las tablas
- **Foreign Keys:** Nombradas con sufijo `Id` (ej: `candidateId`, `companyId`)
- **Índices:** Creados en todas las FKs y campos de búsqueda frecuente

### Timestamps
- **Criterio:** Solo en entidades principales del negocio
- **Campos:** `createdAt` y `updatedAt`
- **Excepción:** Tablas con fechas del dominio propias (Education, WorkExperience)

### Integridad Referencial
- **CASCADE:** Usado para relaciones de composición (hijo no existe sin padre)
- **RESTRICT:** Usado para relaciones de referencia (proteger datos históricos)

---

## ENUMs del Sistema

### PositionStatus
Estado de una posición vacante.

| Valor | Descripción |
|-------|-------------|
| `DRAFT` | Posición en borrador, no publicada |
| `OPEN` | Posición abierta y activa para aplicaciones |
| `CLOSED` | Posición cerrada, no acepta más aplicaciones |
| `ON_HOLD` | Posición pausada temporalmente |

### EmploymentType
Tipo de contratación ofrecida.

| Valor | Descripción |
|-------|-------------|
| `FULL_TIME` | Tiempo completo |
| `PART_TIME` | Medio tiempo |
| `CONTRACT` | Contrato temporal |
| `TEMPORARY` | Posición temporal |
| `INTERNSHIP` | Pasantía o internship |

### ApplicationStatus
Estado del proceso de aplicación de un candidato.

| Valor | Descripción |
|-------|-------------|
| `PENDING` | Aplicación recibida, pendiente de revisión |
| `REVIEWING` | En proceso de revisión |
| `INTERVIEWED` | Candidato ya fue entrevistado |
| `ACCEPTED` | Candidato aceptado para la posición |
| `REJECTED` | Candidato rechazado |
| `WITHDRAWN` | Candidato retiró su aplicación |

### InterviewResult
Resultado de una entrevista individual.

| Valor | Descripción |
|-------|-------------|
| `PENDING` | Entrevista pendiente o sin resultado aún |
| `PASSED` | Candidato aprobó la entrevista |
| `FAILED` | Candidato no aprobó la entrevista |
| `NO_SHOW` | Candidato no se presentó |

### EmployeeRole
Rol de un empleado en el sistema.

| Valor | Descripción |
|-------|-------------|
| `RECRUITER` | Reclutador, gestiona el proceso |
| `HIRING_MANAGER` | Manager que toma decisión final |
| `INTERVIEWER` | Entrevistador técnico o funcional |
| `ADMIN` | Administrador del sistema |

---

## Tablas del Sistema

### 1. Candidate
Información de candidatos que aplican a posiciones.

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `firstName` | VarChar(100) | NOT NULL | Nombre del candidato |
| `lastName` | VarChar(100) | NOT NULL | Apellido del candidato |
| `email` | VarChar(255) | NOT NULL, UNIQUE | Email único del candidato |
| `phone` | VarChar(15) | NULL | Teléfono de contacto |
| `address` | VarChar(100) | NULL | Dirección del candidato |
| `createdAt` | DateTime | NOT NULL, DEFAULT NOW | Fecha de registro en el sistema |
| `updatedAt` | DateTime | NOT NULL, AUTO | Última actualización del perfil |

**Relaciones:**
- 1:N con `Education` (un candidato tiene múltiples estudios)
- 1:N con `WorkExperience` (un candidato tiene múltiple experiencia)
- 1:N con `Resume` (un candidato puede tener múltiples CVs)
- 1:N con `Application` (un candidato puede aplicar a múltiples posiciones)

**Índices:**
- `email` (UNIQUE index)

**Decisión de diseño:**
- `createdAt/updatedAt` incluidos porque es entidad principal del dominio
- `email` es UNIQUE para evitar duplicados

---

### 2. Education
Historial educativo de un candidato.

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `institution` | VarChar(100) | NOT NULL | Nombre de la institución educativa |
| `title` | VarChar(250) | NOT NULL | Título o grado obtenido |
| `startDate` | DateTime | NOT NULL | Fecha de inicio de estudios |
| `endDate` | DateTime | NULL | Fecha de finalización (NULL si en curso) |
| `candidateId` | Integer | FK, NOT NULL | Referencia al candidato |

**Relaciones:**
- N:1 con `Candidate` (onDelete: CASCADE)

**Índices:**
- `candidateId` (FK index)

**Decisión de diseño:**
- Sin timestamps porque `startDate/endDate` son las fechas relevantes del dominio
- CASCADE: Si se elimina el candidato, se elimina su educación

---

### 3. WorkExperience
Experiencia laboral de un candidato.

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `company` | VarChar(100) | NOT NULL | Nombre de la empresa |
| `position` | VarChar(100) | NOT NULL | Cargo o posición ocupada |
| `description` | VarChar(200) | NULL | Descripción de responsabilidades |
| `startDate` | DateTime | NOT NULL | Fecha de inicio |
| `endDate` | DateTime | NULL | Fecha de fin (NULL si empleo actual) |
| `candidateId` | Integer | FK, NOT NULL | Referencia al candidato |

**Relaciones:**
- N:1 con `Candidate` (onDelete: CASCADE)

**Índices:**
- `candidateId` (FK index)

**Decisión de diseño:**
- Sin timestamps porque `startDate/endDate` son las fechas relevantes del dominio
- CASCADE: Si se elimina el candidato, se elimina su experiencia

---

### 4. Resume
Archivos de CV/Resume de candidatos.

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `filePath` | VarChar(500) | NOT NULL | Ruta del archivo en el sistema |
| `fileType` | VarChar(50) | NOT NULL | Tipo MIME del archivo (pdf, docx, etc.) |
| `uploadDate` | DateTime | NOT NULL | Fecha de subida del archivo |
| `candidateId` | Integer | FK, NOT NULL | Referencia al candidato |

**Relaciones:**
- N:1 con `Candidate` (onDelete: CASCADE)

**Índices:**
- `candidateId` (FK index)

**Decisión de diseño:**
- Sin timestamps porque `uploadDate` es suficiente
- Permite múltiples versiones de CV por candidato
- CASCADE: Si se elimina el candidato, se eliminan sus CVs

---

### 5. Company
Empresas que utilizan el sistema para reclutar.

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `name` | VarChar(200) | NOT NULL | Nombre de la empresa |
| `createdAt` | DateTime | NOT NULL, DEFAULT NOW | Fecha de registro |
| `updatedAt` | DateTime | NOT NULL, AUTO | Última actualización |

**Relaciones:**
- 1:N con `Employee` (una empresa tiene múltiples empleados)
- 1:N con `Position` (una empresa publica múltiples posiciones)

**Índices:**
- `name` (búsquedas por nombre)

**Decisión de diseño:**
- Modelo simple, puede expandirse con más información corporativa
- Timestamps incluidos porque es entidad principal

---

### 6. Employee
Empleados de las empresas que participan en el proceso de reclutamiento.

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `companyId` | Integer | FK, NOT NULL | Referencia a la empresa |
| `name` | VarChar(200) | NOT NULL | Nombre del empleado |
| `email` | VarChar(255) | NOT NULL, UNIQUE | Email único del empleado |
| `role` | EmployeeRole | NOT NULL | Rol en el proceso de reclutamiento |
| `isActive` | Boolean | NOT NULL, DEFAULT TRUE | Estado activo/inactivo |
| `createdAt` | DateTime | NOT NULL, DEFAULT NOW | Fecha de registro |
| `updatedAt` | DateTime | NOT NULL, AUTO | Última actualización |

**Relaciones:**
- N:1 con `Company` (onDelete: RESTRICT)
- 1:N con `Interview` (un empleado realiza múltiples entrevistas)

**Índices:**
- `companyId` (FK index)
- `email` (UNIQUE index)
- `isActive` (filtros frecuentes)

**Decisión de diseño:**
- RESTRICT en company: No permitir eliminar empresa con empleados
- RESTRICT en interviews: Mantener histórico de quién entrevistó

---

### 7. InterviewType
Catálogo de tipos de entrevista (técnica, cultural, HR, etc.).

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `name` | VarChar(100) | NOT NULL | Nombre del tipo de entrevista |
| `description` | Text | NULL | Descripción detallada |

**Relaciones:**
- 1:N con `InterviewStep` (un tipo puede usarse en múltiples pasos)

**Índices:**
- `name` (búsquedas por nombre)

**Decisión de diseño:**
- Sin timestamps: Es un catálogo/configuración
- RESTRICT en InterviewStep: No eliminar tipos en uso

---

### 8. InterviewFlow
Flujos de entrevista configurables (secuencia de pasos de selección).

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `description` | VarChar(500) | NOT NULL | Descripción del flujo |
| `createdAt` | DateTime | NOT NULL, DEFAULT NOW | Fecha de creación |
| `updatedAt` | DateTime | NOT NULL, AUTO | Última actualización |

**Relaciones:**
- 1:N con `Position` (un flujo puede asignarse a múltiples posiciones)
- 1:N con `InterviewStep` (un flujo tiene múltiples pasos)

**Índices:**
- Ninguno adicional (búsquedas poco frecuentes)

**Decisión de diseño:**
- Permite reutilizar flujos entre posiciones similares
- CASCADE en InterviewStep: Si se elimina flujo, se eliminan sus pasos

---

### 9. InterviewStep
Pasos individuales dentro de un flujo de entrevista.

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `interviewFlowId` | Integer | FK, NOT NULL | Referencia al flujo |
| `interviewTypeId` | Integer | FK, NOT NULL | Referencia al tipo de entrevista |
| `name` | VarChar(200) | NOT NULL | Nombre del paso |
| `orderIndex` | Integer | NOT NULL | Orden del paso en el flujo |

**Relaciones:**
- N:1 con `InterviewFlow` (onDelete: CASCADE)
- N:1 con `InterviewType` (onDelete: RESTRICT)
- 1:N con `Interview` (un paso puede tener múltiples entrevistas)

**Índices:**
- `interviewFlowId` (FK index)
- `interviewTypeId` (FK index)
- `(interviewFlowId, orderIndex)` (UNIQUE - orden único por flujo)

**Decisión de diseño:**
- Sin timestamps: Es configuración del flujo
- UNIQUE constraint asegura orden correcto
- RESTRICT en Interview: Mantener histórico

---

### 10. Position
Posiciones vacantes publicadas por empresas.

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `companyId` | Integer | FK, NOT NULL | Empresa que publica |
| `interviewFlowId` | Integer | FK, NOT NULL | Flujo de entrevistas asignado |
| `title` | VarChar(200) | NOT NULL | Título de la posición |
| `description` | Text | NULL | Descripción breve |
| `status` | PositionStatus | NOT NULL, DEFAULT DRAFT | Estado de la posición |
| `isVisible` | Boolean | NOT NULL, DEFAULT FALSE | Visible en búsquedas públicas |
| `location` | VarChar(200) | NULL | Ubicación del trabajo |
| `jobDescription` | Text | NULL | Descripción detallada del trabajo |
| `requirements` | Text | NULL | Requisitos del candidato |
| `responsibilities` | Text | NULL | Responsabilidades del puesto |
| `salaryMin` | Decimal(10,2) | NULL | Salario mínimo ofrecido |
| `salaryMax` | Decimal(10,2) | NULL | Salario máximo ofrecido |
| `employmentType` | EmploymentType | NOT NULL | Tipo de empleo |
| `benefits` | Text | NULL | Beneficios ofrecidos |
| `companyDescription` | Text | NULL | Descripción de la empresa |
| `applicationDeadline` | DateTime | NULL | Fecha límite para aplicar |
| `contactInfo` | VarChar(500) | NULL | Información de contacto |
| `createdAt` | DateTime | NOT NULL, DEFAULT NOW | Fecha de creación |
| `updatedAt` | DateTime | NOT NULL, AUTO | Última actualización |

**Relaciones:**
- N:1 con `Company` (onDelete: RESTRICT)
- N:1 con `InterviewFlow` (onDelete: RESTRICT)
- 1:N con `Application` (una posición recibe múltiples aplicaciones)

**Índices:**
- `companyId` (FK index)
- `interviewFlowId` (FK index)
- `status` (filtros por estado)
- `location` (búsquedas por ubicación)
- `employmentType` (filtros por tipo)

**Decisión de diseño:**
- Campos separados para SEO y búsquedas especializadas
- RESTRICT: Mantener histórico de posiciones con aplicaciones

---

### 11. Application
Aplicaciones de candidatos a posiciones específicas.

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `positionId` | Integer | FK, NOT NULL | Posición a la que aplica |
| `candidateId` | Integer | FK, NOT NULL | Candidato que aplica |
| `applicationDate` | DateTime | NOT NULL, DEFAULT NOW | Fecha de aplicación |
| `status` | ApplicationStatus | NOT NULL, DEFAULT PENDING | Estado de la aplicación |
| `notes` | Text | NULL | Notas del proceso |
| `createdAt` | DateTime | NOT NULL, DEFAULT NOW | Fecha de creación |
| `updatedAt` | DateTime | NOT NULL, AUTO | Última actualización |

**Relaciones:**
- N:1 con `Position` (onDelete: RESTRICT)
- N:1 con `Candidate` (onDelete: CASCADE)
- 1:N con `Interview` (una aplicación tiene múltiples entrevistas)

**Índices:**
- `positionId` (FK index)
- `candidateId` (FK index)
- `status` (filtros por estado)
- `applicationDate` (ordenamiento temporal)
- `(positionId, candidateId)` (UNIQUE - una aplicación por candidato/posición)

**Decisión de diseño:**
- UNIQUE constraint: Un candidato solo aplica una vez a cada posición
- CASCADE en Candidate: Si candidato se elimina, sus aplicaciones también
- RESTRICT en Position: Mantener histórico

---

### 12. Interview
Entrevistas individuales realizadas durante el proceso de selección.

| Campo | Tipo | Constraints | Descripción |
|-------|------|-------------|-------------|
| `id` | Integer | PK, AUTO | Identificador único |
| `applicationId` | Integer | FK, NOT NULL | Aplicación relacionada |
| `interviewStepId` | Integer | FK, NOT NULL | Paso del flujo |
| `employeeId` | Integer | FK, NOT NULL | Entrevistador |
| `interviewDate` | DateTime | NOT NULL | Fecha/hora de la entrevista |
| `result` | InterviewResult | NOT NULL, DEFAULT PENDING | Resultado |
| `score` | Integer | NULL | Puntuación (si aplica) |
| `notes` | Text | NULL | Notas de la entrevista |
| `createdAt` | DateTime | NOT NULL, DEFAULT NOW | Fecha de creación |
| `updatedAt` | DateTime | NOT NULL, AUTO | Última actualización |

**Relaciones:**
- N:1 con `Application` (onDelete: CASCADE)
- N:1 con `InterviewStep` (onDelete: RESTRICT)
- N:1 con `Employee` (onDelete: RESTRICT)

**Índices:**
- `applicationId` (FK index)
- `interviewStepId` (FK index)
- `employeeId` (FK index)
- `interviewDate` (ordenamiento temporal)
- `result` (filtros por resultado)

**Decisión de diseño:**
- CASCADE en Application: Si aplicación se elimina, sus entrevistas también
- RESTRICT en InterviewStep y Employee: Mantener histórico completo
- `score` opcional: No todos los tipos de entrevista tienen puntuación

---

## Relaciones entre Tablas

### Diagrama de Relaciones

```
COMPANY
  ├──> EMPLOYEE (1:N, RESTRICT)
  └──> POSITION (1:N, RESTRICT)

CANDIDATE
  ├──> EDUCATION (1:N, CASCADE)
  ├──> WORK_EXPERIENCE (1:N, CASCADE)
  ├──> RESUME (1:N, CASCADE)
  └──> APPLICATION (1:N, CASCADE)

POSITION
  ├── COMPANY (N:1, RESTRICT)
  ├── INTERVIEW_FLOW (N:1, RESTRICT)
  └──> APPLICATION (1:N, RESTRICT)

INTERVIEW_FLOW
  ├──> POSITION (1:N, RESTRICT)
  └──> INTERVIEW_STEP (1:N, CASCADE)

INTERVIEW_STEP
  ├── INTERVIEW_FLOW (N:1, CASCADE)
  ├── INTERVIEW_TYPE (N:1, RESTRICT)
  └──> INTERVIEW (1:N, RESTRICT)

APPLICATION
  ├── POSITION (N:1, RESTRICT)
  ├── CANDIDATE (N:1, CASCADE)
  └──> INTERVIEW (1:N, CASCADE)

INTERVIEW
  ├── APPLICATION (N:1, CASCADE)
  ├── INTERVIEW_STEP (N:1, RESTRICT)
  └── EMPLOYEE (N:1, RESTRICT)
```

### Matriz de Relaciones

| Tabla Padre | Tabla Hija | Tipo | onDelete | Justificación |
|-------------|------------|------|----------|---------------|
| Company | Employee | 1:N | RESTRICT | Proteger empresa con empleados |
| Company | Position | 1:N | RESTRICT | Proteger empresa con posiciones |
| Candidate | Education | 1:N | CASCADE | Educación es parte del candidato |
| Candidate | WorkExperience | 1:N | CASCADE | Experiencia es parte del candidato |
| Candidate | Resume | 1:N | CASCADE | CV es parte del candidato |
| Candidate | Application | 1:N | CASCADE | Aplicación depende del candidato |
| Position | Application | 1:N | RESTRICT | Mantener histórico de posiciones |
| InterviewFlow | Position | 1:N | RESTRICT | Proteger flujos en uso |
| InterviewFlow | InterviewStep | 1:N | CASCADE | Pasos son parte del flujo |
| InterviewType | InterviewStep | 1:N | RESTRICT | Proteger tipos en uso |
| InterviewStep | Interview | 1:N | RESTRICT | Mantener histórico completo |
| Application | Interview | 1:N | CASCADE | Entrevistas dependen de aplicación |
| Employee | Interview | 1:N | RESTRICT | Mantener registro de entrevistador |

---

## Índices y Performance

### Estrategia de Indexación

1. **Primary Keys:** Índice automático en todos los `id`
2. **Foreign Keys:** Índice explícito en todas las FKs para optimizar JOINs
3. **Campos Únicos:** `email` en Candidate y Employee
4. **Campos de Búsqueda Frecuente:**
   - Estados (status, result)
   - Fechas (applicationDate, interviewDate)
   - Ubicación (location)
   - Flags (isActive, isVisible)

### Índices por Tabla

| Tabla | Índices | Propósito |
|-------|---------|-----------|
| Candidate | email (UNIQUE) | Evitar duplicados, login rápido |
| Education | candidateId | JOINs rápidos |
| WorkExperience | candidateId | JOINs rápidos |
| Resume | candidateId | JOINs rápidos |
| Company | name | Búsquedas por nombre |
| Employee | companyId, email (UNIQUE), isActive | JOINs, login, filtros |
| InterviewType | name | Búsquedas por nombre |
| InterviewStep | interviewFlowId, interviewTypeId, (flowId+orderIndex) UNIQUE | JOINs, ordenamiento |
| Position | companyId, flowId, status, location, employmentType | JOINs, filtros múltiples |
| Application | positionId, candidateId, status, date, (position+candidate) UNIQUE | JOINs, filtros, unicidad |
| Interview | applicationId, stepId, employeeId, date, result | JOINs, filtros, reportes |

### Queries Optimizadas

Los índices están diseñados para optimizar:

- ✅ Listar posiciones abiertas por ubicación
- ✅ Buscar aplicaciones por estado
- ✅ Filtrar entrevistas por fecha y resultado
- ✅ Listar empleados activos de una empresa
- ✅ Buscar candidatos por email
- ✅ Obtener histórico completo de un candidato
- ✅ Dashboard de reclutador (JOINs múltiples)

---

## Decisiones de Diseño

### 1. Normalización 3FN
**Decisión:** Aplicar normalización hasta 3FN estricta.  
**Justificación:**
- Eliminar redundancia de datos
- Facilitar actualizaciones sin anomalías
- Mantener integridad de datos
- No hay necesidad de desnormalización por performance en esta escala

### 2. Timestamps Selectivos
**Decisión:** Solo timestamps en entidades principales, no en todas.  
**Justificación:**
- Education y WorkExperience ya tienen fechas del dominio (startDate/endDate)
- Resume tiene uploadDate que es suficiente
- Evita redundancia y confusión
- Reduce tamaño de tablas

### 3. ENUMs vs Tablas Catálogo
**Decisión:** Usar ENUMs de Prisma para estados y tipos fijos.  
**Justificación:**
- Valores conocidos y estables
- Mejor performance (sin JOINs adicionales)
- Validación a nivel de base de datos
- Más simple de mantener

### 4. Cascade vs Restrict
**Decisión:** Cascade para composición, Restrict para referencia.  
**Justificación:**
- Cascade: Cuando el hijo no tiene sentido sin el padre
- Restrict: Para mantener integridad histórica
- Position, Employee protegidos: datos históricos valiosos

### 5. Aplicación Única por Posición
**Decisión:** UNIQUE constraint en (positionId, candidateId).  
**Justificación:**
- Un candidato solo debe aplicar una vez a cada posición
- Previene duplicados accidentales
- Simplifica lógica de negocio

### 6. Orden en InterviewStep
**Decisión:** UNIQUE constraint en (interviewFlowId, orderIndex).  
**Justificación:**
- Cada paso debe tener orden único dentro del flujo
- Facilita mostrar pasos en secuencia correcta
- Previene errores de configuración

### 7. Campos Opcionales Extensos
**Decisión:** Múltiples campos TEXT opcionales en Position.  
**Justificación:**
- Flexibilidad para diferentes tipos de posiciones
- Algunos campos necesarios para SEO y búsquedas
- NULL permitido para no forzar llenado completo

### 8. Decimal para Salarios
**Decisión:** Decimal(10,2) en vez de Float.  
**Justificación:**
- Precisión exacta para valores monetarios
- Evita errores de redondeo
- Estándar en aplicaciones financieras

### 9. Soft Delete vs Hard Delete
**Decisión:** No implementar soft delete (isDeleted flag).  
**Justificación:**
- RESTRICT protege datos importantes
- Historial se mantiene en Interview y Application
- Simplifica queries (no necesitar WHERE isDeleted = false)
- Se puede agregar después si es necesario

### 10. Separación Candidate vs User
**Decisión:** Candidate es solo para perfiles profesionales, no autenticación.  
**Justificación:**
- Separación de concerns
- Candidatos pueden existir sin cuenta de usuario
- Facilita importación de CVs externos
- Sistema de autenticación puede agregarse después

---

## Mantenimiento y Evolución

### Migraciones Futuras Posibles

1. **Sistema de Autenticación:**
   - Tabla `User` separada
   - Relación opcional Candidate-User
   - Roles y permisos

2. **Auditoría Completa:**
   - Tabla `AuditLog` para rastrear cambios
   - Triggered automático en modificaciones

3. **Documentos Adicionales:**
   - Tabla genérica `Document` para contratos, evaluaciones, etc.

4. **Notificaciones:**
   - Sistema de notificaciones por email/SMS
   - Templates de comunicación

5. **Reportes y Analytics:**
   - Vistas materializadas para dashboards
   - Métricas de funnel de reclutamiento

### Versionado del Schema

- ✅ Cada migración debe tener nombre descriptivo
- ✅ Mantener backward compatibility cuando sea posible
- ✅ Documentar breaking changes en comentarios
- ✅ Usar migraciones de Prisma para rastrear cambios

---

## Glosario de Términos

| Término | Definición |
|---------|------------|
| **Candidate** | Persona que busca empleo en el sistema |
| **Position** | Vacante o puesto de trabajo publicado por una empresa |
| **Application** | Postulación de un candidato a una posición específica |
| **Interview Flow** | Secuencia configurada de pasos de entrevista |
| **Interview Step** | Etapa individual dentro de un flujo de entrevista |
| **Interview Type** | Categoría de entrevista (técnica, cultural, etc.) |
| **Employee** | Persona que trabaja para una empresa y participa en reclutamiento |
| **CASCADE** | Eliminar registros relacionados automáticamente |
| **RESTRICT** | Prevenir eliminación si existen registros relacionados |

---

## Referencias

- **Documentación Prisma:** https://www.prisma.io/docs
- **PostgreSQL Documentation:** https://www.postgresql.org/docs/
- **Normalización de BD:** https://en.wikipedia.org/wiki/Database_normalization
- **Buenas Prácticas de Diseño:** Incluidas en `prompts-cursor-db-plan-hso_bp.md`

---

**Fin del Diccionario de Datos**

_Documento generado como parte del ejercicio HSO del módulo de bases de datos._

