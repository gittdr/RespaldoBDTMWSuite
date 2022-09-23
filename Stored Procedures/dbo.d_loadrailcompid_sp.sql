SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- this proc created 12/15/98 to provide a list of bill to companies
-- only for the bill to company dddw 
--
/*
DPETE `17782 add cmp_altid (for Imari PTS), primaryphone, geoloc,city



*/
--PTS 38816 JJF 20080311 add parmlist
create PROC [dbo].[d_loadrailcompid_sp] @comp varchar(8) , @number int, @parmlist varchar(254) AS

DECLARE @daysout int, @match_rows int, @date datetime

--PTS 42816 JJF 20080527
DECLARE @rowsecurity	char(1),
		@RowSecurityCustom char(1),
		@RowSecurityCustomOverride char(1)
--END PTS 42816 JJF 20080527			

--PTS75456 JJF 20140724
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)

DECLARE @tbl_cmprestrictedcustom TABLE(Value VARCHAR(8))

SELECT @RowSecurityCustom = gi_string1,
		@RowSecurityCustomOverride = gi_string2
FROM generalinfo 
WHERE gi_name = 'RowSecurityCustom'

IF @RowSecurityCustom = 'Y' BEGIN
	IF @RowSecurityCustomOverride = 'Y' BEGIN
		SELECT *
		 FROM  d_loadbillcompid_custom_fn(@comp, @number, @parmlist)

		IF @@ROWCOUNT > 0 BEGIN
			RETURN
		END
	END

	INSERT INTO @tbl_cmprestrictedcustom
	SELECT * FROM  rowrestrict_company_fn(@comp, 'DropDownLookup1001', @parmlist)
END 


SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN
	--PTS75456 JJF 20140724
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_company_fn()
END
--END PTS 42816 JJF 20080527


--vjh 31536
if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
select @daysout = lbp_daysout, 
	@date = lbp_date
	from ListBoxProperty
	where lbp_id=@@spid
else
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
	if exists(SELECT cmp_name 
				FROM company 
				WHERE cmp_id LIKE @comp + '%' 
						AND cmp_railramp = 'Y'
						--PTS75456 JJF 20140724
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						AND (EXISTS(select * FROM @tbl_cmprestrictedcustom cmpres WHERE company.cmp_id = cmpres.value)
							OR @RowSecurityCustom <> 'Y')
				)
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0
else
	if exists(SELECT cmp_name 
				FROM company 
				WHERE cmp_id LIKE @comp + '%' 
						AND (cmp_active = 'Y' OR cmp_active is null) 
						AND cmp_railramp = 'Y'
						--PTS75456 JJF 20140724
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						AND (EXISTS(select * FROM @tbl_cmprestrictedcustom cmpres WHERE company.cmp_id = cmpres.value)
							OR @RowSecurityCustom <> 'Y')
			)
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
		        ISNULL(cmp_altid,''),
		        cmp_Primaryphone,
		        cmp_geoloc,
		        cmp_city				
			FROM company 
			WHERE cmp_id LIKE @comp + '%' 
			AND cmp_railramp = 'Y'
			--PTS75456 JJF 20140724
			AND	(	(@rowsecurity <> 'Y')
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
				)
			AND (EXISTS(select * FROM @tbl_cmprestrictedcustom cmpres WHERE company.cmp_id = cmpres.value)
				OR @RowSecurityCustom <> 'Y')
			ORDER BY cmp_id 
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
			SUBSTRING(cmp_misc1,1,30),
			ISNULL(cmp_altid,''),
      			cmp_Primaryphone,
      			cmp_geoloc,
      			cmp_city				
			FROM company 
			WHERE cmp_id LIKE @comp + '%'
			AND cmp_railramp = 'Y'
			AND (cmp_active = 'Y' OR cmp_active is null)
			--PTS75456 JJF 20140724
			AND	(	(@rowsecurity <> 'Y')
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
				)
			AND (EXISTS(select * FROM @tbl_cmprestrictedcustom cmpres WHERE company.cmp_id = cmpres.value)
				OR @RowSecurityCustom <> 'Y')
			ORDER BY cmp_id 
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
		ISNULL(cmp_altid,''),
    		cmp_Primaryphone,
    		cmp_geoloc,
    		cmp_city				
		FROM company 
		WHERE cmp_id = 'UNKNOWN' 
	

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadrailcompid_sp] TO [public]
GO
