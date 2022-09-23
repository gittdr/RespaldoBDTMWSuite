SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loadservicelocation_sp] @comp varchar(12) , @number int AS

DECLARE @match_rows int

--PTS 42816 JJF 20080527
DECLARE @rowsecurity	char(1)
--END PTS 42816 JJF 20080527			

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

IF @number = 1 
	SET rowcount 1 
ELSE IF @number <= 8 
	set rowcount 8
ELSE IF @number <= 16
	SET rowcount 16
ELSE IF @number <= 24
	SET rowcount 24
ELSE
	set rowcount 8

IF EXISTS (SELECT DISTINCT cmp_id
			FROM company
			WHERE cmp_id  LIKE @comp + '%' 
					AND cmp_service_location = 'Y'
					--PTS75456 JJF 20140724
					AND	(	(@rowsecurity <> 'Y')
							OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)
			)
     SELECT @match_rows = 1
ELSE
     SELECT @match_rows = 0

IF @match_rows > 0
	SELECT DISTINCT company.cmp_id, company.cmp_name, company.cmp_address1, company.cmp_address2, city.cty_nmstct
	FROM company,  city
	WHERE company.cmp_id LIKE @comp + '%' 
			AND company.cmp_service_location = 'Y'
			AND company.cmp_city = city.cty_code
			--PTS75456 JJF 20140724
			AND	(	(@rowsecurity <> 'Y')
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE company.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
				)
 ELSE 
     SELECT cmp_id, cmp_name, cmp_address1, cmp_address2, 'UNKNOWN'
         FROM company
     WHERE cmp_id = 'UNKNOWN'

SET rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadservicelocation_sp] TO [public]
GO
