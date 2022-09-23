SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loadcarid_showretired_sp] @comp varchar(8) , @number int AS

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

--PTS 51570 JJF 20100510 rowsec
if exists	(	SELECT	car_id 
				FROM	carrier 
				--PTS 64250 JJF 20120808
				--inner join RowRestrictValidAssignments_carrier_fn() rsva on (carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
				--END PTS 64250 JJF 20120808
				WHERE	car_id LIKE @comp + '%'
						--PTS 64250 JJF 20120808
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)
						--END PTS 64250 JJF 20120808

			)

	SELECT	car_name , car_id , car_address1 , car_address2 , cty_nmstct, car_board, car_status
	FROM	carrier,
			--PTS 64250 JJF 20120808
			--inner join RowRestrictValidAssignments_carrier_fn() rsva on (carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0),
			--END PTS 64250 JJF 20120808
			city
	WHERE	car_id LIKE @comp + '%'
			AND	carrier.cty_code = city.cty_code
			--PTS 64250 JJF 20120808
			AND	(	(@rowsecurity <> 'Y')
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
			)
			--END PTS 64250 JJF 20120808
	ORDER BY car_id 
else 
	SELECT car_name , car_id , car_address1 , car_address2 , 'UNKNOWN', 'Y', car_status
	FROM carrier
	WHERE car_id = 'UNKNOWN' 

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadcarid_showretired_sp] TO [public]
GO
