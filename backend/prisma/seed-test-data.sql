-- =====================================================
-- DATOS DE PRUEBA - LTI Talent Tracking System
-- =====================================================
-- Este archivo contiene datos de prueba mínimos para validar
-- el funcionamiento completo del sistema de reclutamiento.
--
-- Estructura:
-- 1 Company
-- 2 Employees
-- 1 InterviewType (catálogo)
-- 1 InterviewFlow
-- 2 InterviewSteps
-- 1 Position
-- 1 Candidate (con Education, WorkExperience, Resume)
-- 1 Application
-- 1 Interview
-- =====================================================

-- =====================================================
-- 1. COMPANY
-- =====================================================
INSERT INTO "Company" ("id", "name", "createdAt", "updatedAt")
VALUES 
(1, 'Tech Innovations Inc.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================
-- 2. EMPLOYEES
-- =====================================================
INSERT INTO "Employee" ("id", "companyId", "name", "email", "role", "isActive", "createdAt", "updatedAt")
VALUES 
(1, 1, 'María García', 'maria.garcia@techinnovations.com', 'RECRUITER', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 1, 'Carlos López', 'carlos.lopez@techinnovations.com', 'HIRING_MANAGER', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================
-- 3. INTERVIEW TYPES (Catálogo)
-- =====================================================
INSERT INTO "InterviewType" ("id", "name", "description")
VALUES 
(1, 'Entrevista Técnica', 'Evaluación de habilidades técnicas y conocimientos específicos del puesto'),
(2, 'Entrevista Cultural', 'Evaluación de fit cultural y valores con la empresa'),
(3, 'Entrevista HR', 'Entrevista inicial de recursos humanos para validar perfil');

-- =====================================================
-- 4. INTERVIEW FLOW
-- =====================================================
INSERT INTO "InterviewFlow" ("id", "description", "createdAt", "updatedAt")
VALUES 
(1, 'Proceso estándar de selección técnica - 2 etapas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================
-- 5. INTERVIEW STEPS
-- =====================================================
INSERT INTO "InterviewStep" ("id", "interviewFlowId", "interviewTypeId", "name", "orderIndex")
VALUES 
(1, 1, 3, 'Filtro inicial HR', 1),
(2, 1, 1, 'Evaluación técnica', 2);

-- =====================================================
-- 6. POSITION
-- =====================================================
INSERT INTO "Position" (
    "id", 
    "companyId", 
    "interviewFlowId", 
    "title", 
    "description", 
    "status", 
    "isVisible", 
    "location", 
    "jobDescription",
    "requirements",
    "responsibilities",
    "salaryMin",
    "salaryMax",
    "employmentType",
    "benefits",
    "companyDescription",
    "applicationDeadline",
    "contactInfo",
    "createdAt", 
    "updatedAt"
)
VALUES (
    1,
    1,
    1,
    'Desarrollador Full Stack Senior',
    'Buscamos desarrollador con experiencia en React y Node.js',
    'OPEN',
    true,
    'Ciudad de México, CDMX',
    'Estamos buscando un Desarrollador Full Stack Senior para unirse a nuestro equipo de innovación. Trabajarás en proyectos de alto impacto utilizando las últimas tecnologías.',
    '- 5+ años de experiencia en desarrollo web
- Dominio de React, Node.js y TypeScript
- Experiencia con bases de datos PostgreSQL
- Conocimiento de metodologías ágiles
- Inglés intermedio',
    '- Diseñar y desarrollar aplicaciones web modernas
- Colaborar con equipos multidisciplinarios
- Participar en code reviews
- Mentorear desarrolladores junior
- Optimizar performance de aplicaciones',
    60000.00,
    90000.00,
    'FULL_TIME',
    '- Seguro de gastos médicos mayores
- Vales de despensa
- Home office híbrido
- Capacitación continua
- Días de vacaciones adicionales',
    'Tech Innovations Inc. es una empresa líder en desarrollo de software con más de 10 años en el mercado. Nos enfocamos en crear soluciones innovadoras para nuestros clientes.',
    CURRENT_TIMESTAMP + INTERVAL '30 days',
    'reclutamiento@techinnovations.com',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- =====================================================
-- 7. CANDIDATE
-- =====================================================
INSERT INTO "Candidate" ("id", "firstName", "lastName", "email", "phone", "address", "createdAt", "updatedAt")
VALUES 
(1, 'Juan', 'Pérez Rodríguez', 'juan.perez@email.com', '+525512345678', 'Calle Principal 123, Col. Centro, CDMX', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================
-- 8. EDUCATION
-- =====================================================
INSERT INTO "Education" ("id", "candidateId", "institution", "title", "startDate", "endDate")
VALUES 
(1, 1, 'Universidad Nacional Autónoma de México', 'Ingeniería en Computación', '2012-08-01', '2016-06-30'),
(2, 1, 'Coursera', 'Certificación en React Advanced', '2020-01-15', '2020-03-30');

-- =====================================================
-- 9. WORK EXPERIENCE
-- =====================================================
INSERT INTO "WorkExperience" ("id", "candidateId", "company", "position", "description", "startDate", "endDate")
VALUES 
(1, 1, 'Software Solutions SA', 'Desarrollador Full Stack', 'Desarrollo de aplicaciones web con React y Node.js para clientes del sector financiero', '2016-07-01', '2019-12-31'),
(2, 1, 'Digital Agency MX', 'Senior Full Stack Developer', 'Liderazgo técnico de equipo de 4 desarrolladores, arquitectura de soluciones escalables', '2020-01-15', '2024-10-31');

-- =====================================================
-- 10. RESUME
-- =====================================================
INSERT INTO "Resume" ("id", "candidateId", "filePath", "fileType", "uploadDate")
VALUES 
(1, 1, 'uploads/resumes/juan_perez_cv_2024.pdf', 'application/pdf', CURRENT_TIMESTAMP);

-- =====================================================
-- 11. APPLICATION
-- =====================================================
INSERT INTO "Application" (
    "id", 
    "positionId", 
    "candidateId", 
    "applicationDate", 
    "status", 
    "notes",
    "createdAt", 
    "updatedAt"
)
VALUES (
    1,
    1,
    1,
    CURRENT_TIMESTAMP - INTERVAL '3 days',
    'REVIEWING',
    'Candidato con excelente experiencia. Perfil muy ajustado a los requisitos.',
    CURRENT_TIMESTAMP - INTERVAL '3 days',
    CURRENT_TIMESTAMP
);

-- =====================================================
-- 12. INTERVIEW
-- =====================================================
INSERT INTO "Interview" (
    "id",
    "applicationId",
    "interviewStepId",
    "employeeId",
    "interviewDate",
    "result",
    "score",
    "notes",
    "createdAt",
    "updatedAt"
)
VALUES (
    1,
    1,
    1,
    1,
    CURRENT_TIMESTAMP - INTERVAL '1 day',
    'PASSED',
    85,
    'Candidato muy preparado. Buena comunicación y actitud positiva. Experiencia técnica sólida. Aprobado para siguiente etapa.',
    CURRENT_TIMESTAMP - INTERVAL '1 day',
    CURRENT_TIMESTAMP
);

-- =====================================================
-- RESETEAR SECUENCIAS (para próximos inserts)
-- =====================================================
SELECT setval('"Company_id_seq"', (SELECT MAX(id) FROM "Company"));
SELECT setval('"Employee_id_seq"', (SELECT MAX(id) FROM "Employee"));
SELECT setval('"InterviewType_id_seq"', (SELECT MAX(id) FROM "InterviewType"));
SELECT setval('"InterviewFlow_id_seq"', (SELECT MAX(id) FROM "InterviewFlow"));
SELECT setval('"InterviewStep_id_seq"', (SELECT MAX(id) FROM "InterviewStep"));
SELECT setval('"Position_id_seq"', (SELECT MAX(id) FROM "Position"));
SELECT setval('"Candidate_id_seq"', (SELECT MAX(id) FROM "Candidate"));
SELECT setval('"Education_id_seq"', (SELECT MAX(id) FROM "Education"));
SELECT setval('"WorkExperience_id_seq"', (SELECT MAX(id) FROM "WorkExperience"));
SELECT setval('"Resume_id_seq"', (SELECT MAX(id) FROM "Resume"));
SELECT setval('"Application_id_seq"', (SELECT MAX(id) FROM "Application"));
SELECT setval('"Interview_id_seq"', (SELECT MAX(id) FROM "Interview"));

-- =====================================================
-- VERIFICACIÓN DE DATOS
-- =====================================================
-- Ejecuta estas queries para verificar que los datos se insertaron correctamente:

-- Total de registros por tabla
SELECT 'Company' as tabla, COUNT(*) as registros FROM "Company"
UNION ALL
SELECT 'Employee', COUNT(*) FROM "Employee"
UNION ALL
SELECT 'InterviewType', COUNT(*) FROM "InterviewType"
UNION ALL
SELECT 'InterviewFlow', COUNT(*) FROM "InterviewFlow"
UNION ALL
SELECT 'InterviewStep', COUNT(*) FROM "InterviewStep"
UNION ALL
SELECT 'Position', COUNT(*) FROM "Position"
UNION ALL
SELECT 'Candidate', COUNT(*) FROM "Candidate"
UNION ALL
SELECT 'Education', COUNT(*) FROM "Education"
UNION ALL
SELECT 'WorkExperience', COUNT(*) FROM "WorkExperience"
UNION ALL
SELECT 'Resume', COUNT(*) FROM "Resume"
UNION ALL
SELECT 'Application', COUNT(*) FROM "Application"
UNION ALL
SELECT 'Interview', COUNT(*) FROM "Interview";

-- =====================================================
-- FIN DE DATOS DE PRUEBA
-- =====================================================

