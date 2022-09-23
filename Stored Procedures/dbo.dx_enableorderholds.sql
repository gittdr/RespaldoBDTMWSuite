SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  Sets the ord_status and lgh_outstatus of an order based on the presence of the SHPSTS reference number
  
  RETURNS:
  A return value of zero indicates success. A non-zero return value indicates a failure of some type

  RESULT SETS: 
  Returns the ordernumber and error code to LTSL subsequent to execution of the stored procedure..
 
  PARAMETERS:
  001 - @ord_hdrnumber, int, input, not null;
        This parameter indicates the order number of the newly created order in TMWSuite
 
  REFERENCES:
  None

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  xx/xx/xxxx   ?                ?             Created
  04/01/2016   John Richardson  PTS: 78247    On 204 import when a Bill of Lading reference number
--  exists and the reference qualifier matches the reference number record for the Bill of Lading 
-- in Label Files, it will not match correctly because the retired value in labelfiles is NULL instead of equal to 'N'
  04/15/2016   Lisa Bohm        PTS: 78247    Rewrote the loops into a cursor and cleaned up code
********************************************************************************************************************/

CREATE PROCEDURE [dbo].[dx_enableorderholds] @ord_hdrnumber int
AS

SET NOCOUNT ON;

DECLARE @mov_number int
  , @stpnum int
  , @ord_status varchar(6)
  , @orig_status varchar(6)
  , @errormsg varchar(255)
  , @IsOrderOnEDITab bit
  , @ref_type varchar(6)
	
--Begin postprocessing SQL
SELECT @orig_status = ord_status
FROM orderheader
WHERE ord_hdrnumber = @ord_hdrnumber;

IF EXISTS(
  SELECT 1 
  FROM 
    orderheader (nolock) 
  INNER JOIN  
    edi_orderstate (nolock) on ISNULL(ord_edistate,0) = esc_code 
  WHERE 
    ord_hdrnumber = @ord_hdrnumber 
    AND (ISNULL(ord_edistate,0) > 39 
      OR esc_useractionrequired = 'Y'))
  BEGIN
    SET @IsOrderOnEDITab = 1
  END  
ELSE
  BEGIN
    SET @IsOrderOnEDITab = 0
  END
	
SELECT
  TOP 1 @mov_number = mov_number 
FROM
  stops 
WHERE
  ord_hdrnumber = @ord_hdrnumber;

IF @orig_status IN ('PND','PNH') AND @IsOrderOnEDITab = 1
BEGIN
	RETURN 0
END
	
SET @ord_status = @orig_status;

SET @ref_type = COALESCE((SELECT abbr 
    FROM 
      labelfile 
    WHERE 
      labeldefinition = 'ReferenceNumbers' 
      AND edicode = @ref_type 
      AND ISNULL(retired, 'N') <> 'Y'),'SHPSTS');


SELECT TOP 1 
  @ord_status = IsNull(ref_number, @orig_status)
FROM 
  referencenumber 
WHERE 
  ord_hdrnumber = @ord_hdrnumber 
  AND ref_table = 'orderheader'
  AND ref_type = @ref_type
ORDER BY ref_sequence DESC;	
		
IF EXISTS (
  SELECT 1 
  FROM 
    orderhold 
  WHERE ord_hdrnumber = @ord_hdrnumber 
    and ohld_active = 'Y')
	BEGIN
    SET @ord_status = substring(@ord_status, 1, 2) + 'H';
	END
	
DECLARE @hasAppt bit;

IF EXISTS(
  SELECT 1 
  FROM 
    dbo.[event] 
  WHERE evt_eventcode= 'SAP'
  AND evt_status='DNE' 
  AND stp_number IN (SELECT 
                      stp_number 
                    FROM 
                      stops
                    WHERE ord_hdrnumber = @ord_hdrnumber))
  BEGIN
    SET @hasAppt = 1;
  END
ELSE
  BEGIN
    SET @hasAppt = 0;
  END

DECLARE @stopsList TABLE (stpNumber int);
DECLARE @currStopNum int;
  
IF @orig_status <> @ord_status AND NOT (@ord_status = 'PFP' 
          AND (@orig_status in ('STD','PLN','DSP','CMP') 
          OR @hasAppt = 1))
BEGIN
  INSERT INTO @stopsList (stpNumber)
  SELECT 
    stp_number
  FROM 
    dbo.stops
  WHERE ord_hdrnumber = @ord_hdrnumber;

  DECLARE @stopListUpdate CURSOR;
  SET @stopListUpdate = CURSOR FAST_FORWARD FOR
  SELECT stpNumber
  FROM @stopsList;
    
  OPEN @stopListUpdate
  FETCH NEXT
  FROM @stopListUpdate INTO @currStopNum
  WHILE @@FETCH_STATUS = 0
  BEGIN
  IF @ord_status NOT IN ('AVL','CBR','PCU')
    BEGIN
      UPDATE a
			SET 	stp_status = 'NON'
      FROM dbo.stops a
      WHERE 	stp_number = @currStopNum;
    END
  ELSE
      BEGIN
      UPDATE a
			SET 	stp_status = 'OPN'
      FROM dbo.stops a
      WHERE 	stp_number = @currStopNum;
    END
    
  FETCH NEXT
  FROM @stopListUpdate INTO @currStopNum
  END
  CLOSE @stopListUpdate
  DEALLOCATE @stopListUpdate  
END
	
DECLARE @inv_when varchar(6);
SELECT 
  @inv_when = ISNULL(gi_string1,'') 
FROM
  generalinfo 
WHERE gi_name = 'LTSL_Invoice_When';

IF RTRIM(ISNULL(@inv_when,'')) = '' 
  SET @inv_when = 'CMP'
	EXEC update_ord @mov_number, @inv_when
	EXEC update_move_light @mov_number
	
IF (NOT (@ord_status = 'PFP' AND 
    (@orig_status in ('STD','PLN','DSP','CMP') 
    OR @hasAppt = 1)))
	BEGIN
			UPDATE orderheader 				
      SET ord_status = @ord_status
        ,ord_pendinglegstatusupdate = 'Y'
			WHERE ord_hdrnumber = @ord_hdrnumber;
	END
RETURN 1
GO
GRANT EXECUTE ON  [dbo].[dx_enableorderholds] TO [public]
GO
