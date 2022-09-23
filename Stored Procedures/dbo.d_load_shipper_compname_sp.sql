SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create proc [dbo].[d_load_shipper_compname_sp] 
	--PTS 54990 JJF/SGB 20101209
	--@comp 		varchar(8) 
	@comp 		varchar(100) 
	--END PTS 54990 JJF/SGB 20101209
	,@number	int 
as

/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	----------------------------------------------
	06/04/2001	Vern Jewett		(none)	Original, copied from d_loadbillcompid_sp.
   	PTS17782     DPETE           Add columns to make match all other company dddws
	PTS38461 	EMK				Adde column address3
*/

DECLARE @daysout int
		,@match_rows int
		,@date datetime

DECLARE @rowsecurity	char(1)

SELECT  @daysout = -90
--vjh 31536
if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
select @daysout = lbp_daysout, 
	@date = lbp_date
	from ListBoxProperty
	where lbp_id=@@spid
else
SELECT  @daysout = gi_integer1, 
        @date = gi_date1 
  FROM generalinfo 
 WHERE gi_name = 'GRACE'

--PTS 53255 JJF 20101130
--PTS 42816 JJF 20080527
--DECLARE @tbl_cmprestrictedbyuser TABLE(Value VARCHAR(8))
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--END PTS 53255 JJF 20101130

SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN
	--PTS 53255 JJF 20101130
	--	INSERT INTO @tbl_cmprestrictedbyuser
	--	SELECT * FROM  rowrestrictbyuser_company_fn(@comp)
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_company_fn() 
	--END PTS 53255 JJF 20101130
END
----END PTS 42816 JJF 20080527

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
--PTS 35461
else if @number > 24 
    set rowcount @number
--END PTS 35461
else
	set rowcount 8


if @daysout = 999
-- PTS 24232 -- BL (start)
--	if exists(SELECT cmp_name FROM company WHERE cmp_id LIKE @comp + '%')
	if exists(SELECT cmp_name 
				FROM company 
				WHERE cmp_name LIKE @comp + '%' 
						AND cmp_shipper = 'Y'
						--PTS 53255 JJF 20101130
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						--END PTS 53255 JJF 20101130
				)
-- PTS 24232 -- BL (end)
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0
else
-- PTS 24232 -- BL (start)
--	if exists(SELECT cmp_name FROM company WHERE cmp_id LIKE @comp + '%' AND (cmp_active = 'Y' OR cmp_active is null))
	if exists(SELECT cmp_name 
				FROM company 
				WHERE cmp_name LIKE @comp + '%' 
						AND (cmp_active = 'Y' OR cmp_active is null) 
						AND cmp_shipper = 'Y'
						--PTS 53255 JJF 20101130
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						--END PTS 53255 JJF 20101130
				)
-- PTS 24232 -- BL (end)
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0

if @match_rows > 0
	if @daysout = 999
		SELECT	cmp_name ,
				cmp_id ,
				cmp_address1 ,
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
				cmp_contact,
				SUBSTRING(cmp_misc1,1,30),
            cmp_Primaryphone,
            cmp_geoloc,
            cmp_city,
            cmp_altid,
			--PTS 38461 EMK 	
			cmp_address3,
			--PTS 38461 EMK 		
			--PTS 64927 JJF 20130709
			cmp_revtype1,
			cmp_revtype2,
			cmp_revtype3,
			cmp_revtype4
			--END PTS 64927 JJF 20130709

		  FROM 	company 
		  WHERE cmp_name LIKE @comp + '%' 
			AND cmp_shipper = 'Y'
				--PTS 53255 JJF 20101130
				AND	(	(@rowsecurity <> 'Y')
						OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
					)
				--END PTS 53255 JJF 20101130
		  ORDER BY cmp_name 
	else
		SELECT	cmp_name ,
				cmp_id ,
				cmp_address1 ,
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
				cmp_contact,
				SUBSTRING(cmp_misc1,1,30)	,
            cmp_Primaryphone,
            cmp_geoloc,
            cmp_city,
            cmp_altid,
			--PTS 38461 EMK 	
			cmp_address3,
			--PTS 38461 EMK
			--PTS 64927 JJF 20130709
			cmp_revtype1,
			cmp_revtype2,
			cmp_revtype3,
			cmp_revtype4
			--END PTS 64927 JJF 20130709
		  FROM 	company 
		  WHERE cmp_name LIKE @comp + '%'
			AND cmp_shipper = 'Y'
			AND (cmp_active = 'Y' OR cmp_active is null)
				--PTS 53255 JJF 20101130
				AND	(	(@rowsecurity <> 'Y')
						OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
					)
				--END PTS 53255 JJF 20101130
		  ORDER BY cmp_name 
else 
	SELECT	cmp_name ,
		cmp_id , 
		cmp_address1 , 
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
		cmp_contact,
		SUBSTRING(cmp_misc1,1,30),
            cmp_Primaryphone,
            cmp_geoloc,
            cmp_city,
            cmp_altid,
			--PTS 38461 EMK 	
			cmp_address3,
			--PTS 38461 EMK 				
			--PTS 64927 JJF 20130709
			cmp_revtype1,
			cmp_revtype2,
			cmp_revtype3,
			cmp_revtype4
			--END PTS 64927 JJF 20130709
		FROM company 
		--PTS 53255 JJF 20101201 - this has potential for retrieving multiple 'UNKNOWN' companies
		--WHERE cmp_name = 'UNKNOWN' 
		WHERE cmp_id = 'UNKNOWN' 
		--END PTS 53255 JJF 20101201 - this has potential for retrieving multiple 'UNKNOWN' companies
set rowcount 0 
GO
GRANT EXECUTE ON  [dbo].[d_load_shipper_compname_sp] TO [public]
GO
