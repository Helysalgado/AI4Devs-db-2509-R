-- =====================================================
-- QUERIES DE VALIDACIÓN - LTI Talent Tracking System
-- =====================================================
-- Este archivo contiene queries para validar:
-- - Búsquedas usando índices
-- - JOINs correctos entre tablas
-- - Relaciones Candidate-Application-Position
-- - Relación Interview-InterviewStep-Employee
-- - Conteos y agregados
-- =====================================================

-- =====================================================
-- QUERY 1: Búsqueda de Candidatos por Email (usando índice UNIQUE)
-- =====================================================
-- Objetivo: Validar índice en Candidate.email
-- Índice utilizado: Candidate_email_key (UNIQUE)
-- =====================================================

EXPLAIN ANALYZE
SELECT 
    c.id,
    c."firstName",
    c."lastName",
    c.email,
    c.phone,
    COUNT(a.id) as total_applications
FROM "Candidate" c
LEFT JOIN "Application" a ON c.id = a."candidateId"
WHERE c.email = 'juan.perez@email.com'
GROUP BY c.id, c."firstName", c."lastName", c.email, c.phone;

-- Resultado esperado: Juan Pérez con 1 aplicación
-- Plan esperado: Index Scan using Candidate_email_key


-- =====================================================
-- QUERY 2: Posiciones Abiertas por Ubicación (usando múltiples índices)
-- =====================================================
-- Objetivo: Validar índices en Position.status y Position.location
-- Índices utilizados: Position_status_idx, Position_location_idx
-- =====================================================

EXPLAIN ANALYZE
SELECT 
    p.id,
    p.title,
    p.location,
    p."employmentType",
    p."salaryMin",
    p."salaryMax",
    c.name as company_name,
    COUNT(a.id) as total_applications
FROM "Position" p
INNER JOIN "Company" c ON p."companyId" = c.id
LEFT JOIN "Application" a ON p.id = a."positionId"
WHERE 
    p.status = 'OPEN' 
    AND p.location ILIKE '%Ciudad de México%'
    AND p."isVisible" = true
GROUP BY p.id, p.title, p.location, p."employmentType", p."salaryMin", p."salaryMax", c.name
ORDER BY total_applications DESC;

-- Resultado esperado: 1 posición (Desarrollador Full Stack Senior) con 1 aplicación
-- Plan esperado: Bitmap Index Scan en Position_status_idx


-- =====================================================
-- QUERY 3: Historial Completo de un Candidato con Relaciones
-- =====================================================
-- Objetivo: Validar JOINs múltiples: Candidate → Education, WorkExperience, Application → Position
-- Índices utilizados: Education_candidateId_idx, WorkExperience_candidateId_idx, Application_candidateId_idx
-- =====================================================

EXPLAIN ANALYZE
SELECT 
    c.id as candidate_id,
    c."firstName" || ' ' || c."lastName" as candidate_name,
    c.email,
    
    -- Educación
    json_agg(DISTINCT jsonb_build_object(
        'institution', e.institution,
        'title', e.title,
        'startDate', e."startDate",
        'endDate', e."endDate"
    )) FILTER (WHERE e.id IS NOT NULL) as education,
    
    -- Experiencia Laboral
    json_agg(DISTINCT jsonb_build_object(
        'company', w.company,
        'position', w.position,
        'startDate', w."startDate",
        'endDate', w."endDate"
    )) FILTER (WHERE w.id IS NOT NULL) as work_experience,
    
    -- Aplicaciones
    json_agg(DISTINCT jsonb_build_object(
        'position_title', p.title,
        'company', co.name,
        'application_date', a."applicationDate",
        'status', a.status
    )) FILTER (WHERE a.id IS NOT NULL) as applications

FROM "Candidate" c
LEFT JOIN "Education" e ON c.id = e."candidateId"
LEFT JOIN "WorkExperience" w ON c.id = w."candidateId"
LEFT JOIN "Application" a ON c.id = a."candidateId"
LEFT JOIN "Position" p ON a."positionId" = p.id
LEFT JOIN "Company" co ON p."companyId" = co.id
WHERE c.id = 1
GROUP BY c.id, c."firstName", c."lastName", c.email;

-- Resultado esperado: Perfil completo de Juan Pérez con 2 educaciones, 2 experiencias, 1 aplicación
-- Plan esperado: Multiple Index Scans en FKs


-- =====================================================
-- QUERY 4: Proceso de Entrevistas con InterviewStep y Employee
-- =====================================================
-- Objetivo: Validar relación Interview → InterviewStep → InterviewType + Employee
-- Índices utilizados: Interview_applicationId_idx, Interview_interviewStepId_idx, Interview_employeeId_idx
-- =====================================================

EXPLAIN ANALYZE
SELECT 
    c."firstName" || ' ' || c."lastName" as candidate_name,
    p.title as position_title,
    a."applicationDate",
    a.status as application_status,
    
    -- Detalles de entrevistas
    i."interviewDate",
    ist.name as interview_step_name,
    ist."orderIndex" as step_order,
    it.name as interview_type,
    i.result as interview_result,
    i.score,
    e.name as interviewer_name,
    e.role as interviewer_role,
    i.notes as interview_notes

FROM "Application" a
INNER JOIN "Candidate" c ON a."candidateId" = c.id
INNER JOIN "Position" p ON a."positionId" = p.id
LEFT JOIN "Interview" i ON a.id = i."applicationId"
LEFT JOIN "InterviewStep" ist ON i."interviewStepId" = ist.id
LEFT JOIN "InterviewType" it ON ist."interviewTypeId" = it.id
LEFT JOIN "Employee" e ON i."employeeId" = e.id
WHERE a.id = 1
ORDER BY ist."orderIndex", i."interviewDate";

-- Resultado esperado: Juan Pérez → Entrevista HR con María García → PASSED (85 puntos)
-- Plan esperado: Index Scans en todas las FKs


-- =====================================================
-- QUERY 5: Dashboard de Reclutamiento - Conteos Agregados
-- =====================================================
-- Objetivo: Validar queries agregadas con múltiples índices
-- Índices utilizados: Application_status_idx, Interview_result_idx, Position_status_idx
-- =====================================================

EXPLAIN ANALYZE
WITH position_stats AS (
    SELECT 
        p.id,
        p.title,
        p.status,
        COUNT(DISTINCT a.id) as total_applications,
        COUNT(DISTINCT CASE WHEN a.status = 'PENDING' THEN a.id END) as pending_applications,
        COUNT(DISTINCT CASE WHEN a.status = 'REVIEWING' THEN a.id END) as reviewing_applications,
        COUNT(DISTINCT CASE WHEN a.status = 'INTERVIEWED' THEN a.id END) as interviewed_applications,
        COUNT(DISTINCT CASE WHEN a.status = 'ACCEPTED' THEN a.id END) as accepted_applications,
        COUNT(DISTINCT CASE WHEN a.status = 'REJECTED' THEN a.id END) as rejected_applications
    FROM "Position" p
    LEFT JOIN "Application" a ON p.id = a."positionId"
    WHERE p.status IN ('OPEN', 'ON_HOLD')
    GROUP BY p.id, p.title, p.status
),
interview_stats AS (
    SELECT 
        a."positionId",
        COUNT(DISTINCT i.id) as total_interviews,
        COUNT(DISTINCT CASE WHEN i.result = 'PASSED' THEN i.id END) as passed_interviews,
        COUNT(DISTINCT CASE WHEN i.result = 'FAILED' THEN i.id END) as failed_interviews,
        COUNT(DISTINCT CASE WHEN i.result = 'PENDING' THEN i.id END) as pending_interviews,
        ROUND(AVG(i.score), 2) as avg_score
    FROM "Application" a
    LEFT JOIN "Interview" i ON a.id = i."applicationId"
    GROUP BY a."positionId"
)
SELECT 
    ps.*,
    COALESCE(ist.total_interviews, 0) as total_interviews,
    COALESCE(ist.passed_interviews, 0) as passed_interviews,
    COALESCE(ist.failed_interviews, 0) as failed_interviews,
    COALESCE(ist.pending_interviews, 0) as pending_interviews,
    COALESCE(ist.avg_score, 0) as avg_interview_score,
    
    -- Métricas de conversión
    CASE 
        WHEN ps.total_applications > 0 
        THEN ROUND((ps.interviewed_applications::numeric / ps.total_applications) * 100, 2)
        ELSE 0 
    END as interview_conversion_rate,
    
    CASE 
        WHEN ps.total_applications > 0 
        THEN ROUND((ps.accepted_applications::numeric / ps.total_applications) * 100, 2)
        ELSE 0 
    END as acceptance_rate

FROM position_stats ps
LEFT JOIN interview_stats ist ON ps.id = ist."positionId"
ORDER BY ps.total_applications DESC;

-- Resultado esperado: Estadísticas de posición con métricas de conversión
-- Plan esperado: CTE scan con índices en status


-- =====================================================
-- QUERY 6: Validar Integridad de Foreign Keys
-- =====================================================
-- Objetivo: Verificar que no hay registros huérfanos (integridad referencial)
-- =====================================================

-- Educación sin candidato (no debería existir)
SELECT 'Education huérfana' as issue, COUNT(*) as count
FROM "Education" e
LEFT JOIN "Candidate" c ON e."candidateId" = c.id
WHERE c.id IS NULL

UNION ALL

-- WorkExperience sin candidato (no debería existir)
SELECT 'WorkExperience huérfana', COUNT(*)
FROM "WorkExperience" w
LEFT JOIN "Candidate" c ON w."candidateId" = c.id
WHERE c.id IS NULL

UNION ALL

-- Application sin Position o Candidate (no debería existir)
SELECT 'Application sin Position', COUNT(*)
FROM "Application" a
LEFT JOIN "Position" p ON a."positionId" = p.id
WHERE p.id IS NULL

UNION ALL

SELECT 'Application sin Candidate', COUNT(*)
FROM "Application" a
LEFT JOIN "Candidate" c ON a."candidateId" = c.id
WHERE c.id IS NULL

UNION ALL

-- Interview sin Application (no debería existir)
SELECT 'Interview sin Application', COUNT(*)
FROM "Interview" i
LEFT JOIN "Application" a ON i."applicationId" = a.id
WHERE a.id IS NULL

UNION ALL

-- Interview sin InterviewStep (no debería existir)
SELECT 'Interview sin InterviewStep', COUNT(*)
FROM "Interview" i
LEFT JOIN "InterviewStep" ist ON i."interviewStepId" = ist.id
WHERE ist.id IS NULL

UNION ALL

-- Interview sin Employee (no debería existir)
SELECT 'Interview sin Employee', COUNT(*)
FROM "Interview" i
LEFT JOIN "Employee" e ON i."employeeId" = e.id
WHERE e.id IS NULL;

-- Resultado esperado: Todos los conteos deben ser 0


-- =====================================================
-- QUERY 7: Validar Constraints UNIQUE
-- =====================================================
-- Objetivo: Verificar que los constraints UNIQUE están funcionando
-- =====================================================

-- Emails duplicados en Candidate (no debería existir)
SELECT 'Candidate emails duplicados' as issue, email, COUNT(*) as count
FROM "Candidate"
GROUP BY email
HAVING COUNT(*) > 1

UNION ALL

-- Emails duplicados en Employee (no debería existir)
SELECT 'Employee emails duplicados', email, COUNT(*)
FROM "Employee"
GROUP BY email
HAVING COUNT(*) > 1

UNION ALL

-- Aplicaciones duplicadas (mismo candidato a misma posición)
SELECT 'Aplicaciones duplicadas', 
       "positionId"::text || '-' || "candidateId"::text, 
       COUNT(*)
FROM "Application"
GROUP BY "positionId", "candidateId"
HAVING COUNT(*) > 1

UNION ALL

-- OrderIndex duplicado en mismo InterviewFlow
SELECT 'OrderIndex duplicado en Flow',
       "interviewFlowId"::text || '-' || "orderIndex"::text,
       COUNT(*)
FROM "InterviewStep"
GROUP BY "interviewFlowId", "orderIndex"
HAVING COUNT(*) > 1;

-- Resultado esperado: Sin resultados (no duplicados)


-- =====================================================
-- QUERY 8: Performance de Índices - Búsqueda por Fechas
-- =====================================================
-- Objetivo: Validar índices en campos de fecha
-- Índices utilizados: Application_applicationDate_idx, Interview_interviewDate_idx
-- =====================================================

EXPLAIN ANALYZE
SELECT 
    DATE(a."applicationDate") as application_day,
    COUNT(DISTINCT a.id) as total_applications,
    COUNT(DISTINCT i.id) as total_interviews,
    
    -- Breakdown por status
    COUNT(DISTINCT CASE WHEN a.status = 'PENDING' THEN a.id END) as pending,
    COUNT(DISTINCT CASE WHEN a.status = 'REVIEWING' THEN a.id END) as reviewing,
    COUNT(DISTINCT CASE WHEN a.status = 'INTERVIEWED' THEN a.id END) as interviewed,
    COUNT(DISTINCT CASE WHEN a.status = 'ACCEPTED' THEN a.id END) as accepted,
    COUNT(DISTINCT CASE WHEN a.status = 'REJECTED' THEN a.id END) as rejected

FROM "Application" a
LEFT JOIN "Interview" i ON a.id = i."applicationId"
WHERE 
    a."applicationDate" >= CURRENT_DATE - INTERVAL '30 days'
    AND a."applicationDate" < CURRENT_DATE + INTERVAL '1 day'
GROUP BY DATE(a."applicationDate")
ORDER BY application_day DESC;

-- Resultado esperado: Aplicaciones de los últimos 30 días agrupadas por día
-- Plan esperado: Index Scan usando Application_applicationDate_idx


-- =====================================================
-- QUERY 9: Flujo Completo de Entrevista por Posición
-- =====================================================
-- Objetivo: Validar toda la cadena de relaciones del flujo de entrevista
-- =====================================================

EXPLAIN ANALYZE
SELECT 
    p.title as position_title,
    intf.description as interview_flow,
    ist."orderIndex" as step_order,
    ist.name as step_name,
    intt.name as interview_type,
    intt.description as type_description,
    
    -- Estadísticas de este paso
    COUNT(DISTINCT i.id) as interviews_in_step,
    COUNT(DISTINCT CASE WHEN i.result = 'PASSED' THEN i.id END) as passed_count,
    COUNT(DISTINCT CASE WHEN i.result = 'FAILED' THEN i.id END) as failed_count,
    COUNT(DISTINCT CASE WHEN i.result = 'PENDING' THEN i.id END) as pending_count,
    ROUND(AVG(i.score), 2) as avg_score

FROM "Position" p
INNER JOIN "InterviewFlow" intf ON p."interviewFlowId" = intf.id
INNER JOIN "InterviewStep" ist ON intf.id = ist."interviewFlowId"
INNER JOIN "InterviewType" intt ON ist."interviewTypeId" = intt.id
LEFT JOIN "Interview" i ON ist.id = i."interviewStepId"
WHERE p.id = 1
GROUP BY p.id, p.title, intf.id, intf.description, ist.id, ist."orderIndex", ist.name, intt.name, intt.description
ORDER BY ist."orderIndex";

-- Resultado esperado: 2 pasos del flujo (HR y Técnica) con estadísticas
-- Plan esperado: Nested loops con index scans en FKs


-- =====================================================
-- QUERY 10: Empleados más Activos en Entrevistas
-- =====================================================
-- Objetivo: Validar índice en Interview_employeeId y agregaciones
-- Índice utilizado: Interview_employeeId_idx
-- =====================================================

EXPLAIN ANALYZE
SELECT 
    e.id,
    e.name as employee_name,
    e.role as employee_role,
    c.name as company_name,
    
    -- Estadísticas de entrevistas
    COUNT(i.id) as total_interviews,
    COUNT(CASE WHEN i.result = 'PASSED' THEN 1 END) as passed_interviews,
    COUNT(CASE WHEN i.result = 'FAILED' THEN 1 END) as failed_interviews,
    COUNT(CASE WHEN i.result = 'PENDING' THEN 1 END) as pending_interviews,
    
    -- Métricas
    ROUND(AVG(i.score), 2) as avg_score_given,
    ROUND(
        (COUNT(CASE WHEN i.result = 'PASSED' THEN 1 END)::numeric / 
         NULLIF(COUNT(CASE WHEN i.result != 'PENDING' THEN 1 END), 0)) * 100, 
        2
    ) as approval_rate,
    
    -- Última entrevista
    MAX(i."interviewDate") as last_interview_date

FROM "Employee" e
INNER JOIN "Company" c ON e."companyId" = c.id
LEFT JOIN "Interview" i ON e.id = i."employeeId"
WHERE e."isActive" = true
GROUP BY e.id, e.name, e.role, c.name
HAVING COUNT(i.id) > 0
ORDER BY total_interviews DESC, avg_score_given DESC;

-- Resultado esperado: María García con 1 entrevista, tasa de aprobación 100%
-- Plan esperado: Index Scan usando Interview_employeeId_idx


-- =====================================================
-- RESUMEN DE VALIDACIÓN
-- =====================================================
-- Las queries anteriores validan:
-- ✅ Índices en campos únicos (email)
-- ✅ Índices en foreign keys (todas las relaciones)
-- ✅ Índices en campos de búsqueda (status, location, dates)
-- ✅ JOINs correctos entre todas las tablas
-- ✅ Relaciones complejas (Candidate → Application → Interview)
-- ✅ Integridad referencial (sin registros huérfanos)
-- ✅ Constraints UNIQUE funcionando
-- ✅ Agregaciones y métricas de negocio
-- ✅ Performance de queries con EXPLAIN ANALYZE
-- ✅ Flujos completos del sistema
-- =====================================================

