SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_getResourceTypes_From_Log_sp]
      ( @effective      DATETIME
      , @Drv_ID         VARCHAR(13)
      , @Trc_ID         VARCHAR(13)
      , @Trl_ID         VARCHAR(13)
      , @Car_ID         VARCHAR(13)
      )
AS

/*
*
*
* NAME:
* dbo.d_getResourceTypes_From_Log_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to return info from AssetProfileLog
*
* RETURNS:
*
* NOTHING:
*
* 01/06/2012 PTS58228 SPN - Created Initial Version
*
*/ 

SET NOCOUNT ON

BEGIN

   DECLARE @DrvType1       VARCHAR(50)
   DECLARE @DrvType2       VARCHAR(50)
   DECLARE @DrvType3       VARCHAR(50)
   DECLARE @DrvType4       VARCHAR(50)
   DECLARE @DrvCompany     VARCHAR(50)
   DECLARE @DrvDivision    VARCHAR(50)
   DECLARE @DrvFleet       VARCHAR(50)
   DECLARE @DrvTerminal    VARCHAR(50)
   DECLARE @DrvTeamLeader  VARCHAR(50)
   DECLARE @DrvDomicile    VARCHAR(50)
   
   DECLARE @TrcType1       VARCHAR(50)
   DECLARE @TrcType2       VARCHAR(50)
   DECLARE @TrcType3       VARCHAR(50)
   DECLARE @TrcType4       VARCHAR(50)
   DECLARE @TrcCompany     VARCHAR(50)
   DECLARE @TrcDivision    VARCHAR(50)
   DECLARE @TrcFleet       VARCHAR(50)
   DECLARE @TrcTerminal    VARCHAR(50)
   
   DECLARE @TrlType1       VARCHAR(50)
   DECLARE @TrlType2       VARCHAR(50)
   DECLARE @TrlType3       VARCHAR(50)
   DECLARE @TrlType4       VARCHAR(50)
   DECLARE @TrlCompany     VARCHAR(50)
   DECLARE @TrlDivision    VARCHAR(50)
   DECLARE @TrlFleet       VARCHAR(50)
   DECLARE @TrlTerminal    VARCHAR(50)
   
   DECLARE @CarType1       VARCHAR(50)
   DECLARE @CarType2       VARCHAR(50)
   DECLARE @CarType3       VARCHAR(50)
   DECLARE @CarType4       VARCHAR(50)

   DECLARE @temp TABLE
   ( effective       DATETIME
   , Drv_ID          VARCHAR(13)
   , DrvType1        VARCHAR(50)
   , DrvType2        VARCHAR(50)
   , DrvType3        VARCHAR(50)
   , DrvType4        VARCHAR(50)
   , DrvCompany      VARCHAR(50)
   , DrvDivision     VARCHAR(50)
   , DrvFleet        VARCHAR(50)
   , DrvTerminal     VARCHAR(50)
   , DrvTeamLeader   VARCHAR(50)
   , DrvDomicile     VARCHAR(50)
   , Trc_ID          VARCHAR(13)
   , TrcType1        VARCHAR(50)
   , TrcType2        VARCHAR(50)
   , TrcType3        VARCHAR(50)
   , TrcType4        VARCHAR(50)
   , TrcCompany      VARCHAR(50)
   , TrcDivision     VARCHAR(50)
   , TrcFleet        VARCHAR(50)
   , TrcTerminal     VARCHAR(50)
   , Trl_ID          VARCHAR(13)
   , TrlType1        VARCHAR(50)
   , TrlType2        VARCHAR(50)
   , TrlType3        VARCHAR(50)
   , TrlType4        VARCHAR(50)
   , TrlCompany      VARCHAR(50)
   , TrlDivision     VARCHAR(50)
   , TrlFleet        VARCHAR(50)
   , TrlTerminal     VARCHAR(50)
   , Car_ID          VARCHAR(13)
   , CarType1        VARCHAR(50)
   , CarType2        VARCHAR(50)
   , CarType3        VARCHAR(50)
   , CarType4        VARCHAR(50)
   )

   --'Driver'
   EXEC getResourceType_From_Log_sp @effective, 'DRV', @Drv_ID, 'DrvType1',   @DrvType1      OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'DRV', @Drv_ID, 'DrvType2',   @DrvType2      OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'DRV', @Drv_ID, 'DrvType3',   @DrvType3      OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'DRV', @Drv_ID, 'DrvType4',   @DrvType4      OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'DRV', @Drv_ID, 'Company',    @DrvCompany    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'DRV', @Drv_ID, 'Division',   @DrvDivision   OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'DRV', @Drv_ID, 'Fleet',      @DrvFleet      OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'DRV', @Drv_ID, 'Terminal',   @DrvTerminal   OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'DRV', @Drv_ID, 'TeamLeader', @DrvTeamLeader OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'DRV', @Drv_ID, 'Domicile',   @DrvDomicile   OUTPUT
   
   --'Tractor'
   EXEC getResourceType_From_Log_sp @effective, 'TRC', @Trc_ID, 'TrcType1',   @TrcType1    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRC', @Trc_ID, 'TrcType2',   @TrcType2    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRC', @Trc_ID, 'TrcType3',   @TrcType3    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRC', @Trc_ID, 'TrcType4',   @TrcType4    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRC', @Trc_ID, 'Company',    @TrcCompany  OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRC', @Trc_ID, 'Division',   @TrcDivision OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRC', @Trc_ID, 'Fleet',      @TrcFleet    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRC', @Trc_ID, 'Terminal',   @TrcTerminal OUTPUT
   
   --'Trailer'
   EXEC getResourceType_From_Log_sp @effective, 'TRL', @Trl_ID, 'TrlType1',   @TrlType1    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRL', @Trl_ID, 'TrlType2',   @TrlType2    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRL', @Trl_ID, 'TrlType3',   @TrlType3    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRL', @Trl_ID, 'TrlType4',   @TrlType4    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRL', @Trl_ID, 'Company',    @TrlCompany  OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRL', @Trl_ID, 'Division',   @TrlDivision OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRL', @Trl_ID, 'Fleet',      @TrlFleet    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'TRL', @Trl_ID, 'Terminal',   @TrlTerminal OUTPUT
   
   --'Carrier'
   EXEC getResourceType_From_Log_sp @effective, 'CAR', @Car_ID, 'CarType1',   @CarType1    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'CAR', @Car_ID, 'CarType2',   @CarType2    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'CAR', @Car_ID, 'CarType3',   @CarType3    OUTPUT
   EXEC getResourceType_From_Log_sp @effective, 'CAR', @Car_ID, 'CarType4',   @CarType4    OUTPUT
   

   INSERT INTO @temp
   ( effective    
   , Drv_ID
   , DrvType1     
   , DrvType2     
   , DrvType3     
   , DrvType4     
   , DrvCompany   
   , DrvDivision  
   , DrvFleet     
   , DrvTerminal  
   , DrvTeamLeader
   , DrvDomicile  
   , Trc_ID
   , TrcType1     
   , TrcType2     
   , TrcType3     
   , TrcType4     
   , TrcCompany   
   , TrcDivision  
   , TrcFleet     
   , TrcTerminal  
   , Trl_ID
   , TrlType1     
   , TrlType2     
   , TrlType3     
   , TrlType4     
   , TrlCompany   
   , TrlDivision  
   , TrlFleet     
   , TrlTerminal  
   , Car_ID
   , CarType1
   , CarType2
   , CarType3
   , CarType4
   )
   VALUES
   ( @effective
   , @Drv_ID
   , @DrvType1     
   , @DrvType2     
   , @DrvType3     
   , @DrvType4     
   , @DrvCompany   
   , @DrvDivision  
   , @DrvFleet     
   , @DrvTerminal  
   , @DrvTeamLeader
   , @DrvDomicile  
   , @Trc_ID
   , @TrcType1     
   , @TrcType2     
   , @TrcType3     
   , @TrcType4     
   , @TrcCompany   
   , @TrcDivision  
   , @TrcFleet     
   , @TrcTerminal  
   , @Trl_ID
   , @TrlType1     
   , @TrlType2     
   , @TrlType3     
   , @TrlType4     
   , @TrlCompany   
   , @TrlDivision  
   , @TrlFleet     
   , @TrlTerminal  
   , @Car_ID
   , @CarType1
   , @CarType2
   , @CarType3
   , @CarType4
   )
   
   SELECT * FROM @temp
   
   RETURN
   
END
GO
GRANT EXECUTE ON  [dbo].[d_getResourceTypes_From_Log_sp] TO [public]
GO
