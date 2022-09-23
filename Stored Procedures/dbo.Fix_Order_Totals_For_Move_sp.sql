SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Fix_Order_Totals_For_Move_sp](@MovNumber INTEGER)
AS
DECLARE	@MinOrd		INTEGER,
		@MinStp		INTEGER,
		@ToWgtUnit	VARCHAR(6),
		@ToVolUnit	VARCHAR(6),
		@ToCntUnit	VARCHAR(6),
		@CurWgt		MONEY,
		@TotWgt		MONEY,
		@CurVol		MONEY,
		@TotVol		MONEY,
		@CurCnt		MONEY,
		@TotCnt		MONEY
--PTS 79330 Changed to a FF CURSOR instead of a constant lookup to stops. Added nolock to prevent deadlocks at CRE.

DECLARE MOVSTOPS CURSOR FAST_FORWARD FOR
SELECT ord_hdrnumber from stops with (nolock) where mov_number = @MovNumber and ord_hdrnumber > 0 
group by ord_hdrnumber order by ord_hdrnumber;

OPEN MOVSTOPS
FETCH NEXT FROM MOVSTOPS into @MinOrd

WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT	@ToWgtUnit = ISNULL(ord_totalweightunits, 'UNK'),
			@CurWgt = ord_totalweight,
			@ToVolUnit = ISNULL(ord_totalvolumeunits, 'UNK'),
			@CurVol = ord_totalvolume,
			@ToCntUnit = ISNULL(ord_totalcountunits, 'UNK'),
			@CurCnt = ord_totalpieces
	  FROM	orderheader
	 WHERE	ord_hdrnumber = @MinOrd

	SELECT	@TotWgt = SUM(dbo.sync_qty_with_units_fn(fgt_weightunit, ord_totalweightunits, ISNULL(fgt_weight, 0.0000))),
			@TotVol = SUM(dbo.sync_qty_with_units_fn(fgt_volumeunit, ord_totalvolumeunits, ISNULL(fgt_volume, 0.0000))),
			@TotCnt = SUM(dbo.sync_qty_with_units_fn(fgt_countunit, ord_totalcountunits, ISNULL(fgt_count, 0.0000)))
	  FROM	freightdetail
				INNER JOIN stops ON stops.stp_number = freightdetail.stp_number
				INNER JOIN orderheader ON orderheader.ord_hdrnumber = stops.ord_hdrnumber
	 WHERE	stops.stp_type = 'DRP' 
	   AND	stops.ord_hdrnumber = @MinOrd

	IF ISNULL(@TotWgt, 0.0000) <> ISNULL(@CurWgt, 0.0000) OR ISNULL(@TotVol, 0.0000) <> ISNULL(@CurVol, 0.0000) OR ISNULL(@TotCnt, 0.0000) <> ISNULL(@CurCnt, 0.0000)
		UPDATE	orderheader
		   SET	ord_totalweight = @TotWgt,
				ord_totalvolume = @TotVol,
				ord_totalpieces = @TotCnt
		 WHERE	ord_hdrnumber = @MinOrd

FETCH NEXT FROM MOVSTOPS into @MinOrd
END
CLOSE MOVSTOPS;
DEALLOCATE MOVSTOPS;
	


GO
GRANT EXECUTE ON  [dbo].[Fix_Order_Totals_For_Move_sp] TO [public]
GO
