SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TariffInputTSGetBuildMilesManuallyList]
( @TariffInputTS_Id  INT
) RETURNS @List TABLE
         ( ord_number                     VARCHAR(30)
         , stp_number                     INT
         , stp_event                      VARCHAR(8)
         , mile_typ_to_stop               VARCHAR(8)
         , mile_typ_from_stop             VARCHAR(8)
         , cmp_id                         VARCHAR(8)
         , cmp_name                       VARCHAR(50)
         , stp_city                       INT
         , stp_zipcode                    VARCHAR(15)
         , ect_billable                   VARCHAR(8)
         , stp_mfh_sequence               INT
         , stp_loadstatus                 VARCHAR(8)
         , stp_type                       VARCHAR(8)
         , stp_sequence                   INT
         , stopoffflag                    INT
         , minsatstop                     INT
         , allowdetention                 VARCHAR(8)
         , stp_ooa_mileage                DECIMAL(19,6)
         , stp_ooa_stop                   DECIMAL(19,6)
         , stp_reasonlate                 VARCHAR(8)
         , stp_type1                      VARCHAR(8)
         , stp_delayhours                 DECIMAL(19,6)
         , ord_hdrnumber                  INT
         , stp_ord_mileage                DECIMAL(19,6)
         , ord_no_recalc_miles            VARCHAR(8)
         , stp_arrivaldate                DATETIME
         )
AS
/**
 *
 * NAME:
 * dbo.fnc_TariffInputTSGetBuildMilesManuallyList
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns List from TariffInputTSBuildMilesManuallyList
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @TariffInputTS_Id   INT
 *
 * REVISION HISTORY:
 * PTS 76379 SPN 04/10/2014 - Initial Version Created
 *
 **/

BEGIN

   INSERT INTO @List (ord_number,stp_number,stp_event,mile_typ_to_stop,mile_typ_from_stop
                     ,cmp_id,cmp_name,stp_city,stp_zipcode,ect_billable,stp_mfh_sequence
                     ,stp_loadstatus,stp_type,stp_sequence,stopoffflag,minsatstop
                     ,allowdetention,stp_ooa_mileage,stp_ooa_stop,stp_reasonlate
                     ,stp_type1,stp_delayhours,ord_hdrnumber,stp_ord_mileage,ord_no_recalc_miles,stp_arrivaldate
                     )
   SELECT ord_number,stp_number,stp_event,mile_typ_to_stop,mile_typ_from_stop
        , cmp_id,cmp_name,stp_city,stp_zipcode,ect_billable,stp_mfh_sequence
        , stp_loadstatus,stp_type,stp_sequence,stopoffflag,minsatstop
        , allowdetention,stp_ooa_mileage,stp_ooa_stop,stp_reasonlate
        , stp_type1,stp_delayhours,ord_hdrnumber,stp_ord_mileage,ord_no_recalc_miles,stp_arrivaldate
     FROM TariffInputTSBuildMilesManuallyList
    WHERE TariffInputTS_Id = @TariffInputTS_Id

   RETURN

END
GO
GRANT REFERENCES ON  [dbo].[fnc_TariffInputTSGetBuildMilesManuallyList] TO [public]
GO
GRANT SELECT ON  [dbo].[fnc_TariffInputTSGetBuildMilesManuallyList] TO [public]
GO
