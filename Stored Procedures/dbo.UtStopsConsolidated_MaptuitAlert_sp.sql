SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_MaptuitAlert_sp]
(
  @inserted UtStopsConsolidated READONLY,
  @deleted  UtStopsConsolidated READONLY,
  @GETDATE  DATETIME
)
AS

DECLARE @DTL TABLE (m2qdkey VARCHAR(100))
DECLARE @TargetRecordCount  INTEGER,
        @m2qhid             INTEGER

INSERT @DTL 
  VALUES ('STop_OrderID'),
         ('Stop_StopID'),
         ('Stop_StopType'),
         ('Stop_LocationID'),
         ('Stop_CityName'),
         ('Stop_RegionCode'),
         ('Stop_WindowStart'),
         ('Stop_WindowEnd'),
         ('Stop_ArrivalTime'),
         ('Timestamp'),
         ('Stop_LoadUnloadTime');

SELECT  @TargetRecordCount = COUNT(1)
  FROM  @inserted i
          INNER JOIN @deleted d ON d.stp_number = i.stp_number
 WHERE  i.ord_hdrnumber > 0
   AND  d.stp_status = 'OPN' 
   AND  i.stp_status = 'DNE'

IF @TargetRecordCount > 0 
BEGIN 
  EXECUTE @m2qhid = dbo.getsystemnumberblock 'M2QHID', '', @TargetRecordCount;

  INSERT INTO dbo.m2msgqdtl
    (
      m2qdid,
      m2qdkey,
      m2qdcrtpgm,
      m2qdvalue
    ) 
    SELECT  m2qdid,
            m2qdkey,
            m2qdcrtpgm,
            m2qdvalue
      FROM  (SELECT SubQuery.Futurem2qhid m2qdid,
                    DTL.m2qdkey,
                    'HIL' m2qdcrtpgm,
                    CASE DTL.m2qdkey
                      WHEN 'Stop_OrderID' THEN ord_number
                      WHEN 'Stop_StopID' THEN CONVERT(VARCHAR(20), stp_mfh_sequence)
                      WHEN 'Stop_StopType' THEN stp_type
                      WHEN 'Stop_LocationID' THEN NULLIF(cmp_id, 'UNKNOWN')
                      WHEN 'Stop_CityName' THEN cty_name
                      WHEN 'Stop_RegionCode' THEN stp_state
                      WHEN 'Stop_WindowStart' THEN CONVERT(VARCHAR, stp_schdtearliest, 20)
                      WHEN 'Stop_WindowEnd' THEN  CONVERT(VARCHAR, stp_schdtlatest, 20)
                      WHEN 'Stop_ArrivalTime' THEN CONVERT(VARCHAR, stp_arrivaldate, 20)
                      WHEN 'Timestamp' THEN CONVERT(VARCHAR, @GETDATE, 20)
                    END AS m2qdvalue
               FROM @DTL DTL,
                    (SELECT oh.ord_number,
                            i.stp_mfh_sequence,
                            CASE 
                              WHEN i.stp_type = 'PUP' OR i.stp_event = 'XDL' THEN 'PICK'
                              WHEN i.stp_type = 'DRP' OR i.stp_event = 'XDU' THEN 'DROP'
                            END AS stp_type,
                            i.stp_arrivaldate,
                            i.stp_schdtearliest,
                            i.stp_schdtlatest,
                            i.cmp_id,
                            i.stp_state,
                            c.cty_name,
                            ROW_NUMBER () OVER (ORDER BY i.stp_number) + @m2qhid - 1 Futurem2qhid 
                       FROM @inserted i   
                              INNER JOIN @deleted d ON d.stp_number = i.stp_number
                              INNER JOIN dbo.orderheader oh WITH(NOLOCK) ON oh.ord_hdrnumber = i.ord_hdrnumber
                              INNER JOIN dbo.city c WITH(NOLOCK) ON c.cty_code = i.stp_city
                      WHERE i.ord_hdrnumber > 0
                        AND d.stp_status = 'OPN' 
                        AND i.stp_status = 'DNE') AS subQuery
              WHERE DTL.m2qdkey <> 'Stop_LoadUnloadTime') AS SubQuery2
     WHERE  m2qdvalue IS NOT NULL;

  INSERT INTO dbo.m2msgqhdr
    SELECT  @m2qhid + n - 1,
            'ChangeStop',
            @GETDATE,
            'R'
      FROM  dbo.ident_numbers
     WHERE  n <= @TargetRecordCount
END

SELECT  @TargetRecordCount = COUNT(1)
  FROM  @inserted i
          INNER JOIN @deleted d ON d.stp_number = i.stp_number
 WHERE  i.ord_hdrnumber > 0
   AND  d.stp_departure_status = 'OPN' 
   AND  i.stp_departure_status = 'DNE'

IF @TargetRecordCount > 0 
BEGIN 
  EXECUTE @m2qhid = dbo.getsystemnumberblock 'M2QHID', '', @TargetRecordCount;

  INSERT INTO dbo.m2msgqdtl
    (
      m2qdid,
      m2qdkey,
      m2qdcrtpgm,
      m2qdvalue
    ) 
    SELECT  m2qdid,
            m2qdkey,
            m2qdcrtpgm,
            m2qdvalue
      FROM  (SELECT SubQuery.Futurem2qhid m2qdid,
                    DTL.m2qdkey,
                    'HIL' m2qdcrtpgm,
                    CASE DTL.m2qdkey
                      WHEN 'Stop_OrderID' THEN ord_number
                      WHEN 'Stop_StopID' THEN CONVERT(VARCHAR(20), stp_mfh_sequence)
                      WHEN 'Stop_StopType' THEN stp_type
                      WHEN 'Stop_LocationID' THEN NULLIF(cmp_id, 'UNKNOWN')
                      WHEN 'Stop_CityName' THEN cty_name
                      WHEN 'Stop_RegionCode' THEN stp_state
                      WHEN 'Stop_WindowStart' THEN CONVERT(VARCHAR, stp_schdtearliest, 20)
                      WHEN 'Stop_WindowEnd' THEN  CONVERT(VARCHAR, stp_schdtlatest, 20)
                      WHEN 'Stop_ArrivalTime' THEN CONVERT(VARCHAR, stp_arrivaldate, 20)
                      WHEN 'Stop_LoadUnloadTime' THEN CONVERT(VARCHAR, stp_departuredate, 20)
                      WHEN 'Timestamp' THEN CONVERT(VARCHAR, @GETDATE, 20)
                    END AS m2qdvalue
               FROM @DTL DTL,
                    (SELECT oh.ord_number,
                            i.stp_mfh_sequence,
                            CASE 
                              WHEN i.stp_type = 'PUP' OR i.stp_event = 'XDL' THEN 'PICK'
                              WHEN i.stp_type = 'DRP' OR i.stp_event = 'XDU' THEN 'DROP'
                            END AS stp_type,
                            i.stp_arrivaldate,
                            i.stp_departuredate,
                            i.stp_schdtearliest,
                            i.stp_schdtlatest,
                            i.cmp_id,
                            i.stp_state,
                            c.cty_name,
                            ROW_NUMBER () OVER (ORDER BY i.stp_number) + @m2qhid - 1 Futurem2qhid 
                       FROM @inserted i   
                              INNER JOIN @deleted d ON d.stp_number = i.stp_number
                              INNER JOIN dbo.orderheader oh WITH(NOLOCK) ON oh.ord_hdrnumber = i.ord_hdrnumber
                              INNER JOIN dbo.city c WITH(NOLOCK) ON c.cty_code = i.stp_city
                      WHERE i.ord_hdrnumber > 0
                        AND d.stp_departure_status = 'OPN' 
                        AND i.stp_departure_status = 'DNE') AS subQuery) AS SubQuery2
     WHERE  m2qdvalue IS NOT NULL;

  INSERT INTO dbo.m2msgqhdr
    SELECT  @m2qhid + n - 1,
            'ChangeStop',
            @GETDATE,
            'R'
      FROM  dbo.ident_numbers
     WHERE  n <= @TargetRecordCount
END

GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_MaptuitAlert_sp] TO [public]
GO
