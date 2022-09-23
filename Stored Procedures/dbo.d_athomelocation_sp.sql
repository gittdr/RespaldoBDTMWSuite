SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_athomelocation_sp] @p_comp varchar(30) , @p_number int AS 
/*
 * 
 * NAME:
 * dbo.d_athomelocation_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns companies that are flagged as At Home locations for instant best match
 *
 *
 * RESULT SETS: 
 * cmp_name
 * cmp_id
 * cmp_address1
 * cmp_address2
 * cty_nmstct
 * cmp_defaultbillto         
 *	cmp_defaultpriority
 *	cmp_zip
 *	cmp_subcompany
 *	cmp_currency
 *	cmp_mileagetable
 *	cmp_shipper
 *	cmp_consingee
 *	cmp_billto
 *	cmp_contact
 *	cmp_misc1
 *	cmp_primaryphone
 *	cmp_geoloc
 *	cmp_city
 * cmp_altid
 *
 * PARAMETERS:
 * 001 - @p_comp, varchar(30), input
 *       The string that is to be searched for in the company id
 * 002 - @p_number, int, input,
 *       The number of matches to return
 *
 * 
 * REVISION HISTORY:
 * 11/02/2005 ? PTS29829 - Jason Bauwin ? Initial Release
 *
*/

DECLARE @v_daysout int, @v_match_rows int, @v_date datetime
SELECT  @v_daysout = -90

--vjh 31536
if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
select @v_daysout = lbp_daysout, 
	@v_date = lbp_date
	from ListBoxProperty
	where lbp_id=@@spid
else
SELECT  @v_daysout = gi_integer1, 
	@v_date = gi_date1 
  FROM generalinfo 
 WHERE gi_name = 'GRACE'

if @p_number = 1 
	set rowcount 1 
else if @p_number <= 8 
	set rowcount 8
else if @p_number <= 16
	set rowcount 16
else if @p_number <= 24
	set rowcount 24
else
	set rowcount 8

if @v_daysout = 999
	if exists(SELECT cmp_name FROM company WHERE cmp_id LIKE @p_comp + '%' and isnull(cmp_athome_location,'N') = 'Y')
		SELECT @v_match_rows = 1
	else
		SELECT @v_match_rows = 0
else
	if exists(SELECT cmp_name FROM company WHERE cmp_id LIKE @p_comp + '%' AND (cmp_active = 'Y' OR cmp_active is null)and isnull(cmp_athome_location,'N') = 'Y')
		SELECT @v_match_rows = 1
	else
		SELECT @v_match_rows = 0


if @v_match_rows > 0
	If Left(@p_comp,1)='_'
		if @v_daysout = 999
			SELECT	Isnull(cmp_name ,''),
				cmp_id ,
				IsNull(cmp_address1,'') ,
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
				cmp_primaryphone,
				cmp_geoloc = IsnUll(cmp_geoloc,''),	
				cmp_city ,			
				IsNull(cmp_altid,'')
				FROM company 
				WHERE cmp_id LIKE @p_comp + '%'
				  AND LEFT(cmp_id,1)='_'
				ORDER BY cmp_id 
		else
			SELECT	Isnull(cmp_name ,''),
				cmp_id ,
				IsNull(cmp_address1,'') ,
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
				cmp_contact = IsNull(cmp_contact,''),
				SUBSTRING(cmp_misc1,1,30),
				Cmp_primaryphone,
				cmp_geoloc = IsnUll(cmp_geoloc,''),
				cmp_city ,
				IsNull(cmp_altid,'')
				FROM company 
				WHERE cmp_id LIKE @p_comp + '%'
				  AND LEFT(cmp_id,1)='_'
				  AND (cmp_active = 'Y' OR cmp_active is null)
              AND isnull(cmp_athome_location,'N') = 'Y'
				ORDER BY cmp_id 

	ELSE
		if @v_daysout = 999
			SELECT	Isnull(cmp_name ,''),
				cmp_id ,
				IsNull(cmp_address1,'') ,
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
				cmp_contact = IsNull(cmp_contact,''),
				SUBSTRING(cmp_misc1,1,30),
				cmp_primaryphone,
				cmp_geoloc = IsnUll(cmp_geoloc,''),
				cmp_city ,
				IsNull(cmp_altid,'')
				FROM company 
				WHERE cmp_id LIKE @p_comp + '%'
              and isnull(cmp_athome_location,'N') = 'Y'
				ORDER BY cmp_id 
		else
			SELECT	Isnull(cmp_name ,''),
				cmp_id ,
				IsNull(cmp_address1,'') ,
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
				cmp_contact = IsNull(cmp_contact,''),
				SUBSTRING(cmp_misc1,1,30),
				Cmp_primaryphone,
				cmp_geoloc = IsnUll(cmp_geoloc,''),
				cmp_city ,
				IsNull(cmp_altid,'')
				FROM company 
				WHERE cmp_id LIKE @p_comp + '%'
				AND (cmp_active = 'Y' OR cmp_active is null)
            and isnull(cmp_athome_location,'N') = 'Y'
				ORDER BY cmp_id 

else 
	SELECT	Isnull(cmp_name ,''),
		cmp_id , 
		IsNull(cmp_address1,'') ,
		cmp_address2 ,
		cty_nmstct ,
		cmp_defaultbillto,
		cmp_defaultpriority,
		cmp_zip,
		cmp_subcompany,
		cmp_currency,
		cmp_mileagetable,
		cmp_shipper,
		cmp_consingee,
		cmp_billto,
		cmp_contact = IsNull(cmp_contact,''),
		SUBSTRING(cmp_misc1,1,30),
		Cmp_primaryphone,
		'',
		cmp_city ,
		IsNull(cmp_altid,'')
		FROM company 
		WHERE cmp_id = 'UNKNOWN' 

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_athomelocation_sp] TO [public]
GO
