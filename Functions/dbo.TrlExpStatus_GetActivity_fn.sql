SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[TrlExpStatus_GetActivity_fn]
(
  @asgnId       VARCHAR(13),
  @statusCodes  TMWTable_char6 READONLY
)
RETURNS @TrlExpStatusGetActivity TABLE 
    (mov_number               INTEGER     NOT NULL,
     lgh_number               INTEGER     NOT NULL,
     asgn_status              VARCHAR(6)  NOT NULL,
     asgn_number              INTEGER     NOT NULL,
     asgn_date                DATETIME    NOT NULL,
     asgn_enddate             DATETIME    NOT NULL,
     AvailableCompany         VARCHAR(8)  NOT NULL,
     AvailableCity            INTEGER     NOT NULL,
     SplitTrip                CHAR(1)     NOT NULL,
     FirstAssignment          CHAR(1)     NOT NULL,
     LastAssignment           CHAR(1)     NOT NULL,
     LastStopEvent            VARCHAR(6)  NOT NULL,
     LastStopStatus           VARCHAR(6)  NOT NULL,
     LastStopDepartureStatus  VARCHAR(6)  NOT NULL,
     LastEventEvent           VARCHAR(6)  NOT NULL,
     LastEventStatus          VARCHAR(6)  NOT NULL,
     LastEventDepartureStatus VARCHAR(6)  NOT NULL,
     FistSplitFirstStopStatus VARCHAR(6)  NULL,
     LastSplitAvailableDate   DATETIME    NULL,
     LastSplitLastStopCompany VARCHAR(8)  NULL,
     LastSplitLastStopCity    INTEGER     NULL,
     Preload                  CHAR(1)     NOT NULL,
     PreloadStopStatus        VARCHAR(6)  NULL,
     PreloadEventStatus       VARCHAR(6)  NULL,
     NextEvent                VARCHAR(6)  NULL,
     NextCompany              VARCHAR(8)  NULL,
     NextCity                 INTEGER     NULL,
     NextState                VARCHAR(6)  NULL,
     NextRegion1              VARCHAR(6)  NULL,
     NextRegion2              VARCHAR(6)  NULL,
     NextRegion3              VARCHAR(6)  NULL,
     NextRegion4              VARCHAR(6)  NULL,
     NextCompanyOtherType1    VARCHAR(6)  NULL,
     PriorEvent               VARCHAR(6)  NULL,
     PriorCompany             VARCHAR(8)  NULL,
     PriorCity                INTEGER     NULL,
     PriorState               VARCHAR(6)  NULL,
     PriorRegion1             VARCHAR(6)  NULL,
     PriorRegion2             VARCHAR(6)  NULL,
     PriorRegion3             VARCHAR(6)  NULL,
     PriorRegion4             VARCHAR(6)  NULL,
     PriorCompanyOtherType1   VARCHAR(6)  NULL,
     LastStop                 INTEGER     NULL)
AS
BEGIN
  INSERT @TrlExpStatusGetActivity
    SELECT TOP 1
            CurrentAssignment.mov_number,
            CurrentAssignment.lgh_number,
            CurrentAssignment.asgn_status,
            CurrentAssignment.asgn_number,
            CurrentAssignment.asgn_date,
            CurrentAssignment.asgn_enddate,
            CurrentLastStop.cmp_id AvailableCompany,
            CurrentLastStop.stp_city AvailableCity,
            CASE  
              WHEN CurrentLastStop.stp_event = 'DLT'  OR CurrentFirstStop.stp_event IN ('HCT', 'HLT') THEN 'Y' 
              ELSE 'N'
            END SplitTrip,
            CASE 
              WHEN CurrentAssignment.asgn_number = CurrentAssignment.asgn_trl_first_asgn THEN 'Y'
              ELSE 'N'
            END FirstAssignment,
            CASE 
              WHEN CurrentAssignment.asgn_number = CurrentAssignment.asgn_trl_last_asgn THEN 'Y'
              ELSE 'N'
            END LastAssignment,
            CurrentLastStop.stp_event LastStopEvent,
            COALESCE(CurrentLastStop.stp_status, 'OPN') LastStopStatus,
            COALESCE(CurrentLastStop.stp_departure_status, 'OPN') LastStopDepartureStatus,
            CurrentLastEvent.evt_eventcode LastEventEvent,
            COALESCE(CurrentLastEvent.evt_status, 'OPN') LastEventStatus,
            COALESCE(CurrentLastEvent.evt_departure_status, 'OPN') LastEventDepartureStatus,
            FirstSplitFirstStop.stp_status FistSplitFirstStopStatus,
            LastSplitAssignment.asgn_enddate LastSplitAvailableDate,
            LastSplitSegmentLastStop.cmp_id LastSplitLastStopCompany,
            LastSplitSegmentLastStop.stp_city LastSplitLastStopCity,
            CASE 
              WHEN COALESCE(CurrentAssignment.asgn_pld_event, 0) > 0 THEN 'Y'
              ELSE 'N'
            END Preload,
            PreloadStop.stp_status PreloadStopStatus,
            PreloadEvent.evt_status PreloadEventStatus,
            NextStop.stp_event NextEvent,
            NextStop.cmp_id NextCompany,
            NextStop.stp_city NextCity,
            NextCity.cty_state NextState,
            NextCity.cty_region1 NextRegion1,
            NextCity.cty_region2 NextRegion2,
            NextCity.cty_region3 NextRegion3,
            NextCity.cty_region4 NextRegion4,
            NextCompany.cmp_othertype1 NextCompanyOtherType1,
            PriorStop.stp_event PriorEvent,
            PriorStop.cmp_id PriorCompany,
            PriorStop.stp_city PriorCity,
            PriorCity.cty_state PriorState,
            PriorCity.cty_region1 PriorRegion1,
            PriorCity.cty_region2 PriorRegion2,
            PriorCity.cty_region3 PriorRegion3,
            PriorCity.cty_region4 PriorRegion4,
            PriorCompany.cmp_othertype1 PriorCompanyOtherType1,
            CurrentLastStop.stp_number LastStop
      FROM  assetassignment CurrentAssignment
              INNER JOIN legheader CurrentLegheader ON CurrentLegheader.lgh_number = CurrentAssignment.lgh_number
              INNER JOIN event CurrentFirstEvent ON CurrentFirstEvent.evt_number = CurrentAssignment.evt_number
              INNER JOIN stops CurrentFirstStop ON CurrentFirstStop.stp_number = CurrentFirstEvent.stp_number
              INNER JOIN event CurrentLastEvent ON CurrentLastEvent.evt_number = CurrentAssignment.last_evt_number
              INNER JOIN stops CurrentLastStop ON CurrentLastStop.stp_number = CurrentLastEvent.stp_number
              LEFT OUTER JOIN event PriorEvent ON PriorEvent.evt_number = CurrentAssignment.last_dne_evt_number
              LEFT OUTER JOIN stops PriorStop ON PriorStop.stp_number = PriorEvent.stp_number
              LEFT OUTER JOIN city PriorCity ON PriorCity.cty_code = PriorStop.stp_city
              LEFT OUTER JOIN company PriorCompany ON PriorCompany.cmp_id = PriorStop.cmp_id
              LEFT OUTER JOIN event NextEvent ON NextEvent.evt_number = CurrentAssignment.next_opn_evt_number
              LEFT OUTER JOIN stops NextStop ON NextStop.stp_number = NextEvent.stp_number
              LEFT OUTER JOIN city NextCity ON NextCity.cty_code = NextStop.stp_city
              LEFT OUTER JOIN company NextCompany ON NextCompany.cmp_id = NextStop.cmp_id
              LEFT OUTER JOIN assetassignment FirstSplitAssignment ON FirstSplitAssignment.asgn_number = CurrentAssignment.asgn_trl_first_asgn
              LEFT OUTER JOIN event FirstSplitFirstEvent ON FirstSplitFirstEvent.evt_number = FirstSplitAssignment.evt_number
              LEFT OUTER JOIN stops FirstSplitFirstStop ON FirstSplitFirstStop.stp_number = FirstSplitFirstEvent.stp_number
              LEFT OUTER JOIN assetassignment LastSplitAssignment ON LastSplitAssignment.asgn_number = CurrentAssignment.asgn_trl_last_asgn
              LEFT OUTER JOIN event LastSplitSegmentLastEvent ON LastSplitSegmentLastEvent.evt_number = LastSplitAssignment.last_evt_number
              LEFT OUTER JOIN stops LastSplitSegmentLastStop ON LastSplitSegmentLastStop.stp_number = LastSplitSegmentLastEvent.stp_number
              LEFT OUTER JOIN event PreloadEvent ON PreloadEvent.evt_number = CurrentAssignment.asgn_pld_event
              LEFT OUTER JOIN stops PreloadStop ON PreloadStop.stp_number = PreloadEvent.stp_number
       WHERE  CurrentAssignment.asgn_type = 'TRL'
         AND  CurrentAssignment.asgn_id = @asgnId
         AND  CurrentAssignment.asgn_status IN (SELECT KeyField FROM @statusCodes)
    ORDER BY CurrentAssignment.asgn_enddate DESC;

    WITH CTE AS
    (
      SELECT TOP 1
              e.stp_number,
              e.evt_eventcode,
              COALESCE(e.evt_status, 'OPN') evt_status,
              COALESCE(e.evt_departure_status, 'OPN') evt_departure_status
        FROM  @TrlExpStatusGetActivity Activity
                INNER JOIN event e ON e.stp_number = Activity.laststop
      ORDER BY e.evt_sequence DESC 
    )
    UPDATE  Activity
       SET  LastEventEvent = CTE.evt_eventcode,
            LastEventStatus = CTE.evt_status,
            LastEventDepartureStatus = CTE.evt_departure_status
      FROM  @TrlExpStatusGetActivity Activity
              INNER JOIN CTE ON CTE.stp_number = Activity.laststop
  RETURN
END  
GO
GRANT SELECT ON  [dbo].[TrlExpStatus_GetActivity_fn] TO [public]
GO
