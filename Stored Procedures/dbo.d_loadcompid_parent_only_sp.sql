SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROC [dbo].[d_loadcompid_parent_only_sp] @comp varchar(8) , @number int AS

/** 
 * NAME:
 *	dbo.d_loadcompid_parent_only_sp
 *
 * TYPE:
 *	[StoredProcedure]
 *
 * DESCRIPTION:
 *    Provides data for dddw d_loadcompid_parent_for_dddw
 *    
 * RETURNS:
 *    Nothing
 *
 * RESULT SETS: 
 *    1  cmp_name			varchar(30) 
 *    2  cmp_id				varchar(8)
 *    3	 cmp_address1		varchar(100)
 *    4	 cmp_address2		varchar(100)
 *    5	 cty_nmstct			varchar(25)
 *    6	 cmp_defaultbillto	varchar(8)
 *    7	 cmp_defaultpriority varchar(6)
 *    8	 cmp_zip			varchar(10)
 *    9	 cmp_subcompany		varchar(6)
 *    10 cmp_currency		varchar(6)
 *    11 cmp_mileagetable	varchar(2)
 *    12 cmp_shipper		char(1)
 *    13 cmp_consingee		char(1)
 *    14 cmp_billto			char(1)
 *    15 cmp_contact		varchar(30)
 *	  16 cmp_misc1			varchar(254)
 *    17 cmp_parent			char(1)
 *    18 cmp_altid			varchar(25)
 *    19 cmp_primaryphone	varchar(20)
 *    20 cmp_geoloc			varchar(50)
 *    21 cmp_city			int
 *
 * PARAMETERS:
 *	@comp varchar(8)    is cmp_id
 *	@number int			for @match_rows value
 *
 * REVISION HISTORY:
 * 05/24/2007.01 - PTS 35516 - Judy Swindell - Original draft.  
 *
 **/

-- ( --35516 5-8-2007 jds Created - copied from d_loadcompid_with_inactive_sp ) 

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
					and cmp_parent = 'Y'
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
                IsNull(cmp_altid,''),
      cmp_primaryphone ,
      cmp_geoloc,
      cmp_city	
		FROM company 
		WHERE cmp_id LIKE @comp + '%'
				and cmp_parent = 'Y'
				--PTS 53255 JJF 20101130
				--AND (EXISTS(select * FROM @tbl_cmprestrictedbyuser cmpres WHERE company.cmp_id = cmpres.value)
				--	OR @rowsecurity <> 'Y')
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
                IsNull(cmp_altid,''),
                cmp_primaryphone ,
                cmp_geoloc,
                cmp_city			
		FROM company 
		WHERE cmp_id = 'UNKNOWN' 
set rowcount 0
GO
GRANT EXECUTE ON  [dbo].[d_loadcompid_parent_only_sp] TO [public]
GO
