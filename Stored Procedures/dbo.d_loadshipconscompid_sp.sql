SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create  PROC [dbo].[d_loadshipconscompid_sp] @comp varchar(8) , @number int AS
DECLARE @daysout int, @match_rows int, @date datetime

/*
*	PTS 54076 - DJM - Added the columns cmp_address3,cmp_primaryphone,cmp_geoloc,cmp_city to result set to 
*		match requirements in Order Entry
*/

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

--PTS 53255 JJF 20101130  
--PTS 42816 JJF 20080527  
--DECLARE @tbl_cmprestrictedbyuser TABLE(Value VARCHAR(8))  
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)  
--END PTS 53255 JJF 20101130  



SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'


IF @rowsecurity = 'Y' BEGIN
	--INSERT INTO tbl_cmprestrictedbyuser
	--SELECT * FROM  rowrestrictbyuser_company_fn(@comp)

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
--PTS 35461/PTS 64942 JJF 20130501
else if @number > 24 
    set rowcount @number
--END PTS 35461/PTS 64942 JJF 20130501
else
	set rowcount 8
if @daysout = 999
	if exists(SELECT cmp_name 
				FROM company 
				WHERE cmp_id LIKE @comp + '%' 
						and (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
								-- PTS 27259 -- BL (start)
								--			when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
								-- PTS 27259 -- BL (end)
									else 'N' end) = 'Y' 
						--PTS 42816 JJF 20080527
						--PTS 38816 JJF 20070311 add parmlist
						--PTS 40136 JJF 20071112
						--AND dbo.RowRestrictByUser(cmp_BelongsTo, cmp_id, 'DropDownLookup1001', @parmlist) = 1
						--END PTS 40136 JJF 20071112
						  --PTS 53255 JJF 20101130  
						  AND ( (@rowsecurity <> 'Y')  
							OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)  
						   )  
						  --END PTS 53255 JJF 20101130  
						--END PTS 42816 JJF 20080527
				)
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0
else
	if exists(SELECT cmp_name 
				FROM company 
				WHERE cmp_id LIKE @comp + '%' 
						and (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
						-- PTS 27259 -- BL (start)
						--				when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
						-- PTS 27259 -- BL (end)
								else 'N' end) = 'Y' 
						AND (cmp_active = 'Y' OR cmp_active is null)
						--PTS 42816 JJF 20080527
						--PTS 38816 JJF 20070311 add parmlist
						--PTS 40136 JJF 20071112
						--AND dbo.RowRestrictByUser(cmp_BelongsTo, cmp_id, 'DropDownLookup1001', @parmlist) = 1
						--END PTS 40136 JJF 20071112
						  --PTS 53255 JJF 20101130  
						  AND ( (@rowsecurity <> 'Y')  
							OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)  
						   )  
						  --END PTS 53255 JJF 20101130  
						--END PTS 42816 JJF 20080527
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
				ISNULL(cmp_altid,''),	
				cmp_address3,
				cmp_primaryphone,
				cmp_geoloc,
				cmp_city
			FROM company 
			WHERE cmp_id LIKE @comp + '%' 
				AND LEFT(cmp_id,1)='_'
				AND (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
						-- PTS 27259 -- BL (start)
						--						when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
						-- PTS 27259 -- BL (end)
						else 'N' end)= 'Y'
				--PTS 42816 JJF 20080527
				--PTS 38816 JJF 20070311 add parmlist
				--PTS 40136 JJF 20071112
				--AND dbo.RowRestrictByUser(cmp_BelongsTo, cmp_id, 'DropDownLookup1001', @parmlist) = 1
				--END PTS 40136 JJF 20071112
				  --PTS 53255 JJF 20101130  
				  AND ( (@rowsecurity <> 'Y')  
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)  
				   )  
				  --END PTS 53255 JJF 20101130  
				--END PTS 42816 JJF 20080527

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
				cmp_primaryphone,
				cmp_geoloc,
				cmp_city,
				cmp_address3
				FROM company 
				WHERE cmp_id LIKE @comp + '%' 
					AND LEFT(cmp_id,1)='_'
					and (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
						-- PTS 27259 -- BL (start)
						--						when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
						-- PTS 27259 -- BL (end)
						else 'N' end)= 'Y'
					AND (cmp_active = 'Y' OR cmp_active is null)
					--PTS 42816 JJF 20080527
					--PTS 38816 JJF 20070311 add parmlist
					--PTS 40136 JJF 20071112
					--AND dbo.RowRestrictByUser(cmp_BelongsTo, cmp_id, 'DropDownLookup1001', @parmlist) = 1
					--END PTS 40136 JJF 20071112
					 --PTS 53255 JJF 20101130  
					 AND ( (@rowsecurity <> 'Y')  
						OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)  
					  )  
					--END PTS 53255 JJF 20101130  
					--END PTS 42816 JJF 20080527

				ORDER BY cmp_id 
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
				ISNULL(cmp_altid,''),	
				cmp_address3,
				cmp_primaryphone,
				cmp_geoloc,
				cmp_city
				FROM company 
				WHERE cmp_id LIKE @comp + '%' 
					AND (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
					-- PTS 27259 -- BL (start)
					--						when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
					-- PTS 27259 -- BL (end)
						else 'N' end)= 'Y'
					--PTS 42816 JJF 20080527
					--PTS 38816 JJF 20070311 add parmlist
					--PTS 40136 JJF 20071112
					--AND dbo.RowRestrictByUser(cmp_BelongsTo, cmp_id, 'DropDownLookup1001', @parmlist) = 1
					--END PTS 40136 JJF 20071112
					 --PTS 53255 JJF 20101130  
					 AND ( (@rowsecurity <> 'Y')  
						OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)  
					  )  
					--END PTS 53255 JJF 20101130  
					--END PTS 42816 JJF 20080527

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
				cmp_address3,
				cmp_primaryphone,
				cmp_geoloc,
				cmp_city
				FROM company 
				WHERE cmp_id LIKE @comp + '%' 
					and (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'
						-- PTS 27259 -- BL (start)
						--						when cmp_billto = 'N' and cmp_parent = 'N' then 'Y'
						-- PTS 27259 -- BL (end)
						else 'N' end)= 'Y'
					AND (cmp_active = 'Y' OR cmp_active is null)
					--PTS 42816 JJF 20080527
					--PTS 38816 JJF 20070311 add parmlist
					--PTS 40136 JJF 20071112
					--AND dbo.RowRestrictByUser(cmp_BelongsTo, cmp_id, 'DropDownLookup1001', @parmlist) = 1
					--END PTS 40136 JJF 20071112
					 --PTS 53255 JJF 20101130  
					 AND ( (@rowsecurity <> 'Y')  
						OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)  
					  )  
					--END PTS 53255 JJF 20101130  
					--END PTS 42816 JJF 20080527
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
		cmp_address3,
		cmp_primaryphone,
		cmp_geoloc,
		cmp_city
	FROM company 
		WHERE cmp_id = 'UNKNOWN' 
set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loadshipconscompid_sp] TO [public]
GO
