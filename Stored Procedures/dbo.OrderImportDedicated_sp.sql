SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[OrderImportDedicated_sp]
	@filename		varchar(255)

AS
SET NOCOUNT ON
DECLARE
	-- Variables used by cursor 
	@LoadID				Integer,
	@SequenceNumber			INTEGER,
	@ArrivalTime			DATETIME,
	@departuretime			DateTime,
	@DeliveryDate			DATETIME,
	@CustID 			VARCHAR(8),
	@CustName			VARCHAR(60),
	@LocationAddress1		VARCHAR(50),
	@LocationCity			VARCHAR(18),
	@LocationState			VARCHAR(6),
	@LocationZip			VARCHAR(9),
	@PreviousSequence		Integer,
	@DeliveryCount			Integer,
	@LastDeliveryCount		Integer,
	-- Variables used for return status from called stored procedures	
	@CompanyStatus			INTEGER,
	@CityStatus				INTEGER,
	@StopStatus				INTEGER,
	@OrderStatus				INTEGER,
	-- Variables used for creating stops
	@EventType				VARCHAR(6),
	@StopSequence				INTEGER,
	@MovNumber				INTEGER,
	@StpNumber				INTEGER,
	@FgtNumber				INTEGER,
	@OrdTotalMiles				INTEGER,
	@EarliestTime				DATETIME,
	@LatestTime				DATETIME,
	@PreviousDistance			INTEGER,
	-- Variables used for creating order
	@Origin					VARCHAR(8),
	@OrderNumber				VARCHAR(12),
	@BillTo					VARCHAR(8),
	@OrderBy				VARCHAR(8),
	-- Variables used for various purposes
	@PreviousLoadID			INTEGER,
	@PreviousDeliveryDate		DATETIME,
	@OrdHdrNumber				VARCHAR(12),
	@RevType1				VARCHAR(6),
	@RevType2				VARCHAR(6),
	@UserType1				VARCHAR(6),
	@RevType1Verify				INTEGER,
	@file_sequence				integer,
	@userid					varchar(20)

SET @PreviousLoadID = -1
SET @OrdTotalMiles = 0
SET @PreviousDistance = 0

/* Update change blanks to Nulls		*/
Update OrderImportDedicated
set deliverydate = null
where RTrim(deliverydate) = ''
	and sFilename = @Filename

Update OrderImportDedicated
set ArrivalTime = null
where Rtrim(ArrivalTime) = ''
	and sFilename = @filename

Update OrderImportDedicated
set DepartureTime = null
where Rtrim(DepartureTime) = ''
	and sFilename = @filename

Update OrderImportDedicated
set SequenceNumber = 0
where isnull(SequenceNumber,'') = ''
	and sFilename = @filename

update orderimportdedicated
set custid = null
where Rtrim(custid) = ''
	and sFilename = @filename



/*	Update the Delivery date field to set the Dates for when the Tractor leaves it's domocile point and
	when it arrives back from the last delivery	*/
Update OrderImportDedicated
set deliverydate = (select min(deliverydate) from orderimportdedicated o2 where o2.loadid = orderimportdedicated.loadid) 
where deliverydate is null 
	and arrivaltime is null
	and sFilename = @filename

Update OrderImportDedicated
set deliverydate = (select max(deliverydate) from orderimportdedicated o2 where o2.loadid = orderimportdedicated.loadid) 
where deliverydate is null
	and departuretime is null
	and sFilename = @filename


-- Declare Import_Cursor to loop through imported records
DECLARE Import_Cursor CURSOR FOR
SELECT	fileseq,
	Cast(Loadid as Integer) LoadId,
		Cast(SequenceNumber as Integer) SequenceNumber,
		isNull(CustID,OriginId) CustID, 
		CustName,
		convert(datetime, isNull(deliverydate,'19500101'), 112) + Convert(DateTime, Left(Right('0000' + isnull(arrivaltime, departuretime),4),2) + ':' + Right(Right('0000' + isnull(arrivaltime, departuretime),4),2),108) arrivaltime,
		convert(datetime, isNull(deliverydate,'19500101'), 112) + Convert(DateTime, Left(Right('0000' + isnull(departuretime, arrivaltime),4),2) + ':' + Right(Right('0000' + isnull(departuretime, arrivaltime),4),2),108) departuretime,
		DeliveryDate,
		LocationCity,
		LocationState,
		LocationZip,
		(Select count(*) from OrderImportDedicated o2 where o2.loadid = OrderImportDedicated.loadid and sequencenumber > 0) delivery_count,
		sfilename 
  FROM	OrderImportDedicated
 WHERE	LoadId IS NOT NULL and
	sfilename = @filename
ORDER BY fileseq, LoadId

Select @UserId = user_name(user_id())

-- Check for missing company records
INSERT INTO OrderImportDedicated_audit
(LoadID, Departuredate, Message, Type, Sequence, sfilename)
SELECT	cast(LoadID as Integer) LoadId,
	 Cast(isNull(Deliverydate,'11/11/11') as DateTime),
 	'Sequence #' + STR(SequenceNumber, 2) + ':  Missing Company - ' + CustName + ' (' + isNull(CustID,OriginId) + ').  Please add and try again.',
	1,
	fileseq,
	sfilename
FROM	OrderImportDedicated OID
WHERE sFilename = @filename
	and NOT EXISTS(SELECT * 
		FROM company 
		WHERE (cmp_id = OID.CustID OR cmp_id = OID.OriginID) OR
			(cmp_altid = OID.CustID OR cmp_altid = OID.OriginID))

IF (SELECT COUNT(*) FROM OrderImportDedicated_audit where sFilename = @filename) > 0
	Begin
		GOTO RAISEERROR_EXIT
	end

-- Open Import_Cursor
OPEN Import_Cursor

-- Fetch first record from Import_Cursor
FETCH NEXT FROM Import_Cursor INTO @file_sequence, @LoadID, @SequenceNumber, @CustID, @CustName, @ArrivalTime, 
			    @departuretime, @deliverydate, @LocationCity, @LocationState, @LocationZip, @DeliveryCount,
			    @filename

-- Loop through Import_Cursor while records still left to process
WHILE (@@FETCH_STATUS = 0)
	BEGIN
		Select @CustId = isnull((Select cmp_id from company where cmp_altid = @custid),@custid)
		if @custid is null
			Begin
				Select @CustId = (Select cmp_id from company where cmp_id = @custid)
			end

		SET @OrdHdrNumber = ISNULL(@OrdHdrNumber, '')

		IF @SequenceNumber = 0 AND @PreviousLoadID <> -1 AND @LoadID <> @PreviousLoadID and @LastDeliveryCount > 0
			BEGIN
				--Print 'Before Add TMWv_create_order_from_stops'
				EXEC @OrderStatus = TMWv_create_order_from_stops 'Y', @MovNumber, '', @OrderBy, @UserID, @BillTo, 'N', @RevType1, @RevType2, 'UNK', 'UNK', @OrdTotalMiles,
						 '', '', '', 0.0, 'UNK', 0.0, 0.0, 0,
						 0, '', '', 'N', 'UNKNOWN', '', @OrderNumber OUTPUT

				--Print 'After Add TMWv_create_order_from_stops'
				--Print 'Created Order: ' + @OrderNumber
				-- See if there was error creating order
				IF @OrderStatus <> 1
				BEGIN
					INSERT INTO OrderImportDedicated_audit
						(LoadID, Departuredate, Message, Type, Sequence, sfilename)
					VALUES
						(@PreviousLoadID, @PreviousDeliveryDate, 'ERROR:  Error Creating Order. Status = ' + STR(@OrderStatus, 3), 1, 0, @filename)
					GOTO RAISEERROR_EXIT
				END
	
				INSERT INTO OrderImportDedicated_audit
					(LoadID, Departuredate, Message, Type, Sequence, sfilename)
				VALUES
					(@PreviousLoadID, @PreviousDeliveryDate, 'Order:  ' + RTRIM(@OrderNumber) + ', Successfully Created.', 1, 0, @filename)
	
				SET @OrdTotalMiles = 0
				SET @PreviousDistance = 0
			END
		
			IF @SequenceNumber = 0 and @LoadID <> @PreviousLoadID
				BEGIN 
					SET @Origin = @CustID
					SET @BillTo = @Origin
					SET @OrderBy = @Origin
					SET @StopSequence = 1
					SET @EventType = 'HPL'
					SET @MovNumber = 0
				END
			ELSE
				BEGIN
					SET @StopSequence = @StopSequence + 1
					IF @CustID = @Origin 
						SET @EventType = 'IEMT'
					ELSE
						SET @EventType = 'LUL'
				END
		
			SET @LatestTime = @departuretime
			SET @EarliestTime = @ArrivalTime
	
			/* Do not create and Order or Stops where the Delivery count is zero.		*/
			if @DeliveryCount > 0 
				Begin
					EXEC @StopStatus = TMWv_add_neworder_stop 'Y', @MovNumber, @StopSequence, @EventType, @CustID,
								  0, @PreviousDistance, 'UNK', '', @ArrivalTime,
								  @EarliestTime, @LatestTime, 'UNKNOWN', 0, 
								  'LBS', 0.0, 'UNK', 0.0, 'UNK', '', '', '', '', '', @MovNumber OUTPUT, 
								  @StpNumber OUTPUT, @FgtNumber OUTPUT

					IF @StopStatus <> 1
						BEGIN
							INSERT INTO OrderImportDedicated_audit
								(LoadID, Departuredate, Message, Type, Sequence, sfilename)
							VALUES
								(@LoadID, @DeliveryDate, 'ERROR:  Error Creating Stop ' + STR(@StopSequence) + '. Status = ' + STR(@StopStatus, 3), 1, 0, @filename)
							GOTO RAISEERROR_EXIT
						END
					Else
						BEGIN
							SET @OrdTotalMiles = @OrdTotalMiles + 0
					
							SET @PreviousLoadID = @LoadID
							SET @PreviousDeliveryDate = @DeliveryDate
					
							SET @PreviousDistance = 0
						END
				End

			Select @LastDeliveryCount = @DeliveryCount
		FETCH NEXT FROM Import_Cursor INTO @file_sequence, @LoadID, @SequenceNumber, @CustID, @CustName, @ArrivalTime, 
				@departuretime, @deliverydate, @LocationCity, @LocationState, @LocationZip, @DeliveryCount,
				@filename		 
	END	

/*	For the Last Load in the List, Create the Order			*/
IF @SequenceNumber = 0 AND @PreviousLoadID <> -1 and @DeliveryCount > 0
	BEGIN
		EXEC @OrderStatus = TMWv_create_order_from_stops 'Y', @MovNumber, '', @OrderBy, @UserID, @BillTo, 'N', @RevType1, @RevType2, 'UNK', 'UNK', @OrdTotalMiles,
				 '', '', '', 0.0, 'UNK', 0.0, 0.0, 0,
				 0, '', '', 'N', 'UNKNOWN', '', @OrderNumber OUTPUT

		--Print 'Created Order for last Entry: ' + @OrderNumber
		-- See if there was error creating order
		IF @OrderStatus <> 1
		BEGIN
			INSERT INTO OrderImportDedicated_audit
				(LoadID, Departuredate, Message, Type, Sequence, sfilename)
			VALUES
				(@PreviousLoadID, @PreviousDeliveryDate, 'ERROR:  Error Creating Order. Status = ' + STR(@OrderStatus, 3), 1, 0, @filename)
			GOTO RAISEERROR_EXIT
		END

		INSERT INTO OrderImportDedicated_audit
			(LoadID, Departuredate, Message, Type, Sequence, sfilename)
		VALUES
			(@PreviousLoadID, @PreviousDeliveryDate, 'Order:  ' + RTRIM(@OrderNumber) + ', Successfully Created.', 1, 0, @filename)

		SET @OrdTotalMiles = 0
		SET @PreviousDistance = 0
	END


CLOSE Import_Cursor
DEALLOCATE Import_Cursor

--Delete from OrderImportDedicated where sFilename = @filename

/*
SELECT	LoadId,
	DepartureDate,
	sfilename,
	Message
FROM OrderImportDedicated_audit
ORDER BY LoadId ASC, Type ASC, Sequence ASC
*/


SET NOCOUNT OFF
RETURN 1

RAISEERROR_EXIT:
CLOSE Import_Cursor
DEALLOCATE Import_Cursor

--DELETE from OrderImportDedicated
--where not exists (select * 
--		from OrderImportDedicated_audit 
--		where OrderImportDedicated_audit.LoadID = orderimportdedicated.LoadID)
/*
SELECT	LoadID,
	departuredate,
	sfilename,
	Message
  FROM	OrderImportDedicated_audit 
ORDER BY LoadID ASC, Sequence ASC
*/

--RAISERROR ('Error Importing Orders', 1, 1)
SET NOCOUNT OFF
RETURN -1
GO
GRANT EXECUTE ON  [dbo].[OrderImportDedicated_sp] TO [public]
GO
