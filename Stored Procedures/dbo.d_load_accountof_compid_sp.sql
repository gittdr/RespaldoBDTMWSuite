SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create proc [dbo].[d_load_accountof_compid_sp] 
	@comp 		varchar(8) 
	,@number	int 
as

/**
 * 
 * NAME:
 * d_load_accountof_compid_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: NONE
 *
 * REVISION HISTORY:
 * PTS 39393 - 9/8/2007.01 - Dan Hudec ? Created Procedure
 *
 **/

DECLARE @daysout int
		,@match_rows int
		,@date datetime


SELECT  @daysout = -90
SELECT  @daysout = gi_integer1, 
        @date = gi_date1 
  FROM generalinfo 
 WHERE gi_name = 'GRACE'

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8


if @daysout = 999
	if exists(SELECT cmp_name FROM company WHERE cmp_id LIKE @comp + '%' AND cmp_supplier = 'Y')
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0
else
	if exists(SELECT cmp_name FROM company WHERE cmp_id LIKE @comp + '%' AND (cmp_active = 'Y' OR cmp_active is null) AND cmp_supplier = 'Y')
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0

if @match_rows > 0
	if @daysout = 999
		SELECT	Isnull(cmp_name ,'') ,
				cmp_id ,
				ISNULL (cmp_address1, '') ,
				cmp_address2 , 
				cty_nmstct,
				cmp_defaultbillto,
				cmp_defaultpriority,
				ISNULL (cmp_zip, '' ),
				cmp_subcompany,
				cmp_currency,
				cmp_mileagetable,
				cmp_shipper,
				cmp_consingee,
				cmp_billto,
				cmp_contact = Isnull(cmp_contact,''),
				SUBSTRING(cmp_misc1,1,30),
            cmp_Primaryphone,
            cmp_geoloc = IsNull(cmp_geoloc,''),
            cmp_city,
            cmp_altid		
		  FROM 	company 
		  WHERE cmp_id LIKE @comp + '%' 
			AND cmp_accountof = 'Y'
		  ORDER BY cmp_id 
	else
		SELECT	Isnull(cmp_name ,'') ,
				cmp_id ,
				ISNULL (cmp_address1, '') ,
				cmp_address2 , 
				cty_nmstct,
				cmp_defaultbillto,
				cmp_defaultpriority,
				ISNULL (cmp_zip, '' ),
				cmp_subcompany,
				cmp_currency,
				cmp_mileagetable,
				cmp_shipper,
				cmp_consingee,
				cmp_billto,
				cmp_contact = Isnull(cmp_contact,''),
				SUBSTRING(cmp_misc1,1,30)	,
            cmp_Primaryphone,
            cmp_geoloc = IsNull(cmp_geoloc,''),
            cmp_city,
            cmp_altid			
		  FROM 	company 
		  WHERE cmp_id LIKE @comp + '%'
			AND cmp_accountof = 'Y'
			AND (cmp_active = 'Y' OR cmp_active is null)
		  ORDER BY cmp_id 
else 
	SELECT	Isnull(cmp_name ,''),
		cmp_id , 
		ISNULL (cmp_address1, '') , 
		cmp_address2 ,
		cty_nmstct ,
		cmp_defaultbillto,
		cmp_defaultpriority,
		ISNULL (cmp_zip, '' ),
		cmp_subcompany,
		cmp_currency,
		cmp_mileagetable,
		cmp_shipper,
		cmp_consingee,
		cmp_billto,
		cmp_contact = Isnull(cmp_contact,''),
		SUBSTRING(cmp_misc1,1,30),
            cmp_Primaryphone,
            cmp_geoloc = IsNull(cmp_geoloc,''),
            cmp_city,
            cmp_altid				
		FROM company 
		WHERE cmp_id = 'UNKNOWN' 
set rowcount 0 
GO
GRANT EXECUTE ON  [dbo].[d_load_accountof_compid_sp] TO [public]
GO
