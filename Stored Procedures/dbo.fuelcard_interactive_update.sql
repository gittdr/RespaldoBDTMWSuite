SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[fuelcard_interactive_update] ( 
	@vendor VARCHAR(6) , 
	@assettype VARCHAR(6) = Null, 
	@assetid VARCHAR(6) = Null, 
	@options INT =  Null
) 
AS 

DECLARE @lgh INT, 
        @asgn_number INT, 
        @crdnbr VARCHAR(20), 
        @crddrv VARCHAR(8), 
        @crdstatus VARCHAR(6) 

SET NOCOUNT ON 

DECLARE cur_cashcard CURSOR FOR 
SELECT c.crd_cardnumber, c.crd_driver, c.crd_status 
  FROM cashcard c 
  JOIN manpowerprofile m ON c.crd_driver = m.mpp_id 
 WHERE crd_vendor = @vendor
       AND ISNULL( c.crd_driver, 'UNKNOWN' ) <> 'UNKNOWN' 
       AND c.crd_driver = CASE WHEN @assetid IS NULL THEN c.crd_driver ELSE @assetid END 
ORDER BY c.crd_cardnumber 

OPEN cur_cashcard 

FETCH NEXT FROM cur_cashcard 
INTO @crdnbr , @crddrv , @crdstatus 

WHILE @@FETCH_STATUS = 0
BEGIN 
	
	SELECT @lgh = NULL , @asgn_number = NULL 

	EXEC cur_activity_asgn_number 'DRV', @crddrv , @lgh OUTPUT, @asgn_number OUTPUT 
	
	INSERT FuelCardUpdateQueue 
	( fcuq_update_type, fcuq_asgn_type, fcuq_asgn_id, lgh_number, fcuq_updatedon ) 
	VALUES ( 'TRIP' , 'DRV' , @crddrv , @lgh, GETDATE() ) 
	
	PRINT 'Processing Card#:' + @crdnbr 
	+ ', Inserted FuelCardUpdateQueue row for Driver:' + @crddrv 
	+ ', Seg#:' + CASE WHEN @lgh = 0 THEN '[No Activity]' ELSE ISNULL( CONVERT(VARCHAR(20), @lgh ) , '[No Activity]' ) END 
	+ ', Asgn#: ' + ISNULL( CONVERT(VARCHAR(20), @asgn_number ) , '[No Activity]' ) 
	
	FETCH NEXT FROM cur_cashcard 
	INTO @crdnbr , @crddrv , @crdstatus 
END 

CLOSE cur_cashcard 
DEALLOCATE cur_cashcard 

SET NOCOUNT OFF 

GO
GRANT EXECUTE ON  [dbo].[fuelcard_interactive_update] TO [public]
GO
