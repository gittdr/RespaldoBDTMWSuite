SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loadcompid_referencenumber_with_inactive_sp] @comp varchar(8) , @number int 
AS

/*
 * 
 * NAME:
 * dbo.d_loadcompid_referencenumber_with_inactive_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoice detail records 
 * based on the invoice number selected in the interface.
 *
 * RETURNS:
 * 0  - uniqueness has not been violated 
 * >0 - uniqueness has been violated   
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @comp, varchar(8), input, null;
 *       company 
 * 002 - @number, int, output, null;
 *       return value used to identify the reference number of rows
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 09/22/2005 - PTS 20964 - Imari Bremer - Add billto parameter to for unique reference numbers by billto
 **/
/*
DPETE 17782 add primaryphone, goloc and city to match other dddw
*/


DECLARE @match_rows int, @v_found char(1)

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
----END PTS 42816 JJF 20080527

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
					--AND (EXISTS(select * FROM @tbl_cmprestrictedbyuser cmpres WHERE company.cmp_id = cmpres.value)
					--	OR @rowsecurity <> 'Y')
					AND	(	(@rowsecurity <> 'Y')
							OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)
					--END PTS 53255 JJF 20101130
		)
	SELECT @match_rows = 1
else
	SELECT @match_rows = 0

CREATE TABLE #company_temp (
cmp_name varchar(100) null,
cmp_id varchar(8) null,
cmp_address1 varchar(100) null,
cmp_address2 varchar(100) null, 
cty_nmstct varchar(25) null,
cmp_defaultbillto varchar(8) null,
cmp_defaultpriority varchar(6) null,
cmp_zip varchar(10) null,
cmp_subcompany varchar(6) null,
cmp_currency varchar(6) null,
cmp_mileagetable varchar(2) null,
cmp_shipper varchar(1) null,
cmp_consingee varchar(1) null,
cmp_billto varchar(1) null,
cmp_contact varchar(30) null,
cmp_misc1 varchar(254) null,
cmp_parent varchar(1) null,
cmp_altid varchar(25) null,
cmp_primaryphone varchar(20) null,
cmp_geoloc varchar(50) null,
cmp_city int null,
cmp_active varchar(1) null)

--START PTS# 33744 ILB 07/21/2006
IF len(@comp) = 1 
   BEGIN 	
	IF @comp = 'E' 
	   BEGIN
		INSERT INTO #company_temp
		(cmp_id,cmp_name,cmp_shipper,cmp_consingee,cmp_bilLto,cmp_active)
		VALUES
		('EACH','EACH','Y','Y','Y','N')
	  END 	
  END

IF len(@comp) = 2 
   BEGIN 	
	IF @comp = 'EA' 
	   BEGIN
		INSERT INTO #company_temp
		(cmp_id,cmp_name,cmp_shipper,cmp_consingee,cmp_bilLto,cmp_active)
		VALUES
		('EACH','EACH','Y','Y','Y','N')
	  END 	
   END

IF len(@comp) = 3 
   BEGIN 	
	IF @comp = 'EAC'        
	   BEGIN
		INSERT INTO #company_temp
		(cmp_id,cmp_name,cmp_shipper,cmp_consingee,cmp_bilLto,cmp_active)
		VALUES
		('EACH','EACH','Y','Y','Y','N')
	  END
   END 

IF len(@comp) = 4 
   BEGIN 	
	IF @comp = 'EACH' 
	   BEGIN
		INSERT INTO #company_temp
		(cmp_id,cmp_name,cmp_shipper,cmp_consingee,cmp_bilLto,cmp_active)
		VALUES
		('EACH','EACH','Y','Y','Y','N')
	  END 
   END	

--SELECT @v_found = SUBSTRING(@comp, 1, 1)
--IF @v_found = 'E' 
--   BEGIN
--	INSERT INTO #company_temp
--	(cmp_id,cmp_name,cmp_shipper,cmp_consingee,cmp_bilLto,cmp_active)
--	VALUES
--	('EACH','EACH','Y','Y','Y','N')-
--  END 	
--END PTS# 33744 ILB 07/21/2006

IF @match_rows > 0
	BEGIN		
		INSERT INTO #company_temp  
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
	      		cmp_city,
			cmp_active	
		   FROM company 
		  WHERE cmp_id LIKE @comp + '%' 
				--PTS 53255 JJF 20101130
				--AND (EXISTS(select * FROM @tbl_cmprestrictedbyuser cmpres WHERE company.cmp_id = cmpres.value)
				--	OR @rowsecurity <> 'Y')
				AND	(	(@rowsecurity <> 'Y')
						OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
					)
				--END PTS 53255 JJF 20101130
	       ORDER BY cmp_id 
	END
else 	
	BEGIN
		INSERT INTO #company_temp  
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
	                cmp_city,
			cmp_active			
		   FROM company 
		  WHERE cmp_id IN ('EACH') 
	END

SELECT * 
  FROM #company_temp 

set rowcount 0 
GO
GRANT EXECUTE ON  [dbo].[d_loadcompid_referencenumber_with_inactive_sp] TO [public]
GO
