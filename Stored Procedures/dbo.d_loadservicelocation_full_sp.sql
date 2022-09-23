SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [dbo].[d_loadservicelocation_full_sp] @comp varchar(8) , @number int AS
--  MODIFICATION LOG
--DPETE PTS 12609 return geolocs for companies


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
--END PTS 42816 JJF 20080527

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
						AND cmp_service_location = 'Y'
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
				WHERE cmp_id LIKE @comp + '%' 
						AND (cmp_active = 'Y' OR cmp_active is null) 
						AND cmp_service_location = 'Y'
						--PTS75456 JJF 20140724
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
				)
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0


if @match_rows > 0
	If Left(@comp,1)='_'
		if @daysout = 999
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
				--PTS# 19235 ILB 08/06/03				
				IsNull(cmp_altid,'')
				--PTS# 19235 ILB 08/06/03		
				FROM company 
				WHERE cmp_id LIKE @comp + '%'
						AND LEFT(cmp_id,1)='_'
						AND cmp_service_location = 'Y'
						--PTS75456 JJF 20140724
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
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
				--PTS# 19235 ILB 08/06/03
				IsNull(cmp_altid,'')
				--PTS# 19235 ILB 08/06/03			 			
				FROM company 
				WHERE cmp_id LIKE @comp + '%'
						AND LEFT(cmp_id,1)='_'
						AND (cmp_active = 'Y' OR cmp_active is null)
						AND cmp_service_location = 'Y'
						--PTS75456 JJF 20140724
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
				ORDER BY cmp_id 

	ELSE
		if @daysout = 999
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
				--PTS# 19235 ILB 08/06/03				
				IsNull(cmp_altid,'')
				--PTS# 19235 ILB 08/06/03			 			
				FROM company 
				WHERE cmp_id LIKE @comp + '%'
						AND cmp_service_location = 'Y'
						--PTS75456 JJF 20140724
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
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
				--PTS# 19235 ILB 08/06/03				
				IsNull(cmp_altid,'')
				--PTS# 19235 ILB 08/06/03	 		 			
				FROM company 
				WHERE cmp_id LIKE @comp + '%'
						AND (cmp_active = 'Y' OR cmp_active is null)
						AND cmp_service_location = 'Y'
						--PTS75456 JJF 20140724
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
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
		--PTS# 19235 ILB 08/06/03		
		IsNull(cmp_altid,'')
		--PTS# 19235 ILB 08/06/03			
		FROM company 
		WHERE cmp_id = 'UNKNOWN' 

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadservicelocation_full_sp] TO [public]
GO
