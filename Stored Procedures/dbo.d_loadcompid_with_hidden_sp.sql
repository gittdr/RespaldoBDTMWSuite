SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
DPETE 17782 add primaryphone, goloc and city to match other dddw
*/
create PROC [dbo].[d_loadcompid_with_hidden_sp] @comp varchar(8) , @number int AS
DECLARE @match_rows int

DECLARE @rowsecurity	char(1)

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
--END PTS 42816 JJF 20080527

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
--PTS 35461/PTS 64942 JJF 20130501
else if @number > 24 
    set rowcount @number
--END PTS 35461/PTS 64942 JJF 20130501
else
	set rowcount 8
if exists(SELECT cmp_name 
			FROM company 
			WHERE cmp_id LIKE @comp + '%'
					--PTS 53255 JJF 20101130
					AND	(	(@rowsecurity <> 'Y')
							OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)
					--END PTS 53255 JJF 20101130
		)
	SELECT @match_rows = 1
else
	SELECT @match_rows = 0
if @match_rows > 0

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
                cmp_parent,
		--PTS# 19235 ILB 08/06/03
                IsNull(cmp_altid,''),
		--PTS# 19235 ILB 08/06/03	
      cmp_primaryphone ,
      cmp_geoloc,
      cmp_city	
		FROM company 
		WHERE cmp_id LIKE @comp + '%'
				--PTS 53255 JJF 20101130
				AND	(	(@rowsecurity <> 'Y')
						OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
					)
				--END PTS 53255 JJF 20101130
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
                cmp_parent,
		--PTS# 19235 ILB 08/06/03
                IsNull(cmp_altid,''),
		--PTS# 19235 ILB 08/06/03
                cmp_primaryphone ,
                cmp_geoloc,
                cmp_city			
		FROM company 
		WHERE cmp_id = 'UNKNOWN' 
set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadcompid_with_hidden_sp] TO [public]
GO
