SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 38816 JJF 20080327 add parmlist
CREATE PROC [dbo].[d_loadcarid_sp] @comp varchar(8) , @number int, @parmlist varchar(254) AS

/* PTS12130 MBR 10/10/01 Added grace period check */
DECLARE @daysout int,
                  @date datetime

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
		 FROM  d_loadcarid_custom_fn(@comp, @number, @parmlist)

		IF @@ROWCOUNT > 0 BEGIN
			RETURN
		END
	END

	INSERT INTO @tbl_carrestrictedcustom
	SELECT * FROM  rowrestrict_carrier_fn(@comp, 'DropDownLookup1020', @parmlist)
END 
--END PTS 42816 JJF 20080527


SELECT @daysout = -90
--vjh 31536
if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
select @daysout = lbp_daysout, 
	@date = lbp_date
	from ListBoxProperty
	where lbp_id=@@spid
else
SELECT @daysout = gi_integer1,
               @date = gi_date1
   FROM  generalinfo
WHERE gi_name = 'GRACE'

if @daysout <> 999
   SELECT @date = dateadd(day, @daysout, getdate())

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
if exists (	SELECT car_id 
			FROM carrier
					--PTS 64250 JJF 20120808
					--inner join RowRestrictValidAssignments_carrier_fn() rsva on (carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0) 
					--PTS 64250 JJF 20120808
			WHERE car_id LIKE @comp + '%'  
				AND (car_status <> 'OUT' OR (car_status = 'OUT' AND car_terminationdt >= @date))
				--PTS 42816 JJF 20080527
				AND (EXISTS(select * FROM @tbl_carrestrictedcustom cmpres WHERE carrier.car_id = cmpres.value)
					OR @RowSecurityCustom <> 'Y')
				--END PTS 42816 JJF 20080527
				--PTS 64250 JJF 20120808
				AND	(	(@rowsecurity <> 'Y')
						OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
				)
				--END PTS 64250 JJF 20120808

		) 
	SELECT car_name , car_id , car_address1 , car_address2 , cty_nmstct, car_board, car_iccnum 
	  FROM carrier,
			--PTS 64250 JJF 20120808
			--inner join RowRestrictValidAssignments_carrier_fn() rsva on (carrier.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0),
			--END PTS 64250 JJF 20120808
			city
	 WHERE car_id LIKE @comp + '%' AND
              (car_status <> 'OUT' OR (car_status = 'OUT' AND car_terminationdt >= @date)) AND
	       carrier.cty_code = city.cty_code
			--PTS 42816 JJF 20080527
			--PTS 38816 JJF 20070327 add parmlist and rowrestrict call
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
	SELECT car_name , car_id , car_address1 , car_address2 , 'UNKNOWN', 'Y', car_iccnum
		FROM carrier
		WHERE car_id = 'UNKNOWN' 

set rowcount 0 



GO
GRANT EXECUTE ON  [dbo].[d_loadcarid_sp] TO [public]
GO
