SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create  PROC [dbo].[d_loadshipconscompname_sp] @comp varchar(100) , @number int AS
DECLARE @daysout int, @match_rows int, @date datetime

--PTS 42816 JJF 20080527
DECLARE @rowsecurity	char(1)
--END PTS 42816 JJF 20080527			

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

--PTS75456 JJF 20140724
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)

SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'


IF @rowsecurity = 'Y' BEGIN
	--PTS75456 JJF 20140724
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_company_fn()
END

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
				WHERE cmp_name LIKE @comp + '%' 
						and (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
								-- PTS 27259 -- BL (start)
								--			when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
								-- PTS 27259 -- BL (end)
									else 'N' end) = 'Y' 
						--PTS75456 JJF 20140724
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
				)
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0
else
	if exists(SELECT cmp_name 
				FROM company 
				WHERE cmp_name LIKE @comp + '%' 
						and (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
						-- PTS 27259 -- BL (start)
						--				when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
						-- PTS 27259 -- BL (end)
								else 'N' end) = 'Y' 
						AND (cmp_active = 'Y' OR cmp_active is null)
						--PTS75456 JJF 20140724
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
				)
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0

-- pts 12917 dsk '_' is a wild card so account for it as a literal
if @match_rows > 0
	If Left(@comp,1)='_'
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
				ISNULL(cmp_altid,'')		
				FROM company 
				WHERE cmp_name LIKE @comp + '%' 
					AND LEFT(cmp_name,1)='_'
					AND (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
							-- PTS 27259 -- BL (start)
							--						when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
							-- PTS 27259 -- BL (end)
							else 'N' end)= 'Y'
					--PTS75456 JJF 20140724
					AND	(	(@rowsecurity <> 'Y')
							OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)

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
				SUBSTRING(cmp_misc1,1,30),
				ISNULL(cmp_altid,'')		
				FROM company 
				WHERE cmp_name LIKE @comp + '%' 
					AND LEFT(cmp_name,1)='_'
					and (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
						-- PTS 27259 -- BL (start)
						--						when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
						-- PTS 27259 -- BL (end)
						else 'N' end)= 'Y'
					AND (cmp_active = 'Y' OR cmp_active is null)
					--PTS75456 JJF 20140724
					AND	(	(@rowsecurity <> 'Y')
							OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)

				ORDER BY cmp_name 
	Else
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
				ISNULL(cmp_altid,'')		
				FROM company 
				WHERE cmp_name LIKE @comp + '%' 
					AND (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
					-- PTS 27259 -- BL (start)
					--						when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
					-- PTS 27259 -- BL (end)
						else 'N' end)= 'Y'
					--PTS75456 JJF 20140724
					AND	(	(@rowsecurity <> 'Y')
							OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)

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
				SUBSTRING(cmp_misc1,1,30),
				ISNULL(cmp_altid,'')		
				FROM company 
				WHERE cmp_name LIKE @comp + '%' 
					and (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
						-- PTS 27259 -- BL (start)
						--						when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
						-- PTS 27259 -- BL (end)
						else 'N' end)= 'Y'
					AND (cmp_active = 'Y' OR cmp_active is null)
					--PTS75456 JJF 20140724
					AND	(	(@rowsecurity <> 'Y')
							OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)

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
		ISNULL(cmp_altid,'')		
		FROM company 
		WHERE cmp_name = 'UNKNOWN' 
set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loadshipconscompname_sp] TO [public]
GO
