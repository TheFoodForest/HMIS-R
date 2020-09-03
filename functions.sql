-- BELOW: function for yearly age - by gender, year, program type - num people enroll
--------------------------------- START SUMMARIZEAGE() -----------------------------
DROP FUNCTION IF EXISTS summarizeAge();
create or replace function summarizeAge()
returns table(date varchar,
			 "Project_Type" varchar,
			 "Age" varchar,
			 "Num_Clients" int)
LANGUAGE 'plpgsql'
as $$
declare 
rec RECORD;
begin
	create temp table yearly_age_temp 
			(date varchar,
			 "Project_Type" varchar,
			 "Age" varchar,
			 "Nun_Clients" int);
	FOR rec in 
	(SELECT DISTINCT to_char("Added_Date", 'YYYY') as yearvar FROM enrollment
		WHERE to_char("Added_Date", 'YYYY') > '2014')
	LOOP 
		insert into yearly_age_temp
			 (with t as (
				SELECT rec.yearvar::text as "Date",
				(to_char(MAX(e."Added_Date") OVER(
							PARTITION BY e."Client_Id"
									),'YYYY')::int - to_char(c."Birth_Date",'YYYY')::int)  "Age",
				 p."Project_Type_Group" as "Project_Type",
				 e."Client_Id"
				FROM enrollment e
				LEFT JOIN 
				clients c 
				ON e."Client_Id" = c."Client_Id"
				left join programs p
				on e."Program_Id" = p."Program_Id"
				left join exit_screen ex on ex."Enrollment_Id" = e."Enrollment_Id"
				WHERE e."Added_Date" <> '2014-01-01'
				AND TO_CHAR(e."Added_Date", 'YYYY') <= rec.yearvar::text
				and (ex."Exit_Date" > cast((rec.yearvar::text || '-01-01') as date) 
					 or ex."Exit_Date" is null)
				and c."Birth_Date" is not null
				ORDER BY "Date", p."Project_Type_Group", "Age"
				)
			select rec.yearvar::text as "Date", t."Project_Type", 
			  t."Age", count(distinct t."Client_Id") as "Num_Clients" 
			  from t
			Where t."Age" < 100
			group by t."Date", t."Project_Type", t."Age"
			order by t."Date", t."Project_Type");
	END LOOP;
	RETURN QUERY
	SELECT * from yearly_age_temp;
	drop table if exists yearly_age_temp;
END $$; 
select * from summarizeAge();
--------------------------------- END SUMMARIZEAGE() -----------------------------




-- BELOW: function for summarizing yearly gender - by gender, year, program type - num people enroll

--------------------------------- START SUMMARIZEGENDER() -----------------------------
drop function if exists summarizeGender();
CREATE OR REPLACE FUNCTION summarizeGender(
	)
    RETURNS TABLE(date character varying, "Project_Type" character varying, "Gender" character varying, num_people_enroll integer) 
    LANGUAGE 'plpgsql'

AS $$
declare 
rec RECORD;
begin
	create temp table yearly_gender_temp 
			(date varchar,
			 "Project_Type" varchar,
			 "Gender" varchar,
			 num_people_enroll int);
	FOR rec in 
	(SELECT DISTINCT to_char("Added_Date", 'YYYY') as yearvar FROM enrollment
		WHERE to_char("Added_Date", 'YYYY') > '2014')
	LOOP 
		insert into yearly_gender_temp
			SELECT rec.yearvar::text as Date,
			p."Project_Type_Group" as "Project_Type",
			c."Gender", 
			COUNT(distinct e."Client_Id") Num_People_Enroll
			FROM enrollment e
			LEFT JOIN clients c
			ON e."Client_Id" = c."Client_Id"
			left join programs p
			on e."Program_Id" = p."Program_Id"
			left join exit_screen ex
			on e."Enrollment_Id" = ex."Enrollment_Id"
			WHERE e."Added_Date" <> '2014-01-01'
			AND TO_CHAR(e."Added_Date", 'YYYY') <= rec.yearvar::text
			and (ex."Exit_Date" > cast((rec.yearvar::text || '-01-01') as date)
				OR ex."Exit_Date" IS NULL)
			GROUP BY date, p."Project_Type_Group", c."Gender"
			ORDER BY date, p."Project_Type_Group", c."Gender";
	END LOOP;
	RETURN QUERY
	SELECT * from yearly_gender_temp;
	drop table if exists yearly_gender_temp;
END $$;
select * from summarizeGender();
--------------------------------- END SUMMARIZEGENDER() -----------------------------




-- BELOW: function that returns table summary of race - by race, year, program type - num people enroll
--------------------------------- START SUMMARIZERACE() -----------------------------
DROP FUNCTION IF EXISTS summarizeRace()
CREATE OR REPLACE FUNCTION summarizeRace(
	)
    RETURNS TABLE(date character varying, "Project_Type" character varying, "Race" character varying, num_people_enroll integer) 
    LANGUAGE 'plpgsql'
AS $$
declare 
rec RECORD;
begin
	create temp table yearly_race_temp 
			(date varchar,
			 "Project_Type" varchar,
			 "Race" varchar,
			 num_people_enroll int);
	FOR rec in 
	(SELECT DISTINCT to_char("Added_Date", 'YYYY') as yearvar FROM enrollment
		WHERE to_char("Added_Date", 'YYYY') > '2014')
	LOOP 
		INSERT INTO yearly_race_temp
			SELECT rec.yearvar::text as Date,
			p."Project_Type_Group" as "Project_Type",
			c."Race", 
			COUNT(distinct e."Client_Id") Num_People_Enroll
			FROM enrollment e
			LEFT JOIN clients c
			ON e."Client_Id" = c."Client_Id"
			left join programs p
			on e."Program_Id" = p."Program_Id"
			left join exit_screen ex on ex."Enrollment_Id" = e."Enrollment_Id"
			WHERE e."Added_Date" <> '2014-01-01'
			AND TO_CHAR(e."Added_Date", 'YYYY') <= rec.yearvar::text
			and (ex."Exit_Date" > cast((rec.yearvar::text || '-01-01') as date)
				OR ex."Exit_Date" IS NULL)
			GROUP BY date, p."Project_Type_Group", c."Race"
			ORDER BY date, p."Project_Type_Group";
	END LOOP;	
	RETURN QUERY
	SELECT * from yearly_race_temp;
	drop table if exists yearly_race_temp;
END $$;
select * from summarizeRace();
--------------------------------- END SUMMARIZERACE() -----------------------------

