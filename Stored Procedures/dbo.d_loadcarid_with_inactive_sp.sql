SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 38816 JJF 20080311 add parmlist
CREATE PROC [dbo].[d_loadcarid_with_inactive_sp] @car varchar(8), @number int, @parmlist varchar(254) AS

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

--PTS 42816 JJF 20080527
DECLARE @RowSecurityCustom char(1),
		@RowSecurityCustomOverride char(1)
--END PTS 42816 JJF 20080527			

--PTS 42816 JJF 20080527
DECLARE @tbl_carrestrictedcustom TABLE(Value VARCHAR(8))

SELECT @RowSecurityCustom = gi_string1,
		@RowSecurityCustomOverride = gi_string2
FROM generalinfo 
WHERE gi_name = 'RowSecurityCustom'

IF @RowSecurityCustom = 'Y' BEGIN
	IF @RowSecurityCustomOverride = 'Y' BEGIN
		SELECT *
		 FROM  d_loadcarid_with_inactive_custom_fn(@car, @number, @parmlist)

		IF @@ROWCOUNT > 0 BEGIN
			RETURN
		END
	END

	INSERT INTO @tbl_carrestrictedcustom
	SELECT * FROM  rowrestrict_carrier_fn(@car, 'DropDownLookup1020', @parmlist)
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

--PTS 51570 JJF 20100510 rowsec added
if exists ( SELECT car_id 
			FROM  carrier 
					--PTS 64250 JJF 20120808
					--inner join RowRestrictValidAssignments_carrier_fn() rsva on (carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
					--PTS 64250 JJF 20120808
			WHERE car_id LIKE @car + '%'
			--PTS 42816 JJF 20080527
			--PTS 38816 JJF 20070311 add parmlist
			--AND dbo.RowRestrictByUser('UNK', car_id, 'DropDownLookup1020', @parmlist) = 1
			AND (EXISTS(select * FROM @tbl_carrestrictedcustom cmpres WHERE carrier.car_id = cmpres.value)
				OR @RowSecurityCustom <> 'Y')
			--END PTS 42816 JJF 20080527
			--PTS 64250 JJF 20120808
			AND	(	(@rowsecurity <> 'Y')
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
			)
			--END PTS 64250 JJF 20120808
		 ) 
	SELECT car_id ,car_name , car_address1 , car_address2 , isnull(cty_nmstct,'UNKNOWN'), car_board  
	FROM	carrier,
			--PTS 64250 JJF 20120808
			--inner join RowRestrictValidAssignments_carrier_fn() rsva on (carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0),
			--PTS 64250 JJF 20120808
			city
	WHERE car_id LIKE @car + '%' 
			and carrier.cty_code = city.cty_code
			--PTS 42816 JJF 20080527
			--PTS 38816 JJF 20070311 add parmlist
			--AND dbo.RowRestrictByUser('UNK', car_id, 'DropDownLookup1020', @parmlist) = 1
			AND (EXISTS(select * FROM @tbl_carrestrictedcustom cmpres WHERE carrier.car_id = cmpres.value)
				OR @RowSecurityCustom <> 'Y')
			--END PTS 42816 JJF 20080527
			--PTS 64250 JJF 20120808
			AND	(	(@rowsecurity <> 'Y')
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
			)
			--END PTS 64250 JJF 20120808
	ORDER BY car_id
else 
	SELECT car_id ,car_name , car_address1 , car_address2 , 'UNKNOWN', 'Y'  
	FROM carrier
	WHERE car_id = 'UNKNOWN' 

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadcarid_with_inactive_sp] TO [public]
GO
