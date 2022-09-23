SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* GeoFuel Update ***********************************************************
** Used for updating the amount of fuel in a truck as sent by driver 
** Created:		Matthew Zerefos
**			10/20/98
*********************************************************************************/

CREATE PROCEDURE [dbo].[tmail_geofuel_update_sp]
	@lgh int,
	@tankfraction real,
	@gallons int,
	@errmess varchar(128) OUT

AS

SET NOCOUNT ON 


DECLARE @tankgallons int,
	@tankcapacity int,
	@lghtest int,
	@sT_1 varchar(200), 
	@sT_2 varchar(20) 	--Translation String

SELECT @errmess = ''

--****** Test if there is a record for the current leg header in the table geofuelrequests
SELECT @lghtest = COUNT(gf_lgh_number)
FROM geofuelrequest (NOLOCK)
WHERE gf_lgh_number = @lgh

IF @lghtest > 0 		 --*** There is a record in geofuelrequest for this lgh, so do the update
  BEGIN
    IF @gallons = 0 		 --*** Use tankfraction not gallons
        BEGIN
        SELECT @tankcapacity = gf_tank_cap
        FROM geofuelrequest
        WHERE gf_lgh_number = @lgh
        SELECT @tankgallons = @tankcapacity * @tankfraction
        END
    ELSE
        SELECT @tankgallons = @gallons

    UPDATE geofuelrequest
    SET gf_tank_gals = @tankgallons,
           gf_status = 'RUN'
    WHERE gf_lgh_number = @lgh
  END
ELSE		 --*** There is no record in geofuelrequest for this lgh, so return an error message
	BEGIN	
	SELECT @sT_1 = 'No record for leg header ~1 found in table geofuelrequest.'
	SELECT @sT_2 = RTRIM(CONVERT (char(20), @lgh))
	EXEC dbo.tmail_sprint @sT_1 OUT, @sT_2, '', '','','','','','','',''
--	EXEC dbo.tm_t_sp @sT_1 OUT, 1, ''
	SELECT @errmess = @sT_1
	END

SELECT @errmess
GO
GRANT EXECUTE ON  [dbo].[tmail_geofuel_update_sp] TO [public]
GO
