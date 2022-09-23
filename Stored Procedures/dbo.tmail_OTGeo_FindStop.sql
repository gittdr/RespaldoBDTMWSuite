SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_OTGeo_FindStop] @CMPID VARCHAR(8), 
                                              @Truck VARCHAR(20), 
                                              @Driver VARCHAR(20), 
                                              @Trailer VARCHAR(20),
                                              @Status VARCHAR(20), 
                                              @Flags INT = 0

/*******************************************************************************************************************  
  Object Description:
  Searches for Stops found in AA&D based on cmp_id and Assets
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/07/22    Riley Wolfe     PTS94952	    init 
  2016/08/02    Riley Wolfe     PTS94952      making DBA services changes recomended by Lisa Bohm
********************************************************************************************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @MainAGSQL NVARCHAR(4000), 
        @AssetSQL NVARCHAR(500), 
        @StatusSQL NVARCHAR(200) ,
        @SubSelectSQL NVARCHAR(200),
        @GetLegAGSQL NVARCHAR(1000),
        @subJoin NVARCHAR(200),
        @mainWhere NVARCHAR(200) = N'WHERE cmp_id = @CMPID ',
        @subAddWhere NVARCHAR(200) = '',
        @MainOrder NVARCHAR(200) = '';
        
DECLARE @Current BIT,
        @Arrive BIT,
        @ResultCount INT;

DECLARE @Results TABLE(stp_number INT, lgh_number INT, ord_hdrnumber INT, asgn_status CHAR(3), stp_dispatched_sequence INT);

IF @Status = 'Arrival'
BEGIN
  SET @Current = 1;
  SET @Arrive = 1;
END
ELSE IF @Status = 'Departure'
BEGIN
  SET @Current = 1;
  SET @Arrive = 0;
END
ELSE IF @Status like 'Arrival%Update'
BEGIN
  SET @Current = 0;
  SET @Arrive = 1;
END
ELSE IF @Status LIKE 'Departure%Update'
BEGIN
  SET @Current = 0;
  SET @Arrive = 0;
END
ELSE
  Return;

--find assets
SET @AssetSQL  = N'('; 
IF COALESCE(@Truck, '') > ''
	SET @AssetSQL = @AssetSQL + N'(asgn_type = ''TRC'' AND asgn_id = @Truck) OR ';

IF COALESCE(@Driver, '') > ''
	SET @AssetSQL = @AssetSQL + N'(asgn_type = ''DRV'' AND asgn_id = @Driver) OR ';

IF COALESCE(@Trailer, '') > ''
	SET @AssetSQL = @AssetSQL + N'(asgn_type = ''TRL'' AND asgn_id = @Trailer) OR ';

SET @AssetSQL = LEFT(@AssetSQL, Len(@AssetSQL) -3) + ') ';

--core
SET @SubSelectSQL = N' lgh_number, asgn_status, ROW_NUMBER() OVER (PARTITION BY asgn_status ORDER BY asgn_enddate DESC) theRowNum ';
SET @subJoin = N') sub on stops.lgh_number = sub.lgh_number ';
SET @StatusSQL = N'AND asgn_status IN (''STD'', ''CMP'') ';

If @Current = 1
BEGIN
  If @Arrive = 1
    BEGIN
      IF @Flags & 1 = 1 
        SET @StatusSQL = N' AND asgn_status in (''STD'' ,''DSP'',''PLN'') '; --could be first stop
      ELSE
        SET @StatusSQL = N' AND asgn_status in (''STD'' ,''DSP'') '; --could be first stop
      
      SET @mainWhere = @mainWhere + N'AND stp_status = ''OPN'' AND stp_departure_status = ''OPN'' ';
      SET @SubSelectSQL = N' lgh_number, asgn_status ';
    END
    ELSE --Depart
    BEGIN
      SET @mainWhere = @mainWhere + N'AND stp_status = ''DNE'' AND stp_departure_status = ''OPN'' ';
    END
END
ELSE
BEGIN
  IF @Arrive = 1
    SET @mainWhere = @mainWhere + N'AND stp_status = ''DNE'' ';
  ELSE
    SET @mainWhere = @mainWhere + N'AND stp_status = ''DNE'' AND stp_departure_status = ''DNE'' ';
END

IF LEN(@SubSelectSQL) > 35 --must filter rowNum
  SET @mainWhere = @mainWhere + N'AND sub.theRowNum = 1 ';


SET @GetLegAGSQL = N'(SELECT DISTINCT ' + @SubSelectSQL+ 'FROM assetassignment WHERE '
                   + @AssetSQL + @StatusSQL + @subJoin;

SET @MainAGSQL = N'SELECT stops.stp_number, stops.lgh_number, stops.ord_hdrnumber, ' +
                 N'sub.asgn_status, stops.stp_dispatched_sequence FROM stops Join '
                 + @GetLegAGSQL + @mainWhere;


--Select @MainAGSQL
INSERT INTO @Results
EXEC sp_executesql @MainAGSQL,
                   N' @CMPID VARCHAR(8),
                      @Truck VARCHAR(20),
                      @Driver VARCHAR(20),
                      @Trailer VARCHAR(20)',
                      @CMPID = @CMPID,
                      @Truck = @Truck,
                      @Driver = @Driver,
                      @Trailer = Trailer;

SELECT @ResultCount =  COUNT(1) FROM @Results
IF (@ResultCount) > 1
  IF @Flags & 2 = 2 or (@Arrive = 1 AND @Current = 1)
    SELECT 0, 0, 0, 'Ambiguous Stop, no stop returned';
  Else IF (SELECT count(DISTINCT lgh_number)
            FROM @Results) = 1 --multi-Event, Return first
    SELECT TOP 1 stp_number, lgh_number, ord_hdrnumber, 'Multi-Stop at same location' FROM @Results
    WHERE stp_dispatched_sequence IS NOT NULL
    ORDER BY stp_dispatched_sequence;

  ELSE IF (SELECT count(DISTINCT lgh_number) 
           FROM @Results
           WHERE asgn_status = 'STD') = 1 --Started trumps CMP
    SELECT TOP 1 stp_number, lgh_number, ord_hdrnumber, 'Best Fit Stop' FROM @Results
    WHERE stp_dispatched_sequence IS NOT NULL
	    AND asgn_status = 'STD'
    ORDER BY stp_dispatched_sequence;

  ELSE
    SELECT 0,	0,	0, 'Ambiguous Stop, no stop returned';
ELSE IF (@ResultCount) < 1
  SELECT 0,	0,	0, 'No such Stop found';
ELSE
  SELECT stp_number, lgh_number, ord_hdrnumber, 'Stop Found' FROM @Results;
GO
GRANT EXECUTE ON  [dbo].[tmail_OTGeo_FindStop] TO [public]
GO
