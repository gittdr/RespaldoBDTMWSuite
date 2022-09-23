SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
	
CREATE PROCEDURE [dbo].[recreate_city_archive_tables_sp](@pl_drop varchar(20))
as

/*
*
* NAME:recreate_city_archive_tables
* dbo.recreate_city_archive_tables
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* THIS PROCEDURE MUST BE RUN AS DATBASE OWNER (SYSTEM ADMINISTRATOR)
* Usage: exec recreate_city_archive_tables_sp 'DROP TABLES'
* 
* Recreates archive tables for city and cityzip
* Records them in GI settings: CityArchiveCreated and CityZipArchiveCreated
* 	gi_string is Action (Table Created, Table Recreated, Table Processed)
*	gi_date1 is Date of last update
*	gi_interger1 is Version of city/cityzip table at time of archive creation.
*
* RETURNS:  
*
* RESULT SETS: 
* 	Messages indicating success or failure 
* PARAMETERS:
* 001 pl_drop 		Flag to force dropping of existing tables. 
*					Must be set to 'DROP TABLES' for tables to be created.
* REFERENCES: (called by AND calling references only, don't 
*              include table/view/object references)
* N/A
* 
* city
* 
* REVISION HISTORY:
* 07/20/07 PTS 32403 - EMK - Created
*/

declare @ver int, @pl_flag int,@pl_city_flag int, @pl_zip_flag int,@num_rows int
SELECT @pl_flag = 0, @pl_city_flag =0, @pl_zip_flag=0

if @pl_drop = 'DROP TABLES' SET @pl_flag=1

If exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.cityarchive') and OBJECTPROPERTY(id, N'IsUserTable') = 1) SET @pl_city_flag = 1
If exists (select * from dbo.sysobjects where id = object_id(N'dbo.cityziparchive') and OBJECTPROPERTY(id, N'IsUserTable') = 1) SET @pl_zip_flag = 1

If (@pl_city_flag = 1 OR @pl_zip_flag =1) AND (@pl_flag <> 1)
	BEGIN
		SELECT 'CITYARCHIVE or CITYZIPARCHIVE tables EXIST.  You must set the drop flag to DROP TABLES to drop and recreate tables.'
		SELECT  count(*) as 'CityArchive Records' from cityarchive 
		SELECT  count(*) as 'CityZipArchive Records' from cityziparchive 
	
	END
ELSE
	BEGIN
		--
		-- CREATE CITYARCHIVE
		--
		If @pl_city_flag = 1 
			BEGIN
				drop table cityarchive
				SELECT 'CITYARCHIVE TABLE DROPPED.'
			END


		SELECT * INTO cityarchive FROM city WHERE 1=2
		
		ALTER TABLE cityarchive ADD CONSTRAINT pk_cityarchive PRIMARY KEY CLUSTERED (cty_code)
		GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.cityarchive TO PUBLIC
	
		--Enter the current version of the city table in General Info
		SELECT @ver = IsNull(schema_ver,0) FROM dbo.sysobjects WHERE id = object_id(N'dbo.city')
		
		--Check for instance of CityArchiveCreated GI setting
		IF not exists (SELECT * FROM GeneralInfo WHERE gi_name = 'CityArchiveCreated')
			-- First time process run
			INSERT INTO GeneralInfo (gi_name,gi_datein, gi_string1,gi_integer1, gi_date1,gi_description)
		   	VALUES ('CityArchiveCreated', getdate(), 'Table Created',@ver,getdate(), 'Schema version of city table when cityarchive was created.')
		ELSE
			--This process has been run once, but the cityarchive table was deleted
			UPDATE GeneralInfo SET  gi_string1 = 'Table Recreated' ,gi_integer1=@ver,gi_date1 = getdate(),
					 gi_description = 'Schema version of city table when cityarchive was created.'  WHERE gi_name = 'CityArchiveCreated'
		--
		-- CREATE CITYZIPARCHIVE
		--

		If @pl_zip_flag = 1 
			BEGIN
				drop table cityziparchive
				SELECT 'CITYZIPARCHIVE TABLE DROPPED.'
			END
	
		SELECT * INTO cityziparchive FROM cityzip WHERE 1=2
		
		ALTER TABLE cityziparchive ADD CONSTRAINT pk_cityziparchive PRIMARY KEY CLUSTERED (zip,cty_code)
		GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.cityziparchive TO PUBLIC
	
		--Enter the current version of the cityzip table in General Info
		SELECT @ver = IsNull(schema_ver,0) FROM dbo.sysobjects WHERE id = object_id(N'dbo.cityzip')
	
		--Check for instance of CityZipArchive created
		IF not exists (SELECT * FROM GeneralInfo WHERE gi_name = 'CityZipArchiveCreated')
			-- First time process run
			INSERT INTO GeneralInfo (gi_name,gi_datein, gi_string1,gi_integer1,gi_date1, gi_description)
			   VALUES ('CityZipArchiveCreated', getdate(), 'Table Created',@ver,getdate(), 'Schema version of cityzip table when cityziparchive was created.')
		ELSE
			--This process has been run once, but the cityziparchive table was deleted
			UPDATE GeneralInfo SET gi_string1 = 'Table Recreated' ,gi_integer1=@ver, gi_date1 = getdate(),
				gi_description = 'Schema version of cityzip table when cityziparchive was created.'  WHERE gi_name = 'CityZipArchiveCreated'
		
		SELECT gi_name,gi_date1 from GeneralInfo where gi_name in('CityArchiveCreated','CityZipArchiveCreated')
	END
	
GO
GRANT EXECUTE ON  [dbo].[recreate_city_archive_tables_sp] TO [public]
GO
