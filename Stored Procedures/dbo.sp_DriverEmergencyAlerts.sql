SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_DriverEmergencyAlerts]
    (
      @asgn_id VARCHAR(13) ,
      @cmp_id VARCHAR(8) ,
      @Stp_Number INT ,
      @City_Code INT ,
      @EventDate DATETIME ,
      @latitude DECIMAL(12, 4) ,
      @Longitude DECIMAL(12, 4) ,
      @latitudeSeconds INTEGER ,
      @LongitudeSeconds INTEGER


    )
AS /*
 * NAME:
 * dbo.SP_DriverEmergencyAlerts
 *
 * TYPE:
 * storedprocedure
 *
 * DESCRIPTION:
 * it will Find any ActiveAlerts in the geographic regions and returns messages that can be sent to totalMail. 

 * RETURNS:
 *
 * RESULT SETS: 
 * 
 
 * REFERENCES:
 * 
 * REVISION HISTORY:
 
 **/ 

  
    DECLARE @City_latitude DECIMAL(12, 4)
    DECLARE @City_Longitude DECIMAL(12, 4)

    IF ( @latitude <> 0.0
         AND @Longitude <> 0.0
       ) 
        BEGIN
            SELECT  DriverEmergencyAlerts.id ,
                    DriverEmergencyAlerts.FriendlyMessage
            FROM    DriverEmergencyAlerts
            WHERE   DriverEmergencyAlerts.alertActiveFlag = 'Y'
                    AND DriverEmergencyAlerts.ExpirationDate > @EventDate
                    AND dbo.tmw_airdistance_fn(@latitude, @Longitude,
                                               DriverEmergencyAlerts.AlertArea_latitude,
                                               DriverEmergencyAlerts.AlertArea_Longitude) < DriverEmergencyAlerts.AlertRadius
        END

    ELSE 
        IF ( @latitudeSeconds <> 0
             AND @LongitudeSeconds <> 0
           ) 
            BEGIN
                SELECT  DriverEmergencyAlerts.id ,
                        DriverEmergencyAlerts.FriendlyMessage
                FROM    DriverEmergencyAlerts
                WHERE   DriverEmergencyAlerts.alertActiveFlag = 'Y'
                        AND DriverEmergencyAlerts.ExpirationDate > @EventDate
                        AND dbo.fnc_AirMilesBetweenLatLongSeconds(@latitudeSeconds,
                                                              DriverEmergencyAlerts.AlertArea_latitude*3600.00,
                                                              @LongitudeSeconds,
                                                              DriverEmergencyAlerts.AlertArea_Longitude*3600.00) < DriverEmergencyAlerts.AlertRadius
            END


        ELSE 
            IF ( @City_Code > 0 ) 
                BEGIN
                    SELECT  @City_latitude = City.cty_latitude ,
                            @City_Longitude = City.cty_longitude
                    FROM    city
                    WHERE   cty_code = @City_Code

                    SELECT  DriverEmergencyAlerts.id ,
                            DriverEmergencyAlerts.FriendlyMessage
                    FROM    DriverEmergencyAlerts
                    WHERE   DriverEmergencyAlerts.alertActiveFlag = 'Y'
                            AND DriverEmergencyAlerts.ExpirationDate > @EventDate
                            AND dbo.tmw_airdistance_fn(@City_latitude,
                                                       @City_Longitude,
                                                       DriverEmergencyAlerts.AlertArea_latitude,
                                                       DriverEmergencyAlerts.AlertArea_Longitude) < DriverEmergencyAlerts.AlertRadius
                END

            ELSE 
                IF ( @cmp_id <> '' ) 
                    BEGIN

                        SELECT  @City_latitude = City.cty_latitude ,
                                @City_Longitude = City.cty_longitude
                        FROM    city
                                INNER JOIN Company ON Company.cmp_city = City.cty_code
                                                      AND Company.cmp_id = @cmp_id

                        SELECT  DriverEmergencyAlerts.id ,
                                DriverEmergencyAlerts.FriendlyMessage
                        FROM    DriverEmergencyAlerts
                        WHERE   DriverEmergencyAlerts.alertActiveFlag = 'Y'
                                AND DriverEmergencyAlerts.ExpirationDate > @EventDate
                                AND dbo.tmw_airdistance_fn(@City_latitude,
                                                           @City_Longitude,
                                                           DriverEmergencyAlerts.AlertArea_latitude,
                                                           DriverEmergencyAlerts.AlertArea_Longitude) < DriverEmergencyAlerts.AlertRadius
                    END





GO
GRANT EXECUTE ON  [dbo].[sp_DriverEmergencyAlerts] TO [public]
GO
