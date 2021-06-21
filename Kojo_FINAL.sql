CREATE TABLE departments (
    departement_id   NUMBER(4, 0) NOT NULL,
    department_name  VARCHAR2(30 BYTE) NOT NULL,
    manager_id       NUMBER(6, 0),
    location_id      NUMBER,
    created_by       VARCHAR2(30 BYTE),
    created_date     DATE,
    updated_by       VARCHAR2(30 BYTE),
    updated_date     DATE
);

CREATE TABLE employees (
    employee_id   NUMBER(4, 0) NOT NULL,
    first_name    VARCHAR2(20 BYTE),
    last_name     VARCHAR2(25 BYTE) NOT NULL,
    email         VARCHAR2(25 BYTE) NOT NULL,
    phone_number  VARCHAR2(20 BYTE),
    created_by    VARCHAR2(30 BYTE),
    created_date  DATE,
    updated_by    VARCHAR2(30 BYTE),
    updated_date  DATE
);

CREATE TABLE locations (
    location_id     NUMBER(4, 0) NOT NULL,
    street_address  VARCHAR2(40 BYTE),
    postal_code     VARCHAR2(12 BYTE),
    city            VARCHAR2(30 BYTE) NOT NULL,
    state_province  VARCHAR2(25 BYTE),
    country_id      VARCHAR2(20 BYTE),
    created_by      VARCHAR2(30 BYTE),
    created_date    DATE,
    updated_by      VARCHAR2(30 BYTE),
    updated_date    DATE
);

CREATE TABLE countries (
    country_id    NUMBER(2, 0) NOT NULL,
    country_name  VARCHAR2(40 BYTE),
    region_id     NUMBER,
    created_by    VARCHAR2(30 BYTE),
    created_date  DATE,
    updated_by    VARCHAR2(30 BYTE),
    updated_date  DATE
);

CREATE TABLE regions (
    region_id     NUMBER NOT NULL,
    region_name   VARCHAR2(25 BYTE),
    created_by    VARCHAR2(30 BYTE),
    created_date  DATE,
    updated_by    VARCHAR2(30 BYTE),
    updated_date  DATE
);

CREATE TABLE employment (
    employment_id  NUMBER(9, 0) NOT NULL,
    employmee_id   NUMBER(6, 0) NOT NULL,
    job_id         VARCHAR2(10 BYTE) NOT NULL,
    department_id  NUMBER(4, 0) NOT NULL,
    created_by     VARCHAR2(30 BYTE),
    created_date   DATE,
    updated_by     VARCHAR2(30 BYTE),
    updated_date   DATE
);

CREATE TABLE employment_pay (
    employment_id   NUMBER(9, 0) NOT NULL,
    start_date      DATE NOT NULL,
    salary          NUMBER(8, 2),
    commission_pct  NUMBER(2, 2),
    created_by      VARCHAR2(30 BYTE),
    created_date    DATE,
    updated_by      VARCHAR2(30 BYTE),
    updated_date    DATE
);

CREATE TABLE jobs (
    job_id        VARCHAR2(10 BYTE) NOT NULL,
    job_title     VARCHAR2(35 BYTE) NOT NULL,
    min_salary    NUMBER(6, 0),
    max_salary    NUMBER(6, 0),
    created_by    VARCHAR2(30 BYTE),
    created_date  DATE,
    updated_by    VARCHAR2(30 BYTE),
    updated_date  DATE
);

ALTER TABLE departments ADD CONSTRAINT deparments_pk PRIMARY KEY ( department_id ) ENABLE;

ALTER TABLE employees ADD CONSTRAINT employees_pk PRIMARY KEY ( employee_id ) ENABLE;

ALTER TABLE locations ADD CONSTRAINT locations_pk PRIMARY KEY ( location_id ) ENABLE;

ALTER TABLE countries ADD CONSTRAINT countries_pk PRIMARY KEY ( country_id ) ENABLE;

ALTER TABLE regions ADD CONSTRAINT regions_pk PRIMARY KEY ( region_id ) ENABLE;

ALTER TABLE employment ADD CONSTRAINT employment_pk PRIMARY KEY ( employment_id ) ENABLE;

ALTER TABLE employment_pay ADD CONSTRAINT employment_pay_pk PRIMARY KEY ( employment_id ) ENABLE;

ALTER TABLE jobs ADD CONSTRAINT jobs_pk PRIMARY KEY ( job_id ) ENABLE;

ALTER TABLE countries
    ADD CONSTRAINT countr_reg_fk FOREIGN KEY ( region_id )
        REFERENCES regions ( region_id )
    ENABLE;

ALTER TABLE locations
    ADD CONSTRAINT loc_c_id_fk FOREIGN KEY ( country_id )
        REFERENCES countries ( country_id )
    ENABLE;

ALTER TABLE employment_pay
    ADD CONSTRAINT employment_pay_fk1 FOREIGN KEY ( employment_id )
        REFERENCES employment ( employment_id )
    ENABLE;

ALTER TABLE departments
    ADD CONSTRAINT dept_loc_fk FOREIGN KEY ( location_id )
        REFERENCES locations ( location_id )
    ENABLE;

ALTER TABLE departments
    ADD CONSTRAINT dept_mgr_fk FOREIGN KEY ( manager_id )
        REFERENCES employees ( employee_id )
    ENABLE;

ALTER TABLE employment
    ADD CONSTRAINT employment_fk1 FOREIGN KEY ( employee_id )
        REFERENCES employees ( employee_id )
    ENABLE;

ALTER TABLE employment
    ADD CONSTRAINT employment_fk2 FOREIGN KEY ( job_id )
        REFERENCES jobs ( job_id )
    ENABLE;

ALTER TABLE employment
    ADD CONSTRAINT employment_fk3 FOREIGN KEY ( department_id )
        REFERENCES departments ( department_id )
    ENABLE;

CREATE OR REPLACE VIEW "SHERRING"."V_EMPLOYEE" (
    "EMPLOYEE_ID",
    "FIRST_NAME",
    "LAST_NAME",
    "EMAIL",
    "PHONE_NUMBER",
    "START_DATE"
) AS
    SELECT
        employees.employee_id,
        first_name,
        last_name,
        email,
        phone_number,
        start_date
    FROM
        employees,
        employment,
        employment_pay;

CREATE VIEW v_employment AS
    SELECT
        employment.employee_id,
        first_name,
        last_name,
        email,
        phone_number start_date,
        salary,
        commission_pct
    FROM
        employees,
        employment,
        employment_pay;

CREATE SEQUENCE "SHERRING"."EMPLOYEES_SEQ" MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20
NOORDER NOCYCLE NOKEEP NOSCALE GLOBAL;

CREATE SEQUENCE "SHERRING"."EMPLOYMENT_SEQ" MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20
NOORDER NOCYCLE NOKEEP NOSCALE GLOBAL;

CREATE OR REPLACE TRIGGER trg_employees_pk BEFORE
    INSERT ON employment
    FOR EACH ROW
BEGIN
    << column_sequences >> BEGIN
        IF inserting THEN
            SELECT
                employees_seq.NEXTVAL
            INTO :new.employee_id
            FROM
                sys.dual;

        END IF;
    END column_sequences;
END;

CREATE OR REPLACE TRIGGER trg_employment_pk BEFORE
    INSERT ON employment
    FOR EACH ROW
BEGIN
    << column_sequences >> BEGIN
        IF inserting THEN
            SELECT
                employment_seq.NEXTVAL
            INTO :new.employment_id
            FROM
                sys.dual;

        END IF;
    END column_sequences;
END;

DECLARE
    v_start_value  NUMBER(9);
    v_sql          VARCHAR2(2000);
    v_cnt          NUMBER(1);
BEGIN
    SELECT
        nvl(MAX(employee_id), 0) + 1
    INTO v_start_value
    FROM
        employees;

    SELECT
        COUNT(*)
    INTO v_cnt
    FROM
        user_sequences
    WHERE
        sequence_name = 'EMPLOYEES_SEQ';

    IF v_cnt = 1 THEN
        v_sql := 'DROP SEQUENCE EMPLOYEES_SEQ';
    END IF;
    EXECUTE IMMEDIATE v_sql;
    v_sql := 'CREATE SEQUENCE EMPLOYEES_SEQ START WITH ' || v_start_value;
    EXECUTE IMMEDIATE v_sql;
    dbms_ddl.alter_compile('TRIGGER', user, 'TRG_EMPOLYEES_PK');
END;

DECLARE
    v_start_value  NUMBER(9);
    v_sql          VARCHAR2(2000);
    v_cnt          NUMBER(1);
BEGIN
    SELECT
        nvl(MAX(employment_id), 0) + 1
    INTO v_start_value
    FROM
        employment;

    SELECT
        COUNT(*)
    INTO v_cnt
    FROM
        user_sequences
    WHERE
        sequence_name = 'EMPLOYMENT_SEQ';

    IF v_cnt = 1 THEN
        v_sql := 'DROP SEQUENCE EMPLOYMENT_SEQ';
    END IF;
    EXECUTE IMMEDIATE v_sql;
    v_sql := 'CREATE SEQUENCE EMPLOYMENT_SEQ START WITH ' || v_start_value;
    EXECUTE IMMEDIATE v_sql;
    dbms_ddl.alter_compile('TRIGGER', user, 'TRG_EMPOLYMENT_PK');
END;

CREATE OR REPLACE TRIGGER trg_countries_fp BEFORE
    INSERT OR UPDATE ON countries
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.updated_by := user;
    :new.updated_date := sysdate;
END;

CREATE OR REPLACE TRIGGER trg_departments_fp BEFORE
    INSERT OR UPDATE ON departments
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.updated_by := user;
    :new.updated_date := sysdate;
END;

CREATE OR REPLACE TRIGGER trg_employees_fp BEFORE
    INSERT OR UPDATE ON employees
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.updated_by := user;
    :new.updated_date := sysdate;
END;

CREATE OR REPLACE TRIGGER trg_employment_fp BEFORE
    INSERT OR UPDATE ON employment
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.updated_by := user;
    :new.updated_date := sysdate;
END;

CREATE OR REPLACE TRIGGER trg_employment_pay_fp BEFORE
    INSERT OR UPDATE ON employment_pay
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.updated_by := user;
    :new.updated_date := sysdate;
END;

CREATE OR REPLACE TRIGGER trg_jobs_fp BEFORE
    INSERT OR UPDATE ON jobs
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.updated_by := user;
    :new.updated_date := sysdate;
END;

CREATE OR REPLACE TRIGGER trg_locations_fp BEFORE
    INSERT OR UPDATE ON locations
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.updated_by := user;
    :new.updated_date := sysdate;
END;

CREATE OR REPLACE TRIGGER trg_regions_fp BEFORE
    INSERT OR UPDATE ON regions
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.updated_by := user;
    :new.updated_date := sysdate;
END;

CREATE OR REPLACE PROCEDURE secure_rows AS
    e_not_in_time_window EXCEPTION;
    PRAGMA exception_init ( e_not_in_time_window, -12120 );
BEGIN
    IF sysdate - trunc(sysdate) BETWEEN 7.0 / 24 AND 18.0 / 24 THEN
        RAISE e_not_in_time_window;
    END IF;
END secure_rows;

CREATE OR REPLACE TRIGGER trg_departments_secure_rows BEFORE
    DELETE OR INSERT OR UPDATE ON departments
BEGIN
    secure_rows;
END;

CREATE OR REPLACE TRIGGER trg_countries_secure_rows BEFORE
    DELETE OR INSERT OR UPDATE ON countries
BEGIN
    secure_rows;
END;

CREATE OR REPLACE TRIGGER trg_employees_secure_rows BEFORE
    DELETE OR INSERT OR UPDATE ON employees
BEGIN
    secure_rows;
END;

CREATE OR REPLACE TRIGGER trg_employment_secure_rows BEFORE
    DELETE OR INSERT OR UPDATE ON employment
BEGIN
    secure_rows;
END;

CREATE OR REPLACE TRIGGER trg_employment_pay_secure_rows BEFORE
    DELETE OR INSERT OR UPDATE ON employment_pay
BEGIN
    secure_rows;
END;

CREATE OR REPLACE TRIGGER trg_jobs_secure_rows BEFORE
    DELETE OR INSERT OR UPDATE ON jobs
BEGIN
    secure_rows;
END;

CREATE OR REPLACE TRIGGER trg_locations_secure_rows BEFORE
    DELETE OR INSERT OR UPDATE ON locations
BEGIN
    secure_rows;
END;

CREATE OR REPLACE TRIGGER trg_regions_secure_rows BEFORE
    DELETE OR INSERT OR UPDATE ON regions
BEGIN
    secure_rows;
END;

CREATE OR REPLACE TRIGGER trg_employment_pay_chk BEFORE
    INSERT OR UPDATE ON employment_pay
    FOR EACH ROW
BEGIN
    SELECT
        min_salary,
        max_salary
    INTO temp_table
    FROM
             employment_pay
        INNER JOIN jobs ON employment_pay.employment_id = (
            SELECT
                employment.employment_id
            FROM
                     employment
                INNER JOIN jobs ON employment.job_id = jobs.job_id
        );

    IF temp_table.min_salary IS NOT NULL THEN
        IF :new.salary < temp_table.min_salary THEN
            raise_application_error(-12121,
                                   'Salary must be greater than the minimum salary for this job!');
        END IF;

    END IF;

    IF temp_table.max_salary IS NOT NULL THEN
        IF :new.salary > temp_table.max_salary THEN
            raise_application_error(-12122,
                                   'Salary must be less than the maximum salary for this job!');
        END IF;
    END IF;

END;

CREATE OR REPLACE TRIGGER trg_locations_chk BEFORE
    INSERT OR UPDATE ON locations
    FOR EACH ROW
BEGIN
    IF :new.country_id = 'US' THEN
        IF NOT regexp_like(:new.postal_code, '([[:digit:]]{5})(-[[:digit:]]{4})?$') THEN
            raise_application_error(-12122, 'Postal code must exist!');
        END IF;

    ELSIF :new.country_id = 'CA' THEN
        IF NOT regexp_like(:new.postal_code, '^[ABCEGHJKLMNPRSTVXY][0-9][ABCEGHJKLMNPRSTVWXYZ][ -]?[0-9][ABCEGHJKLMNPRSTVWXYZ][0-9]$')
        THEN
            raise_application_error(-12122, 'Postal code must exist!');
        END IF;
    END IF;
END;

CREATE OR REPLACE TRIGGER trg_jobs_chk BEFORE
    INSERT OR UPDATE ON jobs
    FOR EACH ROW
BEGIN
    IF
        :new.min_salary IS NOT NULL
        AND :new.max_salary IS NOT NULL
    THEN
        IF NOT :new.min_salary < :new.max_salary THEN
            raise_application_error(-12123, 'Minimum salary must be less than the maximum!');
        END IF;

    END IF;
END;