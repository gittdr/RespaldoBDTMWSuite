SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROC [dbo].[d_loadcompid_tariff_template_sp] @comp varchar(8) , @number int, @parmlist varchar(254) AS
--  MODIFICATION LOG
----  PTS 46628  Proc Created.


DECLARE @daysout int, @match_rows int, @date datetime

DECLARE @rowsecurity	char(1)
DECLARE	@RowSecurityCustom char(1)
DECLARE	@RowSecurityCustomOverride char(1)
		
--PTS 53255 JJF 20101130
--PTS 42816 JJF 20080527
--DECLARE @tbl_cmprestrictedbyuser TABLE(Value VARCHAR(8))
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--END PTS 53255 JJF 20101130
DECLARE @tbl_cmprestrictedcustom TABLE(Value VARCHAR(8))

SELECT @RowSecurityCustom = gi_string1,
		@RowSecurityCustomOverride = gi_string2
FROM generalinfo 
WHERE gi_name = 'RowSecurityCustom'

IF @RowSecurityCustom = 'Y' BEGIN
	IF @RowSecurityCustomOverride = 'Y' BEGIN
		SELECT *
		 FROM  d_loadcompid_custom_fn(@comp, @number, @parmlist)

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
	--	INSERT INTO @tbl_cmprestrictedbyuser
	--	SELECT * FROM  rowrestrictbyuser_company_fn(@comp)
	--PTS 53255 JJF 20101130
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_company_fn() 
	--END PTS 53255 JJF 20101130
END
----END PTS 42816 JJF 20080527

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
--PTS 35461
else
	set rowcount 8


SELECT	top 1 Isnull(cmp_name ,'') as 'cmp_name',
		cmp_id , 
		IsNull(cmp_address1,'') as 'cmp_address1' ,
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
		cmp_contact = IsNull(cmp_contact,'') ,
		SUBSTRING(cmp_misc1,1,30) as 'cmp_misc1',
		Cmp_primaryphone,
		cmp_geoloc,
		cmp_city ,	
		IsNull(cmp_altid,'') as 'cmp_altid',		
		IsNull(cmp_address3,'')	as 'cmp_address3'	
		into #temp_COMPLIST					
		FROM company 

delete from #temp_COMPLIST		

		
if @daysout = 999
	if exists(SELECT cmp_name 
				FROM company 
				WHERE cmp_id LIKE @comp + '%'
						--PTS 53255 JJF 20101130
						--AND (EXISTS(select * FROM @tbl_cmprestrictedbyuser cmpres WHERE company.cmp_id = cmpres.value)
						--	OR @rowsecurity <> 'Y')
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						--END PTS 53255 JJF 20101130
						AND (EXISTS(select * FROM @tbl_cmprestrictedcustom cmpres WHERE company.cmp_id = cmpres.value)
							OR @RowSecurityCustom <> 'Y')
						--END PTS 42816 JJF 20080527
				)
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0
else
	if exists(SELECT cmp_name 
				FROM company 
				WHERE cmp_id LIKE @comp + '%' 
						AND (cmp_active = 'Y' OR cmp_active is null)
						--PTS 53255 JJF 20101130
						--AND (EXISTS(select * FROM @tbl_cmprestrictedbyuser cmpres WHERE company.cmp_id = cmpres.value)
						--	OR @rowsecurity <> 'Y')
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						--END PTS 53255 JJF 20101130
						AND (EXISTS(select * FROM @tbl_cmprestrictedcustom cmpres WHERE company.cmp_id = cmpres.value)
							OR @RowSecurityCustom <> 'Y')
						--END PTS 42816 JJF 20080527
				)
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0

--========================================================================================


if @match_rows > 0
	If Left(@comp,1)='_'
		if @daysout = 999
			INSERT INTO #temp_COMPLIST		
			SELECT Isnull(cmp_name ,''),
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
				IsNull(cmp_altid,''),
				--PTS# 19235 ILB 08/06/03
				--PTS 38461 EMK 	
				IsNull(cmp_address3,'')	
				--PTS 38461 EMK 				
						
				FROM company 
				WHERE cmp_id LIKE @comp + '%'
						AND LEFT(cmp_id,1)='_'
						--PTS 53255 JJF 20101130
						--AND (EXISTS(select * FROM @tbl_cmprestrictedbyuser cmpres WHERE company.cmp_id = cmpres.value)
						--	OR @rowsecurity <> 'Y')
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						--END PTS 53255 JJF 20101130
						AND (EXISTS(select * FROM @tbl_cmprestrictedcustom cmpres WHERE company.cmp_id = cmpres.value)
							OR @RowSecurityCustom <> 'Y')
						--END PTS 42816 JJF 20080527
				ORDER BY cmp_id 
				
		else
			INSERT INTO #temp_COMPLIST	
			SELECT Isnull(cmp_name ,''),
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
				IsNull(cmp_altid,''),
				--PTS# 19235 ILB 08/06/03		
				--PTS 38461 EMK 	
				IsNull(cmp_address3,'')	
				--PTS 38461 EMK 		 			
				FROM company 
				WHERE cmp_id LIKE @comp + '%'
						AND LEFT(cmp_id,1)='_'
						AND (cmp_active = 'Y' OR cmp_active is null)
						--PTS 53255 JJF 20101130
						--AND (EXISTS(select * FROM @tbl_cmprestrictedbyuser cmpres WHERE company.cmp_id = cmpres.value)
						--	OR @rowsecurity <> 'Y')
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						--END PTS 53255 JJF 20101130
						AND (EXISTS(select * FROM @tbl_cmprestrictedcustom cmpres WHERE company.cmp_id = cmpres.value)
							OR @RowSecurityCustom <> 'Y')
						--END PTS 42816 JJF 20080527
				ORDER BY cmp_id 
				
	ELSE
		if @daysout = 999
			INSERT INTO #temp_COMPLIST	
			SELECT Isnull(cmp_name ,''),
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
				IsNull(cmp_altid,''),
				--PTS# 19235 ILB 08/06/03
				--PTS 38461 EMK 	
				IsNull(cmp_address3,'')	
				--PTS 38461 EMK 				 			
				FROM company 
				WHERE cmp_id LIKE @comp + '%'
						--PTS 53255 JJF 20101130
						--AND (EXISTS(select * FROM @tbl_cmprestrictedbyuser cmpres WHERE company.cmp_id = cmpres.value)
						--	OR @rowsecurity <> 'Y')
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						--END PTS 53255 JJF 20101130
						AND (EXISTS(select * FROM @tbl_cmprestrictedcustom cmpres WHERE company.cmp_id = cmpres.value)
							OR @RowSecurityCustom <> 'Y')
						--END PTS 42816 JJF 20080527
				ORDER BY cmp_id 
				
		else
			INSERT INTO #temp_COMPLIST	
			SELECT Isnull(cmp_name ,''),
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
				IsNull(cmp_altid,''),
				--PTS# 19235 ILB 08/06/03
				--PTS 38461 EMK 	
				IsNull(cmp_address3,'')	
				--PTS 38461 EMK 		 		 			
				FROM company 
				WHERE cmp_id LIKE @comp + '%'
						AND (cmp_active = 'Y' OR cmp_active is null)
						--PTS 53255 JJF 20101130
						--AND (EXISTS(select * FROM @tbl_cmprestrictedbyuser cmpres WHERE company.cmp_id = cmpres.value)
						--	OR @rowsecurity <> 'Y')
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						--END PTS 53255 JJF 20101130
						AND (EXISTS(select * FROM @tbl_cmprestrictedcustom cmpres WHERE company.cmp_id = cmpres.value)
							OR @RowSecurityCustom <> 'Y')
						--END PTS 42816 JJF 20080527
				ORDER BY cmp_id 
				

else 
	INSERT INTO #temp_COMPLIST	
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
		IsNull(cmp_altid,''),
		--PTS# 19235 ILB 08/06/03
		--PTS 38461 EMK 	
		IsNull(cmp_address3,'')	
		--PTS 38461 EMK 				
		FROM company 
		WHERE cmp_id = 'UNKNOWN' 
		


set rowcount 0 


------------------
insert into #temp_COMPLIST	
values ('DEFAULT FROM ORDER', 'FRMORD', '','','','','','','','','','','','','','',NULL,'','','','' )
select * from  #temp_COMPLIST	

GO
GRANT EXECUTE ON  [dbo].[d_loadcompid_tariff_template_sp] TO [public]
GO
