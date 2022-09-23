SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loadvendorpayto_sp] @comp varchar(12) , @number int AS
/**
 * DESCRIPTION:
 *
 * REVISION HISTORY:
 * 10/29/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @match_rows int

--PTS 64250 JJF 20120808
DECLARE @rowsecurity	char(1)
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--END PTS 64250 JJF 20120808

--PTS 64250 JJF 20120808
SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_carrier_fn() 
END
--END PTS 64250 JJF 20120808

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
	

--PTS 51570 JJF 20100510 - add rowsec
IF EXISTS	(	SELECT DISTINCT pto_id
                FROM	carrier
						--PTS 64250 JJF 20120808
						--inner join RowRestrictValidAssignments_carrier_fn() rsva on (carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0) 
						--END PTS 64250 JJF 20120808
				WHERE	pto_id LIKE @comp + '%'
						--PTS 64250 JJF 20120808
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)
						--END PTS 64250 JJF 20120808
			)
     SELECT @match_rows = 1
ELSE
     SELECT @match_rows = 0

IF @match_rows > 0
	--PTS 51570 JJF 20100510 - add rowsec
	SELECT DISTINCT carrier.pto_id, 
					payto.pto_companyname, 
					payto.pto_address1, 
					payto.pto_address2,
					city.cty_nmstct
	FROM	carrier,
			--PTS 64250 JJF 20120808
			--inner join RowRestrictValidAssignments_carrier_fn() rsva on (carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0), 
			--END PTS 64250 JJF 20120808
			payto left outer join city on payto.pto_city = city.cty_code
			
	WHERE	carrier.pto_id LIKE @comp + '%' 
			AND carrier.pto_id = payto.pto_id 
			--PTS 64250 JJF 20120808
			AND	(	(@rowsecurity <> 'Y')
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
			)
			--END PTS 64250 JJF 20120808

 ELSE 
     SELECT pto_id, pto_companyname, pto_address1, pto_address2, 'UNKNOWN'
         FROM payto
     WHERE pto_id = 'UNKNOWN'

SET rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadvendorpayto_sp] TO [public]
GO
