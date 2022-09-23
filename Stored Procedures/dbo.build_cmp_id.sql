SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


Create procedure [dbo].[build_cmp_id] (@include_billto VARCHAR(1))
AS

DECLARE
@old_cmp_id 		VARCHAR(8),
@new_cmp_id		VARCHAR(8),
@prev_cmp_id		VARCHAR(8),
@duplicate_count	INT,
@increment		INT


select @increment = 1

BEGIN


   CREATE table temp_company (cmp_id VARCHAR(8) NULL,
				new_cmp_id VARCHAR(8) NULL)

   CREATE UNIQUE index idx_temp_company ON temp_company (cmp_id)

   IF @include_billto = 'Y' OR @include_billto Is Null
	BEGIN
	   INSERT INTO temp_company
	   SELECT cmp_id, 	SUBSTRING(
				LTRIM(RTRIM(SUBSTRING(cmp_name,1,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,2,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,3,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,4,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,5,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,6,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,7,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,8,1))), 1, 3) + 
				SUBSTRING(cty_nmstct, 1, 3)
	   FROM company
	   ORDER BY 		SUBSTRING(
				LTRIM(RTRIM(SUBSTRING(cmp_name,1,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,2,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,3,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,4,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,5,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,6,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,7,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,8,1))), 1, 3) + 
				SUBSTRING(cty_nmstct, 1, 3)
 	END
   ELSE
	BEGIN
	   INSERT INTO temp_company
	   SELECT cmp_id, 	SUBSTRING(
				LTRIM(RTRIM(SUBSTRING(cmp_name,1,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,2,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,3,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,4,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,5,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,6,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,7,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,8,1))), 1, 3) + 
				SUBSTRING(cty_nmstct, 1, 3)
	   FROM company
	   WHERE cmp_billto Is Null or cmp_billto = 'N'
	   ORDER BY 		SUBSTRING(
				LTRIM(RTRIM(SUBSTRING(cmp_name,1,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,2,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,3,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,4,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,5,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,6,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,7,1))) + 
				LTRIM(RTRIM(SUBSTRING(cmp_name,8,1))), 1, 3) + 
				SUBSTRING(cty_nmstct, 1, 3)
	END

   DECLARE companycursor CURSOR FOR
				SELECT 	 cmp_id, new_cmp_id
				FROM	 temp_company
				ORDER BY new_cmp_id
   OPEN companycursor

   FETCH NEXT FROM companycursor INTO @old_cmp_id, @new_cmp_id

   WHILE @@fetch_status = 0
   BEGIN
	SELECT	@duplicate_count = count(*)
	FROM	temp_company
	WHERE	new_cmp_id = @new_cmp_id AND
		cmp_id <> @old_cmp_id

	If @duplicate_count > 0
	BEGIN
		UPDATE  temp_company
		SET	new_cmp_id = @new_cmp_id + RTRIM(LTRIM(STR(@increment)))
		WHERE	cmp_id = @old_cmp_id	
	END 

	SELECT @prev_cmp_id = @new_cmp_id
	FETCH NEXT FROM companycursor INTO @old_cmp_id, @new_cmp_id

	IF @new_cmp_id <> @prev_cmp_id select @increment = 1
	IF @new_cmp_id = @prev_cmp_id select @increment = @increment + 1

   END



CLOSE companycursor
DEALLOCATE companycursor

DROP table company_temp1

SELECT * INTO company_temp1 
FROM	company

UPDATE company set cmp_id = t1.new_cmp_id
FROM temp_company t1
WHERE company.cmp_id = t1.cmp_id

DROP table temp_company

END


grant execute on build_cmp_id to PUBLIC



GO
