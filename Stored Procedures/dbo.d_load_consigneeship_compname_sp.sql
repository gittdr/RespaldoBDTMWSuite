SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create proc [dbo].[d_load_consigneeship_compname_sp] 
	@comp 		varchar(100) 
	,@number	int 
as
/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	----------------------------------------------
	PTS 54067	DJM				Created this proc from d_load_consignee_compname_sp to show Consignee and Shipper companies.
	PTS 55062  SGB       Changed @comp from varchar(8) to varchar(100) to allow for longer company name field

*/

DECLARE @daysout int
		,@match_rows int
		,@date datetime

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
					  and (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'  
						else 'N' end) = 'Y'   						--PTS 54076 - DJM
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
					  and (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'  
						else 'N' end) = 'Y'   						--PTS 54076 - DJM
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
				SUBSTRING(cmp_misc1,1,30)	,
            cmp_primaryphone,
            cmp_geoloc,
            cmp_city,
            cmp_altid,
			--PTS 38461 EMK 	
			cmp_address3
			--PTS 38461 EMK 	
		  FROM 	company 
		  WHERE cmp_name LIKE @comp + '%' 
			  and (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'  
				else 'N' end) = 'Y'   						--PTS 54076 - DJM
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
            cmp_primaryphone,
            cmp_geoloc,
            cmp_city,
            cmp_altid,
			--PTS 38461 EMK 	
			cmp_address3
			--PTS 38461 EMK 		
		  FROM 	company 
		  WHERE cmp_name LIKE @comp + '%'
			AND (case when cmp_shipper = 'Y' or cmp_consingee = 'Y' then 'Y'  
				else 'N' end) = 'Y'   						--PTS 54076 - DJM
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
		SUBSTRING(cmp_misc1,1,30)	,
            cmp_primaryphone,
            cmp_geoloc,
            cmp_city,
            cmp_altid,
			--PTS 38461 EMK 	
			cmp_address3
			--PTS 38461 EMK 	
		FROM company 
		WHERE cmp_name = 'UNKNOWN' 
set rowcount 0 
GO
GRANT EXECUTE ON  [dbo].[d_load_consigneeship_compname_sp] TO [public]
GO
