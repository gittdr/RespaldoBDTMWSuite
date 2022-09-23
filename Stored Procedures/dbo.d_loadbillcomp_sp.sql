SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loadbillcomp_sp] @comp varchar(30) , @number int AS 

DECLARE @daysout int, @match_rows int, @date datetime

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
--PTS 35461/PTS 64942 JJF 20130501
else if @number > 24 
    set rowcount @number
--END PTS 35461/PTS 64942 JJF 20130501
else
	set rowcount 8


if @daysout = 999
	if exists(SELECT cmp_id 
				FROM company 
				WHERE cmp_name LIKE @comp + '%' 
						AND cmp_billto = 'Y'
						--PTS 53255 JJF 20101130
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						--END PTS 53255 JJF 20101130
				)
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0
else
	if exists(SELECT cmp_id 
				FROM company 
				WHERE cmp_name LIKE @comp + '%' 
						AND (cmp_active = 'Y' Or cmp_active is null) 
						AND cmp_billto = 'Y'
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
	if @daysout = 999

		SELECT cmp_name , cmp_id , cmp_address1 , cmp_address2 , cty_nmstct, cmp_altid
			FROM company 
			WHERE cmp_name LIKE @comp + '%' 
					AND cmp_billto = 'Y'
						--PTS 53255 JJF 20101130
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						--END PTS 53255 JJF 20101130
		ORDER BY cmp_name 
	
	else
		SELECT cmp_name , cmp_id , cmp_address1 , cmp_address2 , cty_nmstct, cmp_altid 
			FROM company 
			WHERE cmp_name LIKE @comp + '%'
					AND (cmp_active = 'Y' OR cmp_active is null) 
					AND cmp_billto = 'Y'
						--PTS 53255 JJF 20101130
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
						--END PTS 53255 JJF 20101130
		ORDER BY cmp_name 
        
else 
       
	SELECT cmp_name , cmp_id , cmp_address1 , cmp_address2 , cty_nmstct, cmp_altid 
		FROM company 
		WHERE cmp_id = 'UNKNOWN' 

set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loadbillcomp_sp] TO [public]
GO
