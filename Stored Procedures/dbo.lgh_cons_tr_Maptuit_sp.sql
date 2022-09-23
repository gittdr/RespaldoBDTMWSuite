SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[lgh_cons_tr_Maptuit_sp] (
	@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			        Handle logic for MapTuitGeocode ,MapTuitAlert ,MapTuitDirectionsOnDispatch GI setttings that are used in
											                  ut_legheader_consolidated.
********************************************************************************************************************/
DECLARE @MapTuitGeocode CHAR(1)
	,@MapTuitAlert CHAR(1)
	,@MapTuitDirectionsOnDispatch CHAR(1)
	,@COUNT INT
	,@m2qhid INT

SELECT	@MapTuitGeocode = CASE WHEN gi_name = 'MapTuitGeocode'	THEN LEFT(COALESCE(gi_string1, 'N'), 1)	ELSE @MapTuitGeocode END,
				@MapTuitAlert = CASE WHEN gi_name = 'MapTuitAlert'	THEN LEFT(COALESCE(gi_string1, 'N'), 1)	ELSE @MapTuitAlert END,
				@MapTuitDirectionsOnDispatch = CASE WHEN gi_name = 'MapTuitDirectionsOnDispatch' THEN LEFT(COALESCE(gi_string1, 'N'), 1) ELSE @MapTuitDirectionsOnDispatch END
FROM dbo.generalinfo
WHERE  gi_name IN ('MapTuitGeocode', 'MapTuitAlert', 'MapTuitDirectionsOnDispatch')

IF @MapTuitGeocode = 'Y'
BEGIN
  IF EXISTS(SELECT	1
              FROM	@inserted i
												INNER JOIN @deleted d ON i.lgh_number = d.lgh_number
             WHERE	i.lgh_outstatus = 'DSP' 
               AND	i.lgh_outstatus <> COALESCE(d.lgh_outstatus, 'AVL')
               AND	i.lgh_tractor <> 'UNKNOWN')
  BEGIN
			IF @MaptuitDirectionsOnDispatch = 'Y'
			BEGIN
					INSERT dbo.maptuitdirections 
					SELECT 
						i.lgh_tractor
					, i.lgh_number
					, 'A'
					, trc_gps_latitude/3600.0000
					, trc_gps_longitude/3600.0000
					FROM 
						@inserted i
						 INNER JOIN
						@deleted d ON i.lgh_number = d.lgh_number
							INNER JOIN
						dbo.tractorprofile t ON i.lgh_tractor = t.trc_number
					WHERE
						i.lgh_outstatus = 'DSP' 
							AND 
						i.lgh_outstatus <> d.lgh_outstatus 
							AND 
						i.lgh_tractor <> 'UNKNOWN'
							AND
						t.trc_gps_latitude > 0
							AND
						t.trc_gps_longitude > 0;
			END;--IF @MaptuitDirectionsOnDispatch = 'Y'
  END;--IF inserted/delete have any rows
 
  --PTS22080 MBR 03/25/04
  --IF @MapTuitGeocode = 'Y'
  IF @MaptuitAlert = 'Y'
  BEGIN    
    SELECT --Why count here?  Why not exists like everywhere else?  Because I need to know how many IDENTs to get.
      @COUNT = COUNT(*)
    FROM 
      @inserted i
        INNER JOIN
      @deleted d ON i.lgh_number = d.lgh_number
    WHERE
      i.lgh_outstatus = 'CMP' 
        AND 
      i.lgh_outstatus <> ISNULL(d.lgh_outstatus, 'AVL')
        AND 
      i.ord_hdrnumber > 0

    IF @COUNT > 0
    BEGIN
      EXEC @m2qhid = [dbo].[getsystemnumberblock] 'M2QHID', '', @COUNT;
      
      INSERT dbo.m2msgqdtl (
        m2qdid
      , m2qdkey
      , m2qdcrtpgm
      , m2qdvalue)
      SELECT
        ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
      , 'DispatchID'
      , 'HIL'
      , CONVERT(VARCHAR, i.lgh_number)
      FROM 
        @inserted i
          INNER JOIN
        @deleted d ON i.lgh_number = d.lgh_number
      WHERE
        i.lgh_outstatus = 'CMP' 
          AND 
		i.lgh_outstatus <> ISNULL(d.lgh_outstatus, 'AVL')
          AND 
        i.ord_hdrnumber > 0;

      INSERT dbo.m2msgqdtl (
        m2qdid
      , m2qdkey
      , m2qdcrtpgm
      , m2qdvalue)
      SELECT
        ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
      , 'TimeStamp'
      , 'HIL'
      , CONVERT(VARCHAR, GETDATE(), 20)
      FROM 
        @inserted i
          INNER JOIN
        @deleted d ON i.lgh_number = d.lgh_number
      WHERE
        i.lgh_outstatus = 'CMP' 
          AND 
		i.lgh_outstatus <> ISNULL(d.lgh_outstatus, 'AVL')
          AND 
        i.ord_hdrnumber > 0;
      
       
      INSERT dbo.m2msgqhdr 
      SELECT
        ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
      , 'Empty'
      , GETDATE()
      , 'R'
      FROM 
        @inserted i
          INNER JOIN
        @deleted d ON i.lgh_number = d.lgh_number
      WHERE
        i.lgh_outstatus = 'CMP' 
          AND 
        i.lgh_outstatus <> ISNULL(d.lgh_outstatus, 'AVL')
          AND 
        i.ord_hdrnumber > 0;
      
    END;--IF @COUNT > 0

    -- KMM FOR MBR  PTS 22080
    SELECT 
      @COUNT = COUNT(*)
    FROM
      @inserted i
        INNER JOIN
      @deleted d ON i.lgh_number = d.lgh_number
    WHERE
      i.lgh_outstatus = 'STD' 
        AND 
      i.lgh_outstatus <> ISNULL(d.lgh_outstatus, 'AVL')
        AND 
      i.ord_hdrnumber = 0;

    IF @COUNT > 0
    BEGIN
      -- MAPTUIT EMPTY MESSAGE

      
      EXEC @m2qhid = [dbo].[getsystemnumberblock] 'M2QHID', '', @COUNT;
      
      INSERT dbo.m2msgqdtl (
        m2qdid
      , m2qdkey
      , m2qdcrtpgm
      , m2qdvalue)
      SELECT
        ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
      , 'RoutelinePoint_CityName'
      , 'HIL'
      , c.cty_name
      FROM
        @inserted i
          INNER JOIN
        @deleted d ON i.lgh_number = d.lgh_number
          INNER JOIN
        dbo.city c ON i.lgh_endcity = c.cty_code
      WHERE
        i.lgh_outstatus = 'STD' 
          AND 
        i.lgh_outstatus <> ISNULL(d.lgh_outstatus, 'AVL')
          AND 
        i.ord_hdrnumber = 0;
      
      INSERT dbo.m2msgqdtl (
        m2qdid
      , m2qdkey
      , m2qdcrtpgm
      , m2qdvalue)
      SELECT
        ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
      , 'RoutelinePoint_RegionCode'
      , 'HIL'
      , c.cty_state
      FROM
        @inserted i
          INNER JOIN
        @deleted d ON i.lgh_number = d.lgh_number
          INNER JOIN
        dbo.city c ON i.lgh_endcity = c.cty_code
      WHERE
        i.lgh_outstatus = 'STD' 
          AND 
        i.lgh_outstatus <> ISNULL(d.lgh_outstatus, 'AVL')
          AND 
        i.ord_hdrnumber = 0;
      
      INSERT dbo.m2msgqdtl (
        m2qdid
      , m2qdkey
      , m2qdcrtpgm
      , m2qdvalue)
      SELECT
        ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
      , 'UNITID'
      , 'HIL'
      , i.lgh_tractor
      FROM
        @inserted i
          INNER JOIN
        @deleted d ON i.lgh_number = d.lgh_number       
      WHERE
        i.lgh_outstatus = 'STD' 
          AND 
        i.lgh_outstatus <> ISNULL(d.lgh_outstatus, 'AVL')
          AND 
        i.ord_hdrnumber = 0;
      
      INSERT dbo.m2msgqdtl (
        m2qdid
      , m2qdkey
      , m2qdcrtpgm
      , m2qdvalue) 
      SELECT
        ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
      , 'Timestamp'
      , 'HIL'
      , CONVERT(VARCHAR, GETDATE(), 20)
      FROM
        @inserted i
          INNER JOIN
        @deleted d ON i.lgh_number = d.lgh_number       
      WHERE
        i.lgh_outstatus = 'STD' 
          AND 
        i.lgh_outstatus <> ISNULL(d.lgh_outstatus, 'AVL')
          AND 
        i.ord_hdrnumber = 0;
    
      INSERT dbo.m2msgQhdr 
      SELECT
        ROW_NUMBER() OVER (ORDER BY i.lgh_number) + @m2qhid - 1
      , 'Deadhead'
      , GETDATE()
      , 'R'
      FROM
        @inserted i
          INNER JOIN
        @deleted d ON i.lgh_number = d.lgh_number       
      WHERE
        i.lgh_outstatus = 'STD' 
          AND 
        i.lgh_outstatus <> ISNULL(d.lgh_outstatus, 'AVL')
          AND 
        i.ord_hdrnumber = 0;

    -- END FOR MBR
    END;--IF @COUNT > 0
   
    IF EXISTS(SELECT 
                1    
              FROM 
                @inserted i
                  INNER JOIN
                @deleted d ON i.lgh_number = d.lgh_number
              WHERE
                i.lgh_outstatus = 'STD' 
                  AND
                i.lgh_outstatus <> ISNULL(d.lgh_outstatus,'AVL') 
                  AND                 
                i.ord_hdrnumber > 0)
    BEGIN

      INSERT dbo.maptuitdispatch 
      SELECT 
        i.lgh_number
      , 'D'  
      FROM 
        @inserted i
          INNER JOIN
        @deleted d ON i.lgh_number = d.lgh_number
      WHERE
        i.lgh_outstatus = 'STD' 
          AND
        i.lgh_outstatus <> ISNULL(d.lgh_outstatus,'AVL') 
          AND                 
        i.ord_hdrnumber > 0

    END;--IF EXISTS(valid rows in inserted/deleted)
  END;--IF @MaptuitAlert = 'Y'
END;--IF @Maptuitgeocode = 'Y'
--end 55467

GO
GRANT EXECUTE ON  [dbo].[lgh_cons_tr_Maptuit_sp] TO [public]
GO
