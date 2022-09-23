SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[DrvExpStatus_GetActivity_fn]
(
  @asgnId       VARCHAR(13),
  @statusCodes  TMWTable_char6 READONLY
)
RETURNS @DrvExpStatusGetActivity TABLE 
    (lgh_number             INTEGER     NOT NULL,
     Status                 VARCHAR(6)  NOT NULL,
     Event                  VARCHAR(6)  NOT NULL,
     AvailableCompany       VARCHAR(8)  NOT NULL,
     AvailableCity          INTEGER     NOT NULL,
     AvailableDate          DATETIME    NOT NULL,
     Tractor                VARCHAR(8)  NOT NULL,
     Driver1                VARCHAR(8)  NOT NULL,
     Driver2                VARCHAR(8)  NOT NULL,
     Trailer1               VARCHAR(13) NOT NULL,  
     Trailer2               VARCHAR(13) NOT NULL,  
     Carrier                VARCHAR(8)  NOT NULL,
     CurrentHubMiles        INTEGER     NULL,
     PriorEvent             VARCHAR(6)  NULL,
     PriorCompany           VARCHAR(8)  NULL,
     PriorCity              INTEGER     NULL,
     PriorState             VARCHAR(6)  NULL,
     PriorRegion1           VARCHAR(6)  NULL,
     PriorRegion2           VARCHAR(6)  NULL,
     PriorRegion3           VARCHAR(6)  NULL,
     PriorRegion4           VARCHAR(6)  NULL,
     PriorCompanyOtherType1 VARCHAR(6)  NULL,
     NextEvent              VARCHAR(6)  NULL,
     NextCompany            VARCHAR(8)  NULL,
     NextCity               INTEGER     NULL,
     NextState              VARCHAR(6)  NULL,
     NextRegion1            VARCHAR(6)  NULL,
     NextRegion2            VARCHAR(6)  NULL,
     NextRegion3            VARCHAR(6)  NULL,
     NextRegion4            VARCHAR(6)  NULL,
     NextCompanyOtherType1  VARCHAR(6)  NULL)
AS
BEGIN
  INSERT @DrvExpStatusGetActivity
    SELECT TOP 1
            aa.lgh_number lgh_number,
            aa.asgn_status Status,
            availableStop.stp_event Event,
            availableStop.cmp_id AvailableCompany,
            availableStop.stp_city AvailableCity,
            aa.asgn_enddate AvailableDate,
            assetEvent.evt_tractor Tractor,
            assetEvent.evt_driver1 Driver1,
            assetEvent.evt_driver2 Driver2,
            assetEvent.evt_trailer1 Trailer1,
            assetEvent.evt_trailer2 Trailer2,
            assetEvent.evt_carrier Carrier,
            assetEvent.evt_hubmiles CurrentHubReading,
            priorStop.stp_event PriorEvent,
            priorStop.cmp_id PriorCompany,
            priorStop.stp_city PriorCity,
            priorCity.cty_state PriorState,
            priorCity.cty_region1 PriorRegion1,
            priorCity.cty_region2 PriorRegion2,
            priorCity.cty_region3 PriorRegion3,
            priorCity.cty_region4 PriorRegion4,
            priorCompany.cmp_othertype1 PriorCompanyOtherType1,
            nextStop.stp_event NextEvent,
            nextStop.cmp_id NextCompany,
            nextStop.stp_city NextCity,
            nextCity.cty_state NextState,
            nextCity.cty_region1 NextRegion1,
            nextCity.cty_region2 NextRegion2,
            nextCity.cty_region3 NextRegion3,
            nextCity.cty_region4 NextRegion4,
            nextCompany.cmp_othertype1 NextCompanyOtherType1
      FROM  assetassignment aa
              INNER JOIN event lastEvent ON lastEvent.evt_number = aa.last_evt_number
              INNER JOIN stops availableStop ON availableStop.stp_number = lastEvent.stp_number
              INNER JOIN event assetEvent ON assetEvent.stp_number = availableStop.stp_number and assetEvent.evt_sequence = 1
              LEFT OUTER JOIN event priorEvent ON priorEvent.evt_number = aa.last_dne_evt_number
              LEFT OUTER JOIN stops priorStop ON priorStop.stp_number = priorEvent.stp_number
              LEFT OUTER JOIN city priorCity ON priorCity.cty_code = priorStop.stp_city
              LEFT OUTER JOIN company priorCompany ON priorCompany.cmp_id = priorStop.cmp_id
              LEFT OUTER JOIN event nextEvent on nextEvent.evt_number =  aa.next_opn_evt_number
              LEFT OUTER JOIN stops nextStop ON nextStop.stp_number = nextEvent.stp_number
              LEFT OUTER JOIN city nextCity ON nextCity.cty_code = nextStop.stp_city
              LEFT OUTER JOIN company nextCompany ON nextCompany.cmp_id = nextStop.cmp_id
     WHERE  aa.asgn_type = 'DRV'
       AND  aa.asgn_id = @asgnId
       AND  aa.asgn_status IN (SELECT KeyField FROM @statusCodes)
    ORDER BY aa.asgn_enddate DESC
  RETURN
END  
GO
GRANT SELECT ON  [dbo].[DrvExpStatus_GetActivity_fn] TO [public]
GO
