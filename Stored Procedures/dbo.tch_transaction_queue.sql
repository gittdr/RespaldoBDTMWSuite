SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE    PROCEDURE [dbo].[tch_transaction_queue]
		@p_mov_number int,
		@p_tchrealtime_status char(1),
		@p_tchrealtime_tractor char(1),
		@p_tchrealtime_trailer char(1),
		@p_tchrealtime_trip char(1)
AS

/**
 * 
 * NAME:
 * tch_transaction_queue
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure queues up the TCH transactions when Order Entry, Dispatch or TotalMail 
 * update the status of the trip.
 *
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: 	@p_mov_number		int	Move Number to insert into the transaction queue
 *		@p_tchrealtime_status	char(1)	Y/N for status updates
 *		@p_tchrealtime_tractor	char(1)	Y/N for tractor updates
 *		@p_tchrealtime_trailer  char(1) Y/N for trailer updates
 *		@p_tchrealtime_trip	char(1)	Y/N for trip updates
 *
 * REVISION HISTORY:
 * 4/17/2006.01 ? PTS30006 - Dan Hudec ? Created Procedure
 *
 **/

BEGIN

declare @LegEndDate datetime -- RKratz Added 9/7/07 to NOT process completed legs

DECLARE	@v_current_drv	varchar(8),
		@v_current_drv2 varchar(8),
		@v_current_trc	varchar(8),
		@v_current_trl 	varchar(8),
		@v_card1_status	varchar(1),
		@v_card1_trc	varchar(8),
		@v_card1_trl	varchar(8),
		@v_card1_trip	int,
		@v_card1_number	varchar(20),
		@v_card2_status	varchar(1),
		@v_card2_trc	varchar(8),
		@v_card2_trl	varchar(8),
		@v_card2_trip	int,
		@v_card2_number	varchar(20),
		@v_trip_status	varchar(3),
		@v_tch_status 	varchar(1),
		@v_tch_trc	varchar(8),
		@v_tch_trl	varchar(8),
		@v_tch_trip	int,
		@v_tch2_status 	varchar(1),
		@v_tch2_trc	varchar(8),
		@v_tch2_trl	varchar(8),
		@v_tch2_trip	int,
		@v_xfacetype1	int,
		@v_xfacetype2 	int,
		@v_temp_lgh_number	int,
		@v_max_lgh_number	int

SELECT	@v_tch_status = ''
SELECT	@v_tch_trc = ''
SELECT	@v_tch_trl = ''
SELECT	@v_tch_trip = ''
SELECT	@v_tch2_status = ''
SELECT	@v_tch2_trc = ''
SELECT	@v_tch2_trl = ''
SELECT	@v_tch2_trip = ''

SELECT	@v_temp_lgh_number = min(lgh_number)
FROM	legheader_active
WHERE	mov_number = @p_mov_number

SELECT	@v_max_lgh_number = max(lgh_number)
FROM	legheader_active
WHERE	mov_number = @p_mov_number

WHILE 1 = 1
 BEGIN

	

	SELECT	@v_trip_status = lgh_outstatus
	FROM	legheader_active
	WHERE	lgh_number = @v_temp_lgh_number

	IF @v_trip_status in ('PLN', 'STD', 'DSP') --Changed from STD.  Could add a GI Setting in the future. --DPH PTS 33434
	 BEGIN
		SELECT	@v_current_drv = lgh_driver1, 
				@v_current_drv2 = lgh_driver2,
				@v_current_trc = lgh_tractor, 
				@v_current_trl = lgh_primary_trailer
		FROM	legheader_active
		WHERE	lgh_number = @v_temp_lgh_number

		SELECT	@v_card1_status = crd_status, 
				@v_card1_trc = crd_unitnumber, 
				@v_card1_trl = crd_trailernumber, 
				@v_card1_trip = crd_tripnumber,
				@v_card1_number = crd_cardnumber
		FROM	cashcard
		WHERE	crd_driver = @v_current_drv
		  AND	crd_status <> 'D'
		  AND	cashcard.crd_accountid in (select cdacctcode.cac_id from cdacctcode
						   where  cfb_xfacetype in ('10', '30'))

		SELECT	@v_card2_status = crd_status, 
				@v_card2_trc = crd_unitnumber, 
				@v_card2_trl = crd_trailernumber, 
				@v_card2_trip = crd_tripnumber,
				@v_card2_number = crd_cardnumber
		FROM	cashcard
		WHERE	crd_driver = @v_current_drv2
		  AND	crd_status <> 'D'
		  AND	cashcard.crd_accountid in (select cdacctcode.cac_id from cdacctcode
						   where  cfb_xfacetype in ('10', '30'))

		IF @p_tchrealtime_status = 'Y'
		 BEGIN
			IF @v_card1_status <> 'A' 
				SELECT @v_tch_status = 'A'

			IF @v_card2_status <> 'A'
				SELECT @v_tch2_status = 'A'
		 END

	 END

	If @v_trip_status = 'CMP' and @p_tchrealtime_status = 'Y'
	 BEGIN
		SELECT	@v_current_drv = lgh_driver1, 
				@v_current_drv2 = lgh_driver2,
				@v_current_trc = lgh_tractor, 
				@v_current_trl = lgh_primary_trailer
		FROM	legheader_active
		WHERE	lgh_number = @v_temp_lgh_number

		SELECT	@v_card1_status = crd_status, 
				@v_card1_trc = crd_unitnumber, 
				@v_card1_trl = crd_trailernumber, 
				@v_card1_trip = crd_tripnumber,
				@v_card1_number = crd_cardnumber
		FROM	cashcard
		WHERE	crd_driver = @v_current_drv
		  AND	crd_status <> 'D'
			  AND	cashcard.crd_accountid in (select cdacctcode.cac_id from cdacctcode
						   where  cfb_xfacetype in ('10', '30'))

		SELECT	@v_card2_status = crd_status, 
				@v_card2_trc = crd_unitnumber, 
				@v_card2_trl = crd_trailernumber, 
				@v_card2_trip = crd_tripnumber,
				@v_card2_number = crd_cardnumber
		FROM	cashcard
		WHERE	crd_driver = @v_current_drv2
		  AND	crd_status <> 'D'
			  AND	cashcard.crd_accountid in (select cdacctcode.cac_id from cdacctcode
						   where  cfb_xfacetype in ('10', '30'))

		IF @p_tchrealtime_status = 'Y'
		 BEGIN
			IF @v_card1_status = 'A'
				SELECT @v_tch_status = 'H' --Hold or Inactive, Both are ok

			IF @v_card2_status = 'A'
				SELECT @v_tch2_status = 'H' --Hold or Inactive, Both are ok
		 END
	 END

	IF @p_tchrealtime_tractor = 'Y'
	 BEGIN
		IF @v_current_trc <> @v_card1_trc
			SELECT @v_tch_trc = @v_current_trc

		IF @v_current_trc <> @v_card2_trc
			SELECT @v_tch2_trc = @v_current_trc
	 END

	IF @p_tchrealtime_trailer = 'Y'
	 BEGIN
		IF @v_current_trl <> @v_card1_trl
			SELECT @v_tch_trl = @v_current_trl

		IF @v_current_trl <> @v_card2_trl
			SELECT @v_tch2_trl = @v_current_trl
	 END

	IF @p_tchrealtime_trip = 'Y'
	 BEGIN
		IF @p_mov_number <> @v_card1_trip
			SELECT @v_tch_trip = @p_mov_number
		
		IF @p_mov_number <> @v_card2_trip
			SELECT @v_tch2_trip = @p_mov_number
	 END


	SELECT	@v_xfacetype1 = cdacctcode.cfb_xfacetype
	FROM	cdacctcode, cashcard
	WHERE	cashcard.crd_accountid = cdacctcode.cac_id
	AND	cashcard.crd_cardnumber = @v_card1_number

	SELECT	@v_xfacetype2 = cdacctcode.cfb_xfacetype
	FROM	cdacctcode, cashcard
	WHERE	cashcard.crd_accountid = cdacctcode.cac_id
	AND	cashcard.crd_cardnumber = @v_card2_number


--
--declare @LegEndDate datetime --at top  -- RKratz Added 9/7/07 to NOT process completed legs
select @LegEndDate = lgh_enddate from legheader (nolock) where lgh_number = @v_temp_lgh_number -- RKratz Added 9/7/07 to NOT process completed legs
if ( @LegEndDate > getdate() )  -- RKratz Added 9/7/07 to NOT process completed legs
begin  -- RKratz Added 9/7/07 to NOT process completed legs
-- RKratz Added 9/7/07 changed from UNK to UNKNOWN and removed upper(left(x,3))
	IF @v_tch_trc <> 'UNKNOWN' and @v_current_drv <> 'UNKNOWN' and (@v_xfacetype1 = 10 or @v_xfacetype1 = 30) and (@v_tch_status <> '' or @v_tch_trc <> '' or @v_tch_trl <> '' or @v_tch_trip <> '') --10 is TCH
	 BEGIN
		INSERT INTO tchtransqueue (ttq_mov_number, ttq_userid, ttq_issuedon, ttq_cardnumber, ttq_status, 
					   ttq_tractor, ttq_trailer, ttq_tripnum, ttq_msg)
		VALUES (@p_mov_number, suser_sname(), getdate(), @v_card1_number, @v_tch_status, 
			@v_tch_trc, @v_tch_trl, @v_tch_trip, null)
	 END
-- RKratz Added 9/7/07 changed from UNK to UNKNOWN and removed upper(left(x,3))
	IF @v_tch2_trc <> 'UNKNOWN' and @v_current_drv2 <> 'UNKNOWN' and (@v_xfacetype2 = 10 or @v_xfacetype2 = 30) and (@v_tch2_status <> '' or @v_tch2_trc <> '' or @v_tch2_trl <> '' or @v_tch2_trip <> '') --10 is TCH
	 BEGIN
		select @p_mov_number = cast(@p_mov_number as varchar) + '99' --Need to differentiate this move so it will process

		INSERT INTO tchtransqueue (ttq_mov_number, ttq_userid, ttq_issuedon, ttq_cardnumber, ttq_status, 
					   ttq_tractor, ttq_trailer, ttq_tripnum, ttq_msg)
		VALUES (@p_mov_number, suser_sname(), getdate(), @v_card2_number, @v_tch2_status, 
			@v_tch2_trc, @v_tch2_trl, @v_tch2_trip, null)
	 END

end  -- RKratz Added 9/7/07 to NOT process completed legs

	SELECT	@v_temp_lgh_number = min(lgh_number)
	FROM	legheader_active
	WHERE	mov_number = @p_mov_number
	AND		lgh_number > @v_temp_lgh_number

	If @v_temp_lgh_number IS NULL 
	 BEGIN
		BREAK
	 END
 END
END

RETURN
GO
GRANT EXECUTE ON  [dbo].[tch_transaction_queue] TO [public]
GO
